//
//  MNAssetBrowseCell.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/7.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  资源浏览器Cell

#import "MNCollectionViewCell.h"
#import "MNAssetScrollView.h"
@class MNAsset, MNAssetBrowseCell;

typedef NS_ENUM(NSInteger, MNAssetBrowseState) {
    MNAssetBrowseStateNormal = 0,
    MNAssetBrowseStateThumbnailLoading = 1,
    MNAssetBrowseStateContentLoading = 1,
    MNAssetBrowseStatePreviewing
};

@protocol MNAssetBrowseCellDelegate <NSObject>
@optional;
- (BOOL)assetBrowseCellShouldAutoPlaying:(MNAssetBrowseCell *)cell;
@end

@interface MNAssetBrowseCell : MNCollectionViewCell

@property (nonatomic, strong) MNAsset *asset;

@property (nonatomic) MNAssetBrowseState state;

@property (nonatomic, readonly, strong) MNAssetScrollView *scrollView;

- (UIImageView *)foregroundImageView;

- (void)endDisplaying;

+ (CGSize)displaySizeWithImage:(UIImage *)image inView:(UIView *)view;

@end
