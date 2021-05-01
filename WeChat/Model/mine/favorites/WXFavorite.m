//
//  WXFavorite.m
//  WeChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXFavorite.h"
#import "WXWebpage.h"
#import "WXLocation.h"

@implementation WXFavorite
{
    UIImage *_image;
    NSString *_filePath;
}

- (instancetype)init {
    if (self = [super init]) {
        self.identifier = MNFileHandle.fileName;
        self.timestamp = NSDate.timestamps;
    }
    return self;
}

+ (instancetype)shareWithDictionary:(NSDictionary *)dic {
    if (!dic) return nil;
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
    NSData *imageData = dic[WXShareFavoriteImageKey];
    if (!imageData) imageData = [UIImage imageNamed:@"favorite_link"].imageData;
    if (![MNFileHandle writeData:imageData toFile:filePath error:nil]) return nil;
    WXFavorite *favorite = [WXFavorite new];
    favorite.type = WXFavoriteTypeWeb;
    favorite.identifier = filePath.lastPathComponent;
    favorite.url = dic[WXShareFavoriteUrlKey];
    favorite.title = dic[WXShareFavoriteTitleKey];
    favorite.source = dic[WXShareFavoriteSourceKey];
    favorite.subtitle = dic[WXShareFavoriteSubtitleKey];
    favorite.timestamp = dic[WXShareFavoriteTimeKey];
    if (!favorite.source) favorite.uid = WXUser.shareInfo.uid;
    favorite->_filePath = filePath;
    return favorite;
}

+ (WXFavorite *)favoriteWithImage:(UIImage *)image {
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
    if (![MNFileHandle writeImage:image toFile:filePath error:nil]) return nil;
    WXFavorite *favorite = WXFavorite.new;
    favorite.type = WXFavoriteTypeImage;
    favorite.identifier = filePath.lastPathComponent;
    favorite->_image = image;
    favorite->_filePath = filePath;
    return favorite;
}

+ (WXFavorite *)favoriteWithImagePath:(NSString *)imagePath {
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:imagePath.pathExtension]];
    if (![NSFileManager.defaultManager copyItemAtPath:imagePath toPath:filePath error:nil]) return nil;
    WXFavorite *favorite = WXFavorite.new;
    favorite.type = WXFavoriteTypeImage;
    favorite.identifier = filePath.lastPathComponent;
    favorite->_filePath = filePath;
    return favorite;
}

+ (WXFavorite *_Nullable)favoriteWithText:(NSString *)text {
    WXFavorite *favorite = WXFavorite.new;
    favorite.type = WXFavoriteTypeText;
    favorite.timestamp = NSDate.timestamps;
    favorite.title = text;
    return favorite;
}

+ (WXFavorite *)favoriteWithVideoPath:(NSString *)video {
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:video.pathExtension]];
    if (![NSFileManager.defaultManager copyItemAtPath:video toPath:filePath error:nil]) return nil;
    UIImage *image = [MNAssetExporter exportThumbnailOfVideoAtPath:video];
    NSString *imagePath = [filePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
    if (![MNFileHandle writeImage:image toFile:imagePath error:nil]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
        return nil;
    }
    WXFavorite *favorite = WXFavorite.new;
    favorite.type = WXFavoriteTypeVideo;
    favorite.identifier = filePath.lastPathComponent;
    favorite->_image = image;
    favorite->_filePath = filePath;
    return favorite;
}

+ (WXFavorite *)favoriteWithWebpage:(WXWebpage *)webpage {
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath;
    if (webpage.image) {
        filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:webpage.identifier.pathExtension]];
        if (![MNFileHandle writeImage:webpage.image toFile:filePath error:nil]) return nil;
    }
    WXFavorite *favorite = WXFavorite.new;
    favorite.type = WXFavoriteTypeWeb;
    favorite.identifier = filePath ? filePath.lastPathComponent : identifier;
    favorite.title = webpage.title;
    favorite.subtitle = webpage.subtitle;
    favorite.url = webpage.url;
    favorite->_filePath = filePath;
    return favorite;
}

+ (WXFavorite *)favoriteWithLocation:(WXLocation *)location {
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath;
    if (location.snapshot) {
        filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
        if (![MNFileHandle writeImage:location.snapshot toFile:filePath error:nil]) return nil;
    }
    WXFavorite *favorite = WXFavorite.new;
    favorite.type = WXFavoriteTypeLocation;
    favorite.identifier = filePath ? filePath.lastPathComponent : identifier;
    favorite->_filePath = filePath;
    favorite.title = location.name;
    favorite.subtitle = location.address;
    favorite.url = NSStringFromCoordinate2D(location.coordinate);
    return favorite;
}

- (void)removeContentsAtFile {
    if (!self.filePath) return;
    if (self.type == WXFavoriteTypeVideo) {
        NSString *imagePath = [self.filePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
        [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
    }
    [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
}

#pragma mark - Getter
- (NSString *)filePath {
    if (!_filePath && self.identifier.pathExtension.length) {
        _filePath = [WechatHelper.helper.favoritePath stringByAppendingPathComponent:self.identifier];
    }
    return _filePath;
}

- (UIImage *)image {
    if (!_image && self.filePath.length) {
        if (self.type == WXFavoriteTypeWeb || self.type == WXFavoriteTypeImage || self.type == WXFavoriteTypeLocation) {
            _image = [UIImage imageWithContentsOfFile:self.filePath];
        } else if (self.type == WXFavoriteTypeVideo) {
            NSString *imagePath = [self.filePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
            _image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    return _image;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:sql_field(self.url)];
    [aCoder encodeObject:self.uid forKey:sql_field(self.uid)];
    [aCoder encodeObject:self.title forKey:sql_field(self.title)];
    [aCoder encodeInteger:self.type forKey:sql_field(self.type)];
    [aCoder encodeObject:self.source forKey:sql_field(self.source)];
    [aCoder encodeObject:self.subtitle forKey:sql_field(self.subtitle)];
    [aCoder encodeObject:self.identifier forKey:sql_field(self.identifier)];
    [aCoder encodeObject:self.timestamp forKey:sql_field(self.timestamp)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.url = [aDecoder decodeObjectForKey:sql_field(self.url)];
        self.uid = [aDecoder decodeObjectForKey:sql_field(self.uid)];
        self.title = [aDecoder decodeObjectForKey:sql_field(self.title)];
        self.type = [aDecoder decodeIntegerForKey:sql_field(self.type)];
        self.source = [aDecoder decodeObjectForKey:sql_field(self.source)];
        self.subtitle = [aDecoder decodeObjectForKey:sql_field(self.subtitle)];
        self.identifier = [aDecoder decodeObjectForKey:sql_field(self.identifier)];
        self.timestamp = [aDecoder decodeObjectForKey:sql_field(self.timestamp)];
    }
    return self;
}

@end
