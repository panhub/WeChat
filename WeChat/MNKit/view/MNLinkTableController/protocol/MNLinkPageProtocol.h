//
//  MNLinkPageProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  此协议由内部处理, 外部不必理会

#import <Foundation/Foundation.h>
@class MNLinkPageController;

@protocol MNLinkPageDataSource <NSObject>
@required
/**总页数默认获取TableView总行数*/
@property (nonatomic, readonly) NSInteger numberOfPages;
/**
 子界面实例
 @param pageIndex 子界面索引
 @return 子界面
 */
- (UIViewController *)pageOfIndex:(NSUInteger)pageIndex;
@end


@protocol MNLinkPageDelegate <NSObject>
@optional

/**
 即将离开界面到下一界面
 @param pageController pageViewController
 @param fromPage 即将离开的界面
 @param toPage 即将出现的界面
 */
- (void)linkPageController:(MNLinkPageController *)pageController
             willLeavePage:(UIViewController *)fromPage
                    toPage:(UIViewController *)toPage;

/**
 已经离开界面到下一界面
 @param pageController pageViewController
 @param fromPage 已经离开的界面
 @param toPage 已经出现的界面
 */
- (void)linkPageController:(MNLinkPageController *)pageController
              didLeavePage:(UIViewController *)fromPage
                    toPage:(UIViewController *)toPage;


/**
 界面滑动偏移比率
 @param ratio 偏移量/页高
 @param dragging 是否拖拽中
 */
- (void)linkPageDidScrollWithOffsetRatio:(CGFloat)ratio dragging:(BOOL)dragging;

@end
