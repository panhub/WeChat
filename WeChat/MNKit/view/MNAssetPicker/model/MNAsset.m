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

@interface MNAsset ()
@property (nonatomic, getter=isCapturingModel) BOOL capturing;
@end

@implementation MNAsset
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
    if ([content isKindOfClass:UIImage.class]) {
        UIImage *image = content;
        if (image.images.count) {
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

- (void)setState:(MNAssetState)state {
    _state = state;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.stateChangeHandler) {
            self.stateChangeHandler(self);
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
- (void)changeState:(MNAssetState)state {
    if (state == _state) return;
    [self willChangeValueForKey:@"state"];
    self->_state = state;
    [self didChangeValueForKey:@"state"];
}

- (void)changeSource:(MNAssetSourceType)source {
    if (source == _source) return;
    [self willChangeValueForKey:@"source"];
    self->_source = source;
    [self didChangeValueForKey:@"source"];
}

- (void)changeProgress:(double)progress {
    if (progress == _progress) return;
    [self willChangeValueForKey:@"progress"];
    self->_progress = progress;
    [self didChangeValueForKey:@"progress"];
}

- (void)changeThumbnail:(UIImage *)thumbnail {
    [self willChangeValueForKey:@"thumbnail"];
    self->_thumbnail = thumbnail;
    [self didChangeValueForKey:@"thumbnail"];
}

#pragma mark - dealloc
- (void)dealloc {
    self.sourceChangeHandler = nil;
    self.thumbnailChangeHandler = nil;
    self.stateChangeHandler = nil;
    self.progressChangeHandler = nil;
    [MNAssetHelper cancelThumbnailRequestWithAsset:self];
    [MNAssetHelper cancelContentRequestWithAsset:self];
}

@end