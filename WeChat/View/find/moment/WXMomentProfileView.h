//
//  WXMomentProfileView.h
//  MNChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈头视图

#import "MNAdsorbView.h"
@class WXMomentProfileViewModel;

@interface WXMomentProfileView : MNAdsorbView
/**
 视图标记
 */
@property (nonatomic) CGFloat offsetY;
/**
 绑定朋友圈视图模型
 @param viewModel 朋友圈视图模型
 */
- (void)bindViewModel:(WXMomentProfileViewModel *)viewModel;
/**
 更新用户数据
 */
- (void)updateUserInfo;

@end
