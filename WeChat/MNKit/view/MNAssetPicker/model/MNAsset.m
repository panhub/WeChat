//
//  MNAsset.m
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAsset.h"
#import "MNAssetHelper.h"
#import "NSDate+MNHelper.h"
#import "UIImage+MNAnimated.h"
#import "MNAssetPickConfiguration.h"
#import "PHAsset+MNAssetResource.h"
#import "MNAssetExporter+MNExportMetadata.h"

#if __has_include(<Photos/Photos.h>)
#import <Photos/Photos.h>
#endif

@interface MNAsset ()
@property (nonatomic, getter=isCapturingModel) BOOL capturing;
@end

@implementation MNAsset
- (instancetype)init {
    if (self = [super init]) {
#if __has_include(<Photos/Photos.h>)
        self.requestId = PHInvalidImageRequestID;
        self.downloadId = PHInvalidImageRequestID;
#else
        self.requestId = 0;
        self.downloadId = 0;
#endif
        self->_fileSizeString = @"";
        self->_status = MNAssetStatusUnknown;
        self->_source = MNAssetSourceUnknown;
    }
    return self;
}

+ (MNAsset *)capturingModel {
    MNAsset *model = [MNAsset new];
    model->_capturing = YES;
    model->_enabled = YES;
    model->_source = MNAssetSourceResource;
    model->_thumbnail = [MNBundle imageForResource:@"icon_takepicHL"];
    return model;
}

+ (MNAsset *)assetWithContent:(id)content {
    return [self assetWithContent:content configuration:nil];
}

+ (MNAsset *)assetWithContent:(id)content configuration:(MNAssetPickConfiguration *)configuration {
    if (!content) return nil;
    MNAsset *model = [MNAsset new];
    model->_enabled = YES;
    model->_content = content;
    model->_source = MNAssetSourceResource;
    model->_status = MNAssetStatusCompleted;
    if (configuration) model->_renderSize = configuration.renderSize;
    if ([content isKindOfClass:UIImage.class]) {
        UIImage *image = content;
        if (image.isAnimatedImage) {
            model->_type = MNAssetTypeGif;
            model->_thumbnail = [image.images.firstObject resizingToMaxPix:MAX(model.renderSize.width, model.renderSize.height)];
            if (configuration) {
                if (configuration.maxExportPixel > 0) {
                    image = [image resizingToMaxPix:configuration.maxExportPixel];
                }
                if (configuration.maxExportQuality > 0.f) {
                    image = [image resizingToQuality:configuration.maxExportQuality];
                }
                if (!image) return nil;
                model->_content = image;
            }
        } else {
            model->_type = MNAssetTypePhoto;
            model->_thumbnail = [image resizingToMaxPix:MAX(model.renderSize.width, model.renderSize.height)];
        }
        if (configuration && configuration.isAllowsDisplayFileSize) {
            NSData *imageData = [NSData dataWithImage:image];
            model->_fileSize = imageData ? imageData.length : 0;
        }
    } else if ([content isKindOfClass:NSString.class]) {
        UIImage *thumbnail = [MNAssetExporter exportThumbnailOfVideoAtPath:content atSeconds:.1f maximumSize:model.renderSize];
        model->_thumbnail = thumbnail;
        model->_type = MNAssetTypeVideo;
        model->_duration = [MNAssetExporter exportDurationWithMediaAtPath:content];
        model->_durationString = [NSDate timeStringWithInterval:@([MNAssetExporter exportDurationWithMediaAtPath:content])];
        if (configuration && configuration.isAllowsDisplayFileSize) {
            NSNumber *videoSize;
            NSURL *videoURL = [NSURL fileURLWithPath:content];
            [videoURL getResourceValue:&videoSize forKey:NSURLFileSizeKey error:nil];
            model->_fileSize = videoSize ? videoSize.longLongValue : 0;
        }
    } else if ([content isKindOfClass:NSClassFromString(@"PHLivePhoto")]) {
        model->_type = MNAssetTypeLivePhoto;
#if __has_include(<Photos/PHLivePhoto.h>)
        if (@available(iOS 9.1, *)) {
            NSURL *videoURL = [content valueForKey:@"videoURL"];
            NSURL *imageURL = [content valueForKey:@"imageURL"];
            if (!imageURL || !videoURL) return nil;
            model->_thumbnail = [[UIImage imageWithContentsOfFile:imageURL.path] resizingToMaxPix:MAX(model.renderSize.width, model.renderSize.height)];
            if (model->_thumbnail == nil) return nil;
            if (configuration && configuration.isAllowsDisplayFileSize) {
                NSArray<PHAssetResource *>*resources = [PHAssetResource assetResourcesForLivePhoto:model.content];
                long long fileSize = 0;
                for (PHAssetResource *resource in resources) {
                    id obj = [resource valueForKey:@"fileSize"];
                    if (obj) fileSize += [obj longLongValue];
                }
                model->_fileSize = fileSize;
            }
        }
#endif
    }
    model->_fileSizeString = model.fileSizeStringValue;
    return model;
}

- (void)cancelRequest {
    [MNAssetHelper cancelAssetRequest:self];
}

- (void)cancelDownload {
    [MNAssetHelper cancelAssetDownload:self];
}

#pragma mark - Setter
- (void)setSelected:(BOOL)selected {
    if (self.isCapturingModel) return;
    _selected = selected;
    if (!selected) self.selectIndex = 0;
}

- (void)setEnabled:(BOOL)enabled {
    if (self.isCapturingModel) return;
    _enabled = enabled;
}

- (void)setSource:(MNAssetSourceType)source {
    _source = source;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sourceChangeHandler) {
            self.sourceChangeHandler(self);
        }
    });
}

- (void)setThumbnail:(UIImage *)thumbnail {
    _thumbnail = thumbnail;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.thumbnailChangeHandler) {
            self.thumbnailChangeHandler(self);
        }
    });
}

- (void)setStatus:(MNAssetStatus)status {
    _status = status;
    if (status == MNAssetStatusFailed) self->_progress = 0.f;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.statusChangeHandler) {
            self.statusChangeHandler(self);
        }
    });
}

- (void)setProgress:(double)progress {
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressChangeHandler) {
            self.progressChangeHandler(self);
        }
    });
}

- (void)setFileSize:(long long)fileSize {
    _fileSize = fileSize;
    self->_fileSizeString = self.fileSizeStringValue;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fileSizeChangeHandler) {
            self.fileSizeChangeHandler(self);
        }
    });
}

#pragma mark - Change
- (void)updateStatus:(MNAssetStatus)status {
    if (status == _status) return;
    [self willChangeValueForKey:@"status"];
    self->_status = status;
    [self didChangeValueForKey:@"status"];
}

- (void)updateSource:(MNAssetSourceType)source {
    if (source == _source) return;
    [self willChangeValueForKey:@"source"];
    self->_source = source;
    [self didChangeValueForKey:@"source"];
}

- (void)updateProgress:(double)progress {
    if (progress == _progress) return;
    [self willChangeValueForKey:@"progress"];
    self->_progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (void)updateThumbnail:(UIImage *)thumbnail {
    [self willChangeValueForKey:@"thumbnail"];
    self->_thumbnail = thumbnail;
    [self didChangeValueForKey:@"thumbnail"];
}

- (void)updateFileSize:(long long)fileSize {
    [self willChangeValueForKey:@"fileSize"];
    self->_fileSize = fileSize;
    self->_fileSizeString = self.fileSizeStringValue;
    [self didChangeValueForKey:@"fileSize"];
}

#pragma mark - Getter
- (NSString *)fileSizeStringValue {
    NSString *fileSize;
    long long dataLength = self.fileSize;
    if (dataLength >= 1024*1024/10) {
        fileSize = [NSString stringWithFormat:@"%.1fM",(double)dataLength/1024.f/1024.f];
    } else if (dataLength >= 1024) {
        fileSize = [NSString stringWithFormat:@"%.0fK",(double)dataLength/1024.f];
    } else {
        fileSize = [NSString stringWithFormat:@"%lldB", dataLength];
    }
    return fileSize;
}

#pragma mark - dealloc
- (void)dealloc {
    self.content = nil;
    self.sourceChangeHandler = nil;
    self.thumbnailChangeHandler = nil;
    self.statusChangeHandler = nil;
    self.progressChangeHandler = nil;
    self.fileSizeChangeHandler = nil;
    [self cancelRequest];
    [self cancelDownload];
}

@end
