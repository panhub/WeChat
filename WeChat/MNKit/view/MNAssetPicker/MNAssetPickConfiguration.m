//
//  MNAssetPickConfiguration.m
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetPickConfiguration.h"

@implementation MNAssetPickConfiguration
- (instancetype)init {
    if (self = [super init]) {
        self.maxExportPixel = 0;
        self.maxExportQuality = 0.f;
        self.minPickingCount = 1;
        self.maxPickingCount = 1;
        self.allowsEditing = NO;
        self.allowsCapturing = NO;
        self.allowsWritToAlbum = YES;
        self.allowsPreviewing = NO;
        self.allowsPickingGif = NO;
        self.allowsPickingVideo = NO;
        self.allowsPickingPhoto = YES;
        self.allowsPickingLivePhoto = NO;
        self.allowsAutoDismiss = YES;
        self.allowsMixPicking = YES;
        self.allowsGlidePicking = YES;
        self.allowsPickingAlbum = YES;
        self.showPickingNumber = YES;
        self.allowsDisplayFileSize = NO;
        self.allowsOriginalExporting = NO;
        self.allowsResizeVideoSize = YES;
        self.allowsExportHEIF = YES;
        self.sortAscending = YES;
        self.showEmptyAlbum = NO;
        self.numberOfColumns = 3;
        self.maxCaptureDuration = 60.f;
        self.minExportDuration = 1.f;
        self.renderSize = CGSizeMake(350.f, 350.f);
    }
    return self;
}

#pragma mark - Setter
- (void)setMaxPickingCount:(NSUInteger)maxPickingCount {
    _maxPickingCount = MAX(1, maxPickingCount);
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns {
    _numberOfColumns = MAX(2, numberOfColumns);
}

- (void)setCropScale:(CGFloat)cropScale {
    _cropScale = MIN(MAX(0.f, cropScale), 1.f);
}

- (void)setMinExportDuration:(NSTimeInterval)minExportDuration {
    _minExportDuration = MAX(1.f, minExportDuration);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

@end
