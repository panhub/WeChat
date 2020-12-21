//
//  WXMomentLikedViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  点赞视图模型

#import "WXMomentItemViewModel.h"
#import "WXMoment.h"

@interface WXMomentLikedViewModel : WXMomentItemViewModel

/**
 记录数据模型
 */
@property (nonatomic, readonly, strong) WXMoment *moment;

/**
 实例化
 @param moment 朋友圈模型
 @return 点赞视图模型
 */
- (instancetype)initWithMoment:(WXMoment *)moment;

/**
 更新内容
 */
- (void)updateContent;

@end
