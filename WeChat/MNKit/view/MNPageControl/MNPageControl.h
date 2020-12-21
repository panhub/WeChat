//
//  MNPageControl.h
//  MNKit
//
//  Created by Vincent on 2019/2/10.
//  Copyright © 2019年 小斯. All rights reserved.
//  页数控制器

#import <UIKit/UIKit.h>
@class MNPageControl;

typedef NS_ENUM(NSInteger, MNPageControlDirection) {
    MNPageControlDirectionHorizontal = 0,
    MNPageControlDirectionVertical,
};

@protocol MNPageControlDataSource <NSObject>
@optional
- (NSUInteger)numberOfPagesInPageControl:(MNPageControl *)pageControl;
- (UIView *)pageControl:(MNPageControl *)pageControl cellForPageOfIndex:(NSUInteger)index;
@end

@protocol MNPageControlDelegate <NSObject>
@optional
- (void)pageControl:(MNPageControl *)pageControl didSelectPageOfIndex:(NSUInteger)index;
- (void)pageControl:(MNPageControl *)pageControl didEndLayoutCell:(UIView *)cell forPageOfIndex:(NSUInteger)index;
@end

typedef void(^MNPageControlValueChangedHandler)(MNPageControl *pageControl, NSUInteger idx);

@interface MNPageControl : UIView
/**
 交互代理
 */
@property (nonatomic, weak) id<MNPageControlDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNPageControlDataSource> dataSource;
/**
 排列方向
 */
@property (nonatomic) MNPageControlDirection direction;
/**
 总数
 */
@property (nonatomic) NSUInteger numberOfPages;
/**
 当前页数
 */
@property (nonatomic) NSUInteger currentPageIndex;
/**
 页码控件大小
 */
@property (nonatomic) CGSize pageSize;
/**
 页码控件偏移
 */
@property (nonatomic) UIOffset pageOffset;
/**
 页码间隔
 */
@property (nonatomic) CGFloat pageInterval;
/**
 页码Touch事件触发Inset
 */
@property (nonatomic) UIEdgeInsets pageTouchInset;
/**
 页码颜色
 */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
/**
 当前页码颜色
 */
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
/**
 是否在选择中
*/
@property (nonatomic, getter=isSelected, readonly) BOOL selected;

/**
 页码控件位置
 @param pageIndex 页码索引
 @return 位置
 */
- (CGRect)cellRectForPageOfIndex:(NSUInteger)pageIndex;

/**
 获取指定索引的PageCell
 @param pageIndex 指定索引
 @return 指定PageCell
 */
- (UIView *)cellForPageOfIndex:(NSUInteger)pageIndex;

/**
 立即更新控件
 */
- (void)reloadData;


/**
 实例化入口
 @param frame 位置
 @param handler 变化回调
 @return PageControl实例
 */
+ (instancetype)pageControlWithFrame:(CGRect)frame handler:(MNPageControlValueChangedHandler)handler;

@end
