//
//  WXNewLabelController.h
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  新建标签

#import "MNListViewController.h"
@class WXLabel;

NS_ASSUME_NONNULL_BEGIN

@interface WXNewLabelController : MNListViewController

/**编辑标签实例化*/
- (instancetype)initWithLabel:(WXLabel *_Nullable)label;

@end

NS_ASSUME_NONNULL_END
