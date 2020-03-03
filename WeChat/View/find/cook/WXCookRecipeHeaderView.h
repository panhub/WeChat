//
//  WXCookRecipeHeaderView.h
//  MNChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜品图

#import "MNAdsorbView.h"
@class WXCookRecipe;

@interface WXCookRecipeHeaderView : MNAdsorbView

@property (nonatomic, copy) void (^didLoadHandler) (UIView *view);

+ (instancetype)headerWithRecipeModel:(WXCookRecipe *)model;

@end
