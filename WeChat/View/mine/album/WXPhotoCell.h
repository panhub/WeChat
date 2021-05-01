//
//  WXPhotoCell.h
//  WeChat
//
//  Created by Vicent on 2021/4/22.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册-朋友圈

#import "MNCollectionViewCell.h"
@class WXProfile, MNAssetScrollView;

NS_ASSUME_NONNULL_BEGIN

@interface WXPhotoCell : MNCollectionViewCell

/**图片浏览*/
@property (nonatomic, strong, readonly) MNAssetScrollView *scrollView;

/**图片模型*/
@property (nonatomic, strong) WXProfile *picture;

/**外界结束展示*/
- (void)endDisplaying;

/**开始展示*/
- (void)didBeginDisplaying;

/**结束展示*/
- (void)didEndDisplaying;

@end

NS_ASSUME_NONNULL_END
