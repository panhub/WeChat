//
//  MNLinkViewControllerProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  控制器协议部分, @required 必须实现

#import <Foundation/Foundation.h>
@class MNLinkViewController;
@class MNLinkTableConfiguration;

@protocol MNLinkViewControllerDataSource <NSObject>
@required
/**
 左侧标题数组
 @return 标题数组
 */
- (NSArray <NSString *>*)linkViewControllerTableTitles;
/**
 子控制器实例
 @param pageIndex 子界面索引
 @param frame 子界面大小
 @return 子控制器
 */
- (UIViewController *)linkViewControllerPageOfIndex:(NSUInteger)pageIndex frame:(CGRect)frame;

@optional

/**
 默认展示的子界面索引
 @return 索引
 */
- (NSUInteger)linkViewControllerPageIndexOfInitialized;

/**
 配置信息初始化
 @param configuration 配置信息
 */
- (void)linkViewControllerInitializedConfiguration:(MNLinkTableConfiguration *)configuration;

@end

@protocol MNLinkViewControllerDelegate <NSObject>
@optional

/**
 即将离开界面到下一界面
 @param linkController linkViewController
 @param fromPageIndex 即将离开的界面索引
 @param toPageIndex 就要出现的界面索引
 */
- (void)linkViewController:(MNLinkViewController*)linkController
                willLeavePageOfIndex:(NSUInteger)fromPageIndex
                    toPageOfIndex:(NSUInteger)toPageIndex;

/**
 已经离开界面到某界面

 @param linkController linkViewController
 @param fromPageIndex 已经离开的界面索引
 @param toPageIndex 已经出现的界面索引
 */
- (void)linkViewController:(MNLinkViewController*)linkController
                didLeavePageOfIndex:(NSUInteger)fromPageIndex
                    toPageOfIndex:(NSUInteger)toPageIndex;

/**
 即将重载
 @param linkController linkViewController
 */
- (void)linkViewControllerWillReloadData:(MNLinkViewController *)linkController;

/**
 已经重载
 @param linkController linkViewController
 */
- (void)linkViewControllerDidReloadData:(MNLinkViewController *)linkController;

@end

