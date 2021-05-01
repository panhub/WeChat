//
//  WXMomentLikedViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  点赞视图模型

#import "WXMomentEventViewModel.h"
#import "WXMoment.h"

@interface WXMomentLikedViewModel : WXMomentEventViewModel

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

@end
