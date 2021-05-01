//
//  WXFavoriteViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//  收藏视图模型总继承

#import <Foundation/Foundation.h>
#import "WXExtendViewModel.h"
#import "WXFavorite.h"
#import "WXFavorites.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXFavoriteViewModel : NSObject
/**
 可视区域
 */
@property (nonatomic, readonly) CGRect frame;
/**
 收藏数据模型
 */
@property (nonatomic, strong) WXFavorite *favorite;
/**
 标记视图
 */
@property (nonatomic, weak) UIView *containerView;
/**
 时间视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *timeViewModel;
/**
 来源视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *sourceViewModel;
/**
 标签视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *labelViewModel;
/**
 标题视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *titleViewModel;
/**
 副标题视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *subtitleViewModel;
/**
 图片视图模型
 */
@property (nonatomic, strong, readonly) WXExtendViewModel *imageViewModel;
/**
 图片点击事件
 */
@property (nonatomic, copy) void (^imageViewClickedHandler) (WXFavoriteViewModel *viewModel);
/**
 背景长按事件
 */
@property (nonatomic, copy) void (^backgroundLongPressHandler) (WXFavoriteViewModel *viewModel);

/**
 唯一实例化入口
 @param favorite 收藏模型
 @return 收藏视图模型
 */
+ (instancetype)viewModelWithFavorite:(WXFavorite *)favorite;

/**
 约束控件
 */
- (void)layoutSubviews MNKIT_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
