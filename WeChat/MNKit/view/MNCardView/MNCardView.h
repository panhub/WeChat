//
//  MNCardView.h
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  卡片轮播图

#import <UIKit/UIKit.h>
@class MNCardView;

UIKIT_EXTERN NSString * const MNCardItemReuseIdentifier;

/**
 卡片转换动画类型
 - MNCardViewTransitionTypeZoom: 缩放<默认>
 - MNCardViewTransitionTypeRotation: 翻转
 */
typedef NS_ENUM(NSInteger, MNCardViewTransitionType) {
    MNCardViewTransitionTypeZoom = 0,
    MNCardViewTransitionTypeRotation
};

@protocol MNCardViewDataSource <NSObject>
@optional
- (CGFloat)cardViewMinimumLineSpacing:(MNCardView *)cardView;
- (CGSize)cardViewItemSize:(MNCardView *)cardView;
- (Class)cardViewItemClass:(MNCardView *)cardView;
- (NSUInteger)numberOfCardsInView:(MNCardView *)cardView;
- (void)cardView:(MNCardView *)cardView dequeueReusableCard:(UICollectionViewCell *)card atIndexPath:(NSIndexPath *)indexPath;
@end

@protocol MNCardViewDelegate <NSObject>
@optional
- (void)cardView:(MNCardView *)cardView didSelectCardAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MNCardView : UIView

/**
 cell class
 */
@property (nonatomic) Class itemClass;
/**
 cell size
 */
@property (nonatomic) CGSize itemSize;
/**
 cell 间隔
 */
@property (nonatomic) CGFloat minimumLineSpacing;
/**
 Number Of Cell
 */
@property (nonatomic) NSUInteger numberOfCards;
/**
 初始索引
 */
@property (nonatomic) NSUInteger initializedIndex;
/**
 分页展示
 */
@property (nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;
/**
 转场类型
 */
//@property (nonatomic) MNCardViewTransitionType transitionType;
/**
 cell identifier
 */
@property (nonatomic, readonly) NSString *reuseIdentifier;
/**
 交互代理
 */
@property (nonatomic, weak) id<MNCardViewDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNCardViewDataSource> dataSource;


/**
 刷新数据
 */
- (void)reloadData;

/**
 将制定索引移动到中间位置
 @param index 制定索引
 @param animated 是否动态
 */
- (void)scrollCardToCenterOfIndex:(NSInteger)index animated:(BOOL)animated;

@end
