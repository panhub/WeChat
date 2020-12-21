//
//  MNAssetBrowseCell.h
//  MNKit
//
//  Created by Vincent on 2019/9/7.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  资源浏览器Cell

#import "MNCollectionViewCell.h"
#import "MNAssetScrollView.h"
@class MNAsset, MNAssetBrowseCell;

/**
 浏览状态
 - MNAssetBrowseStateNormal 初始状态
 - MNAssetBrowseStateThumbnailLoading 截图加载中
 - MNAssetBrowseStateContentLoading 内容加载中
 - MNAssetBrowseStatePreviewing 预览中
 */
typedef NS_ENUM(NSInteger, MNAssetBrowseState) {
    MNAssetBrowseStateNormal = 0,
    MNAssetBrowseStateThumbnailLoading = 1,
    MNAssetBrowseStateContentLoading = 1,
    MNAssetBrowseStatePreviewing
};

/**计算图片尺寸*/
UIKIT_EXTERN CGSize MNImageAssetAspectInSize(UIImage *_Nonnull, CGSize);

NS_ASSUME_NONNULL_BEGIN

@protocol MNAssetBrowseCellDelegate <NSObject>
@optional;
- (BOOL)assetBrowseCellShouldAutoPlaying:(MNAssetBrowseCell *)cell;
@end

@interface MNAssetBrowseCell : MNCollectionViewCell
/**资源*/
@property (nonatomic, strong) MNAsset *asset;
/**状态*/
@property (nonatomic) MNAssetBrowseState state;
/**内容滚动*/
@property (nonatomic, readonly, strong) MNAssetScrollView *scrollView;
/**事件代理*/
@property (nonatomic, weak) id<MNAssetBrowseCellDelegate> delegate;

/**当前图像*/
- (UIImageView *)currentImageView;

/**当前图像*/
- (UIImage *)currentImage;

/**结束展示*/
- (void)endDisplaying;

/**设置播放控制是否可见*/
- (void)setPlayToolBarVisible:(BOOL)isVisible animated:(BOOL)animated;

@end
NS_ASSUME_NONNULL_END
