//
//  WXFileModel.m
//  WeChat
//
//  Created by Vincent on 2019/6/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXFileModel.h"

#define WXFilePathGifExtension         @"gif"
#define WXFilePathImageExtension     @"jpg"
#define WXFilePathVideoExtension     @"mp4"
#define WXFilePathAudioExtension     @"wav"
#define WXFilePathDataExtension      @"data"

@implementation WXFileModel
@synthesize content = _content;
@synthesize filePath = _filePath;

- (instancetype)init {
    if (self = [super init]) {
        self.identifier = NSString.identifier;
    }
    return self;
}

+ (instancetype)fileWithImage:(UIImage *)image session:(NSString *)session {
    if (!image || session.length <= 0) return nil;
    NSData *imageData = [NSData dataWithImage:image];
    if (imageData.length <= 0) return nil;
    NSString *filePath = [WechatHelper.helper.sessionPath stringByAppendingFormat:@"/%@/%@.%@", session, NSString.identifier, (image.isAnimatedImage ? WXFilePathGifExtension : WXFilePathImageExtension)];
    [NSFileManager.defaultManager createDirectoryAtPath:filePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
    if (![imageData writeToFile:filePath atomically:YES]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.session = session;
    model.identifier = filePath.lastPathComponent;
    model->_filePath = filePath.copy;
    model->_content = image.copy;
    model.type = WXFileTypeImage;
    return model;
}

+ (instancetype)fileWithDictionary:(NSDictionary *)dictionary session:(NSString *)session {
    if (dictionary.allKeys <= 0 || session.length <= 0) return nil;
    NSString *identifier = NSString.identifier;
    NSString *filePath = [WechatHelper.helper.sessionPath stringByAppendingFormat:@"/%@/%@.%@", session, identifier, WXFilePathDataExtension];
    if (![dictionary.JsonData writeToFile:filePath atomically:YES]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.identifier = filePath.lastPathComponent;
    model.session = session;
    model->_filePath = filePath;
    model->_content = dictionary.copy;
    model.type = WXFileTypeJSON;
    return model;
}

+ (instancetype)fileWithObject:(NSObject *)obj session:(NSString *)session {
    if (!obj || session.length <= 0) return nil;
    NSString *identifier = NSString.identifier;
    NSString *filePath = [WechatHelper.helper.sessionPath stringByAppendingFormat:@"/%@/%@.%@", session, identifier, WXFilePathDataExtension];
    if (![MNFileHandle writeData:obj.archivedData toFile:filePath error:nil]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.identifier = filePath.lastPathComponent;
    model.session = session;
    model->_filePath = filePath;
    model->_content = obj;
    model.type = WXFileTypeObject;
    return model;
}

+ (instancetype)fileWithAudio:(NSString *)audioPath session:(NSString *)session {
    if (audioPath.length <= 0 || session.length <= 0) return nil;
    NSString *identifier = NSString.identifier;
    NSString *filePath = [WechatHelper.helper.sessionPath stringByAppendingFormat:@"/%@/%@.%@", session, identifier, WXFilePathAudioExtension];
    if (![NSFileManager.defaultManager copyItemAtPath:audioPath toPath:filePath error:nil]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.type = WXFileTypeAudio;
    model.identifier = filePath.lastPathComponent;
    model.session = session;
    model->_filePath = filePath;
    return model;
}

+ (instancetype)fileWithVideo:(NSString *)videoPath session:(NSString *)session {
    if (videoPath.length <= 0 || session.length <= 0) return nil;
    NSString *identifier = NSString.identifier;
    NSString *filePath = [WechatHelper.helper.sessionPath stringByAppendingFormat:@"/%@/%@.%@", session, identifier, WXFilePathVideoExtension];
    if (![NSFileManager.defaultManager copyItemAtPath:videoPath toPath:filePath error:nil]) return nil;
    UIImage *thumbnailImage = [MNAssetExporter exportThumbnailOfVideoAtPath:filePath];
    if (!thumbnailImage) return nil;
    NSString *thumbnailPath = [filePath.stringByDeletingPathExtension stringByAppendingPathExtension:WXFilePathImageExtension];
    if (![MNFileHandle writeImage:thumbnailImage toFile:thumbnailPath error:nil]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
        return nil;
    }
    WXFileModel *model = WXFileModel.new;
    model.type = WXFileTypeVideo;
    model.identifier = filePath.lastPathComponent;
    model.session = session;
    model->_filePath = filePath;
    model->_content = thumbnailImage.copy;
    return model;
}

- (BOOL)replaceContentWithObject:(NSObject *)obj {
    if (self.type == WXFileTypeUnknown || !self.content || !obj) return NO;
    NSString *filePath = self.filePath;
    if (filePath.length <= 0) return NO;
    // 先移动原数据到缓存
    NSString *tempPath = MNTempPathAppending(filePath.lastPathComponent);
    if (![NSFileManager.defaultManager moveItemAtPath:filePath toPath:tempPath error:nil]) return NO;
    if (![obj.archivedData writeToFile:filePath atomically:YES]) {
        // 放回原数据
        [NSFileManager.defaultManager moveItemAtPath:tempPath toPath:filePath error:nil];
        return NO;
    }
    self->_content = obj;
    [NSFileManager.defaultManager removeItemAtPath:tempPath error:nil];
    return YES;
}

#pragma mark - Getter
- (NSString *)filePath {
    if (!_filePath && self.session.length && self.identifier.length && _type != WXFileTypeUnknown) {
        _filePath = [WechatHelper.helper.sessionPath stringByAppendingFormat:@"/%@/%@", _session, _identifier];
    }
    return _filePath;
}

- (id)content {
    if (!_content) {
        NSString *filePath = self.filePath;
        if (filePath.length <= 0) return nil;
        if (self.type == WXFileTypeImage) {
            if ([filePath.pathExtension isEqualToString:WXFilePathGifExtension]) {
                _content = [UIImage imageWithContentsAtFile:filePath];
            } else {
                _content = [UIImage imageWithContentsOfFile:filePath];
            }
        } else if (self.type == WXFileTypeAudio) {
            _content = [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:ceil([MNAssetExporter exportDurationWithMediaAtPath:filePath])]];
            _content = [NSString replacingEmptyCharacters:_content withCharacters:@"0"];
        } else if (self.type == WXFileTypeVideo) {
            _content = [UIImage imageWithContentsOfFile:[filePath.stringByDeletingPathExtension stringByAppendingPathExtension:WXFilePathImageExtension]];
        } else if (self.type == WXFileTypeObject) {
            NSData *objData = [NSData dataWithContentsOfFile:filePath];
            if (objData.length) _content = objData.unarchivedObject;
        } else if (self.type == WXFileTypeJSON) {
            NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
            if (jsonData.length) _content = jsonData.JsonValue;
        }
    }
    return _content;
}

- (void)removeContentsAtFile {
    if (!self.filePath) return;
    if (self.type == WXFileTypeVideo) {
        [NSFileManager.defaultManager removeItemAtPath:[self.filePath.stringByDeletingPathExtension stringByAppendingPathExtension:WXFilePathImageExtension] error:nil];
    } else if (self.type == WXFileTypeObject) {
        if ([self.content respondsToSelector:@selector(removeContentsAtFile)]) {
            [self.content removeContentsAtFile];
        }
    }
    [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.type forKey:kPath(self.type)];
    [aCoder encodeObject:self.session forKey:kPath(self.session)];
    [aCoder encodeObject:self.identifier forKey:kPath(self.identifier)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.type = [aDecoder decodeIntegerForKey:kPath(self.type)];
        self.session = [aDecoder decodeObjectForKey:kPath(self.session)];
        self.identifier = [aDecoder decodeObjectForKey:kPath(self.identifier)];
    }
    return self;
}

@end
