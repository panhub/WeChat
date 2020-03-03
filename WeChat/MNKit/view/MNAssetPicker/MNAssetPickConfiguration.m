//
//  MNAssetPickConfiguration.m
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetPickConfiguration.h"

@implementation MNAssetPickConfiguration
- (instancetype)init {
    if (self = [super init]) {
        self.exportPixel = 0.f;
        self.minPickingCount = 0;
        self.maxPickingCount = 1;
        self.allowsEditing = YES;
        self.allowsCapturing = YES;
        self.allowsWritToAlbum = YES;
        self.allowsPreviewing = YES;
        self.allowsPickingGif = NO;
        self.allowsPickingVideo = NO;
        self.allowsPickingPhoto = YES;
        self.allowsPickingLivePhoto = NO;
        self.allowsAutoDismiss = YES;
        self.allowsMixPicking = YES;
        self.allowsPickingAlbum = YES;
        self.showPickingNumber = YES;
        self.sortAscending = YES;
        self.showEmptyAlbum = NO;
        self.numberOfColumns = 3;
        self.maxCaptureDuration = 60.f;
        self.renderSize = CGSizeMake(350.f, 350.f);
    }
    return self;
}

#pragma mark - Setter
- (void)setMaxPickingCount:(NSUInteger)maxPickingCount {
    maxPickingCount = MAX(1, maxPickingCount);
    _maxPickingCount = maxPickingCount;
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns {
    numberOfColumns = MAX(2, numberOfColumns);
    _numberOfColumns = numberOfColumns;
}

- (void)setCropScale:(CGFloat)cropScale {
    cropScale = MIN(MAX(0.f, cropScale), 1.f);
    _cropScale = cropScale;
}

@end
