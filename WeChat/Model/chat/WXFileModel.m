//
//  WXFileModel.m
//  MNChat
//
//  Created by Vincent on 2019/6/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXFileModel.h"

@implementation WXFileModel
@synthesize content = _content;
@synthesize filePath = _filePath;

- (instancetype)init {
    if (self = [super init]) {
        self.identifier = MNFileHandle.fileName;
    }
    return self;
}

+ (instancetype)fileWithImage:(UIImage *)image session:(NSString *)session {
    if (!image || session.length <= 0) return nil;
    NSString *filePath = [WechatHelper.helper.directoryPath stringByAppendingFormat:@"/%@/%@.%@", session, MNFileHandle.fileName, (image.isAnimatedImage ? @"gif":@"png")];
    NSData *imageData = [NSData dataWithImage:image];
    if (imageData.length <= 0) return nil;
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
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.directoryPath stringByAppendingFormat:@"/%@/%@", session, identifier];
    if (![dictionary.JsonData writeToFile:filePath atomically:YES]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.identifier = identifier;
    model.session = session;
    model->_filePath = filePath;
    model->_content = dictionary.copy;
    model.type = WXFileTypeJSON;
    return model;
}

+ (instancetype)fileWithObject:(NSObject *)obj session:(NSString *)session {
    if (!obj || session.length <= 0) return nil;
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.directoryPath stringByAppendingFormat:@"/%@/%@", session, identifier];
    if (![obj.archivedData writeToFile:filePath atomically:YES]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.identifier = identifier;
    model.session = session;
    model->_filePath = filePath;
    model->_content = obj;
    model.type = WXFileTypeObject;
    return model;
}

+ (instancetype)fileWithAudio:(NSString *)audioPath session:(NSString *)session {
    if (audioPath.length <= 0 || session.length <= 0) return nil;
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.directoryPath stringByAppendingFormat:@"/%@/%@.wav", session, identifier];
    if (![NSFileManager.defaultManager moveItemAtPath:audioPath toPath:filePath error:nil]) return nil;
    WXFileModel *model = WXFileModel.new;
    model.identifier = identifier;
    model.session = session;
    model->_filePath = filePath;
    model.type = WXFileTypeAudio;
    return model;
}

+ (instancetype)fileWithVideo:(NSString *)videoPath session:(NSString *)session {
    if (videoPath.length <= 0 || session.length <= 0) return nil;
    NSString *identifier = MNFileHandle.fileName;
    NSString *filePath = [WechatHelper.helper.directoryPath stringByAppendingFormat:@"/%@/%@.mp4", session, identifier];
    if (![NSFileManager.defaultManager moveItemAtPath:videoPath toPath:filePath error:nil]) return nil;
    UIImage *thumbnailImage = [MNAssetExporter exportThumbnailOfVideoAtPath:filePath];
    if (!thumbnailImage) return nil;
    NSString *thumbnailPath = [filePath.stringByDeletingPathExtension stringByAppendingString:@".png"];
    if (![MNFileHandle writeImage:thumbnailImage toFile:thumbnailPath error:nil]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
        return nil;
    }
    WXFileModel *model = WXFileModel.new;
    model.identifier = identifier;
    model.session = session;
    model->_filePath = filePath;
    model->_content = thumbnailImage.copy;
    model.type = WXFileTypeVideo;
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
    if (!_filePath && _session.length && _identifier.length && _type != WXFileTypeUnknown) {
        _filePath = [WechatHelper.helper.directoryPath stringByAppendingFormat:@"/%@/%@", _session, _identifier];
        if (self.type == WXFileTypeAudio) {
            _filePath = [_filePath stringByAppendingPathExtension:@"wav"];
        } else if (self.type == WXFileTypeVideo) {
            _filePath = [_filePath stringByAppendingPathExtension:@"mp4"];
        }
    }
    return _filePath;
}

- (id)content {
    if (!_content) {
        NSString *filePath = self.filePath;
        if (filePath.length <= 0) return nil;
        if (self.type == WXFileTypeImage) {
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            if (imageData.length <= 0) return nil;
            if ([filePath.pathExtension isEqualToString:@"gif"]) {
                _content = [UIImage animatedImageWithData:imageData];
            } else {
                _content = [UIImage imageWithData:imageData];
            }
        } else if (self.type == WXFileTypeAudio) {
            _content = [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:ceil([MNAssetExporter exportDurationWithMediaAtPath:filePath])]];
            _content = [NSString replacingEmptyCharacters:_content withCharacters:@"0"];
        } else if (self.type == WXFileTypeVideo) {
            filePath = [filePath.stringByDeletingPathExtension stringByAppendingString:@".png"];
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            if (imageData.length) _content = [UIImage imageWithData:imageData];
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

- (BOOL)removeContentsAtFile {
    if (self.filePath.length <= 0) return YES;
    return [NSFileManager.defaultManager removeItemAtPath:self.filePath error:nil];
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:kPath(self.identifier)];
    [aCoder encodeObject:self.session forKey:kPath(self.session)];
    [aCoder encodeInteger:self.type forKey:kPath(self.type)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.identifier = [aDecoder decodeObjectForKey:kPath(self.identifier)];
        self.type = [aDecoder decodeIntegerForKey:kPath(self.type)];
        self.session = [aDecoder decodeObjectForKey:kPath(self.session)];
    }
    return self;
}

@end
