//
//  WXMyMomentHeaderView.h
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈表头

#import "MNAdsorbView.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyMomentHeaderView : MNAdsorbView
/**
 视图标记
 */
@property (nonatomic) CGFloat offsetY;
/**
 指定用户
 */
@property (nonatomic, strong) WXUser *user;

@end

NS_ASSUME_NONNULL_END
