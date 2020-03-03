//
//  WXCookRecipeBriefView.h
//  MNChat
//
//  Created by Vincent on 2019/6/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜品简介

#import <UIKit/UIKit.h>
@class WXCookRecipe;

NS_ASSUME_NONNULL_BEGIN

@interface WXCookRecipeBriefView : UIView

+ (instancetype)viewWithRecipeModel:(WXCookRecipe *)model;

@end

NS_ASSUME_NONNULL_END
