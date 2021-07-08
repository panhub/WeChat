//
//  WXProfile.m
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXProfile.h"

@implementation WXProfile
{
    UIImage *_image;
    NSString *_filePath;
}

+ (WXProfile *)pictureWithImage:(UIImage *)image {
    NSString *fileName = [NSString.identifier stringByAppendingPathExtension:@"jpg"];
    NSString *filePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:fileName];
    if (![MNFileHandle writeImage:image toFile:filePath error:nil]) return nil;
    WXProfile *picture = WXProfile.new;
    picture.type = WXProfileTypeImage;
    picture.file_name = fileName;
    picture.identifier = NSDate.shortTimestamps;
    picture->_filePath = filePath;
    picture->_image = image;
    return picture;
}

+ (WXProfile *)pictureWithVideoPath:(NSString *)video {
    NSString *fileName = [NSString.identifier stringByAppendingPathExtension:@"mp4"];
    NSString *filePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:fileName];
    if (![NSFileManager.defaultManager copyItemAtPath:video toPath:filePath error:nil]) return nil;
    UIImage *image = [MNAssetExporter exportThumbnailOfVideoAtPath:video];
    NSString *imagePath = [filePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
    if (![MNFileHandle writeImage:image toFile:imagePath error:nil]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
        return nil;
    }
    WXProfile *picture = WXProfile.new;
    picture.type = WXProfileTypeVideo;
    picture.file_name = fileName;
    picture.identifier = NSDate.shortTimestamps;
    picture->_filePath = filePath;
    picture->_image = image;
    return picture;
}

+ (WXProfile *)pictureWithProfile:(id)profile {
    if ([profile isKindOfClass:UIImage.class]) {
        return [self pictureWithImage:profile];
    } else if ([profile isKindOfClass:NSString.class]) {
        return [self pictureWithVideoPath:profile];
    } else if ([profile isKindOfClass:NSURL.class]) {
        return [self pictureWithVideoPath:((NSURL *)profile).path];
    }
    return nil;
}

- (void)removeContentsAtFile {
    if (self.filePath.length <= 0) return;
    if (self.type == WXProfileTypeVideo) {
        NSString *imagePath = [self.filePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
        [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
    }
    [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
}

- (BOOL)isEqualToProfile:(WXProfile *)profile {
    if ([profile isMemberOfClass:WXProfile.class]) {
        return [profile.file_name isEqualToString:self.file_name];
    }
    return NO;
}

#pragma mark - Getter
- (UIImage *)image {
    if (!_image && self.filePath.length) {
        if (self.type == WXProfileTypeImage) {
            _image = [UIImage imageWithContentsOfFile:self.filePath];
        } else {
            NSString *imagePath = [self.filePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
            _image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    return _image;
}

- (NSString *)filePath {
    if (!_filePath && self.file_name.length) {
        _filePath = [WechatHelper.helper.momentPath stringByAppendingPathComponent:self.file_name];
    }
    return _filePath;
}

- (id)content {
    return self.type == WXProfileTypeImage ? self.image : self.filePath;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXProfile *profile = [[self.class allocWithZone:zone] init];
    profile.type = self.type;
    profile.moment = self.moment;
    profile.identifier = self.identifier;
    profile.file_name = self.file_name;
    profile.timestamp = self.timestamp;
    profile->_image = _image;
    profile->_filePath = _filePath;
    return profile;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.type forKey:sql_field(self.type)];
    [aCoder encodeObject:self.moment forKey:sql_field(self.moment)];
    [aCoder encodeObject:self.identifier forKey:sql_field(self.identifier)];
    [aCoder encodeObject:self.file_name forKey:sql_field(self.file_name)];
    [aCoder encodeObject:self.timestamp forKey:sql_field(self.timestamp)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.type = [aDecoder decodeIntegerForKey:sql_field(self.type)];
        self.moment = [aDecoder decodeObjectForKey:sql_field(self.moment)];
        self.identifier = [aDecoder decodeObjectForKey:sql_field(self.identifier)];
        self.file_name = [aDecoder decodeObjectForKey:sql_field(self.file_name)];
        self.timestamp = [aDecoder decodeObjectForKey:sql_field(self.timestamp)];
    }
    return self;
}

#pragma mark - SQL
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"identifier":MNSQLFieldText, @"file_name":MNSQLFieldText, @"type":MNSQLFieldInteger, @"moment":MNSQLFieldText, @"timestamp":MNSQLFieldText};
}

@end
