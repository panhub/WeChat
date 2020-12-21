//
//  MNLinkTableControllerProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  控制器协议

#import <Foundation/Foundation.h>
@class MNLinkTableController;
@class MNLinkTableConfiguration;

@protocol MNLinkTableControllerDataSource <NSObject>
@required
/**
 左侧标题数组
 @return 标题数组<NSString NSAttributedString>
 */
- (NSArray <id>*)linkTableControllerTitles;
/**
 子控制器实例
 @param pageIndex 子界面索引
 @param frame 子界面大小
 @return 子控制器
 */
- (UIViewController *)linkTableControllerPageOfIndex:(NSUInteger)pageIndex frame:(CGRect)frame;

@optional

/**
 默认展示的子界面索引
 @return 索引
 */
- (NSUInteger)linkTableControllerPageIndexOfInitialized;

/**
 配置信息初始化
 @param configuration 配置信息
 */
- (void)linkTableControllerInitializedConfiguration:(MNLinkTableConfiguration *)configuration;

@end

@protocol MNLinkTableControllerDelegate <NSObject>
@optional

/**
 即将离开界面到下一界面
 @param linkController linkTableController
 @param fromPageIndex 即将离开的界面索引
 @param toPageIndex 就要出现的界面索引
 */
- (void)linkTableController:(MNLinkTableController*)linkController
                willLeavePageOfIndex:(NSUInteger)fromPageIndex
                    toPageOfIndex:(NSUInteger)toPageIndex;

/**
 已经离开界面到某界面

 @param linkController linkTableController
 @param fromPageIndex 已经离开的界面索引
 @param toPageIndex 已经出现的界面索引
 */
- (void)linkTableController:(MNLinkTableController*)linkController
                didLeavePageOfIndex:(NSUInteger)fromPageIndex
                    toPageOfIndex:(NSUInteger)toPageIndex;

/**
 即将重载
 @param linkController linkTableController
 */
- (void)linkTableControllerWillReloadData:(MNLinkTableController *)linkController;

/**
 已经重载
 @param linkController linkTableController
 */
- (void)linkTableControllerDidReloadData:(MNLinkTableController *)linkController;

@end

