//
//  WXNewsListController.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//  新闻列表

#import "MNListViewController.h"
@class WXNewsCategory;

NS_ASSUME_NONNULL_BEGIN

@interface WXNewsListController : MNListViewController

/**
 实例化新闻列表控制器
 */
- (instancetype)initWithFrame:(CGRect)frame category:(WXNewsCategory *)category;

@end

NS_ASSUME_NONNULL_END
