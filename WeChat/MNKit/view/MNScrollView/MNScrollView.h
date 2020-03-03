//
//  MNScrollView.h
//  MNKit
//
//  Created by Vincent on 2019/2/10.
//  Copyright © 2019年 小斯. All rights reserved.
//  PageScrollView

#import <UIKit/UIKit.h>
//direction
typedef NS_ENUM(NSInteger, MNScrollViewDirection) {
    MNScrollViewDirectionHorizontal = 0,
    MNScrollViewDirectionVertical
};
@interface MNScrollView : UIScrollView

/**
 滑动方向
 */
@property (nonatomic) MNScrollViewDirection scrollDirection;

/**
 总页数
 */
@property (nonatomic) NSUInteger numberOfPages;

/**
 当前界面索引
 */
@property (nonatomic, readonly) NSUInteger currentPageIndex;

/**
 更新内容尺寸
 @param numberOfPages 总页数
 */
- (void)updateContentWithNumberOfPages:(NSUInteger)numberOfPages;

/**
 更新偏移到指定索引
 @param pageIndex 索引
 @param animated 是否动态
 */
- (void)updateOffsetWithPageIndex:(NSUInteger)pageIndex animated:(BOOL)animated;

/**
 页面偏移量
 @param pageIndex 界面索引
 @return 偏移量
 */
- (CGPoint)contentOffsetOfPageIndex:(NSUInteger)pageIndex;


@end
