//
//  WXWebpage.m
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  

#import "WXWebpage.h"
#import "WXFavorite.h"
#import "WXSession.h"

@implementation WXWebpage
{
    UIImage *_image;
}

- (instancetype)init {
    if (self = [super init]) {
        self.timestamp = NSDate.timestamps;
    }
    return self;
}

+ (WXWebpage *)webpageWithImage:(UIImage *)image {
    if (!image) image = [UIImage imageNamed:@"favorite_link"];
    NSString *identifier = NSString.identifier;
    NSString *imagePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
    if (![MNFileHandle writeImage:image toFile:imagePath error:nil]) return nil;
    WXWebpage *webpage = WXWebpage.new;
    webpage.identifier = imagePath.lastPathComponent;
    webpage->_image = image;
    return webpage;
}

+ (WXWebpage *)webpageWithWebFavorite:(WXFavorite *)favorite session:(WXSession *)session {
    NSString *identifier = NSString.identifier;
    NSString *imagePath = [WechatHelper.helper.sessionPath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
    if (![MNFileHandle writeImage:favorite.image toFile:imagePath error:nil]) return nil;
    WXWebpage *webpage = WXWebpage.new;
    webpage.url = favorite.url;
    webpage.title = favorite.title;
    webpage.subtitle = favorite.subtitle;
    webpage.identifier = imagePath.lastPathComponent;
    webpage->_image = [UIImage imageWithContentsOfFile:imagePath];
    return webpage;
}

+ (WXWebpage *)webpageWithImageData:(NSData *)imageData {
    if (!imageData) imageData = [UIImage imageNamed:@"favorite_link"].imageData;
    NSString *identifier = NSString.identifier;
    NSString *imagePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:[identifier stringByAppendingPathExtension:@"jpg"]];
    if (![MNFileHandle writeData:imageData toFile:imagePath error:nil]) return nil;
    WXWebpage *webpage = WXWebpage.new;
    webpage.identifier = imagePath.lastPathComponent;
    webpage->_image = [UIImage imageWithContentsOfFile:imagePath];
    return webpage;
}

+ (WXWebpage *)shareWithDictionary:(NSDictionary *)dic {
    NSData *imageData = dic[WXShareFavoriteImageKey];
    if (!imageData) imageData = [UIImage imageNamed:@"favorite_link"].imageData;
    WXWebpage *webpage = [self webpageWithImageData:imageData];
    if (!webpage) return nil;
    webpage.title = dic[WXShareFavoriteTitleKey];
    webpage.url = dic[WXShareFavoriteUrlKey];
    NSString *timestamp = dic[WXShareFavoriteTimeKey];
    if (timestamp.length) webpage.timestamp = timestamp;
    return webpage;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXWebpage *item = [WXWebpage allocWithZone:zone];
    item.identifier = self.identifier;
    item.url = self.url;
    item.title = self.title;
    item.subtitle = self.subtitle;
    item.timestamp = self.timestamp;
    item->_image = self->_image;
    return item;
}

- (void)removeContentsAtFile {
    NSString *imagePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:self.identifier];
    if ([NSFileManager.defaultManager fileExistsAtPath:imagePath]) {
        [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
    }
}

#pragma mark - Getter
- (UIImage *)image {
    if (!_image && self.identifier.pathExtension.length) {
        NSString *imagePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:self.identifier];
        _image = [UIImage imageWithContentsOfFile:imagePath];
    }
    return _image;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:sql_field(self.identifier)];
    [coder encodeObject:self.url forKey:sql_field(self.url)];
    [coder encodeObject:self.title forKey:sql_field(self.title)];
    [coder encodeObject:self.subtitle forKey:sql_field(self.subtitle)];
    [coder encodeObject:self.timestamp forKey:sql_field(self.timestamp)];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.identifier = [coder decodeObjectForKey:sql_field(self.identifier)];
        self.url = [coder decodeObjectForKey:sql_field(self.url)];
        self.title = [coder decodeObjectForKey:sql_field(self.title)];
        self.subtitle = [coder decodeObjectForKey:sql_field(self.subtitle)];
        self.timestamp = [coder decodeObjectForKey:sql_field(self.timestamp)];
    }
    return self;
}

@end
