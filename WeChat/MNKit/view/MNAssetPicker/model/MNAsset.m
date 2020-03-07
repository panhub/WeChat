//
//  MNAsset.m
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAsset.h"
#import "MNAssetHelper.h"
#import <Photos/Photos.h>
#import "UIImage+MNAnimated.h"

@interface MNAsset ()
@property (nonatomic, getter=isCapturingModel) BOOL capturing;
@end

@implementation MNAsset
- (instancetype)init {
    if (self = [super init]) {
        self.requestId = INT_MIN;
        self.downloadId = INT_MIN;
        self.status = MNAssetStatusUnknown;
        self.source = MNAssetSourceUnknown;
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
    return [self assetWithContent:content renderSize:CGSizeZero];
}

+ (MNAsset *)assetWithContent:(id)content renderSize:(CGSize)renderSize {
    MNAsset *model = [MNAsset new];
    model->_enabled = YES;
    model->_content = content;
    model->_renderSize = renderSize;
    model->_source = MNAssetSourceResource;
    model->_status = MNAssetStatusCompleted;
    if ([content isKindOfClass:UIImage.class]) {
        UIImage *image = content;
        if (image.isAnimatedImage) {
            model->_type = MNAssetTypeGif;
            model->_thumbnail = [image.images.firstObject resizingToPix:MAX(renderSize.width, renderSize.height)];
        } else {
            model->_type = MNAssetTypePhoto;
            model->_thumbnail = [image resizingToPix:MAX(renderSize.width, renderSize.height)];
        }
    } else if ([content isKindOfClass:NSString.class]) {
        UIImage *thumbnail = [MNAssetExporter exportThumbnailOfVideoAtPath:content];
        thumbnail = [thumbnail resizingToPix:MAX(renderSize.width, renderSize.height)];
        model->_thumbnail = thumbnail;
        model->_type = MNAssetTypeVideo;
        model->_duration = [NSDate playTimeStringWithInterval:@([MNAssetExporter exportMediaDurationWithContentsOfPath:content])];
    } else if ([content isKindOfClass:NSClassFromString(@"PHLivePhoto")]) {
        model->_type = MNAssetTypeLivePhoto;
    }
    return model;
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

#pragma mark - dealloc
- (void)dealloc {
    self.sourceChangeHandler = nil;
    self.thumbnailChangeHandler = nil;
    self.statusChangeHandler = nil;
    self.progressChangeHandler = nil;
    [MNAssetHelper cancelThumbnailRequestWithAsset:self];
    [MNAssetHelper cancelContentRequestWithAsset:self];
}

@end



@implementation PHAsset (MNHelper)

- (CGSize)pixelSize {
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

@end
