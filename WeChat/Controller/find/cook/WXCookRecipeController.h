//
//  WXCookRecipeController.h
//  WeChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  制作过程

#import "MNListViewController.h"
@class WXCookRecipe;

NS_ASSUME_NONNULL_BEGIN

@interface WXCookRecipeController : MNListViewController

- (instancetype)initWithRecipeModel:(WXCookRecipe *)model;

@end

NS_ASSUME_NONNULL_END
