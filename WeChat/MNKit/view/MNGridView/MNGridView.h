//
//  MNGridView.h
//  MNKit
//
//  Created by Vincent on 2018/11/9.
//  Copyright © 2018年 小斯. All rights reserved.
//  热词布局视图

#import <UIKit/UIKit.h>
@class MNGridView;

typedef NS_ENUM(NSInteger, MNGridAlignment) {
    MNGridAlignmentLeft = 0,
    MNGridAlignmentCenter,
    MNGridAlignmentRight
};

@protocol MNGridViewDataSource <NSObject>
@required
- (NSInteger)gridView:(MNGridView *)gridView numberOfItemsInSection:(NSInteger)section;
- (UIView *)gridView:(MNGridView *)gridView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInGridView:(MNGridView *)gridView;
- (UIView *)gridView:(MNGridView *)gridView viewForHeaderInSection:(NSInteger)section;
- (UIView *)gridView:(MNGridView *)gridView viewForFooterInSection:(NSInteger)section;
- (UIEdgeInsets)gridView:(MNGridView *)gridView contentInsetForSection:(NSInteger)section;
@end

@protocol MNGridViewDelegate <UIScrollViewDelegate>
@optional
@end

@interface MNGridView : UIScrollView
/**
 区边界
 */
@property (nonatomic) UIEdgeInsets sectionInset;
/**
 cell纵向间隔
 */
@property (nonatomic) CGFloat minimumLineSpacing;
/**
 cell横向间隔
 */
@property (nonatomic) CGFloat minimumInterItemSpacing;
/**
 按钮的对齐方式
 */
@property (nonatomic) MNGridAlignment contentAlignment;
/**
 交互代理
 */
@property (nonatomic, weak) id<MNGridViewDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNGridViewDataSource> dataSource;

/**
 刷新数据
 */
- (void)reloadData;

/**
 获取指定索引视图
 @param indexPath 索引
 @return 视图
 */
- (UIView *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 获取区头视图
 @param section 指定区
 @return 区视图
 */
- (UIView *)headerViewForSection:(NSInteger)section;

/**
 获取指定区尾视图
 @param section 指定区
 @return 区尾视图
 */
- (UIView *)footerViewForSection:(NSInteger)section;

@end

