//
//  MNLinkPageController.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLinkViewController.h"
#import "MNLinkPageProtocol.h"

@interface MNLinkPageController : MNLinkViewController

/**数据源代理*/
@property (nonatomic, weak)  id<MNLinkPageDataSource> dataSource;
/**交互代理*/
@property (nonatomic, weak)  id<MNLinkPageDelegate> delegate;
/**开启/禁用交互滑动*/
@property (nonatomic) BOOL scrollEnabled;

/**
 更新内容视图大小
 */
- (void)updateContentIfNeed;

/**
 更新当前子界面索引
 @param pageIndex 指定索引
 */
- (void)updateCurrentPageIndex:(NSUInteger)pageIndex;

/**
 刷新上次子界面索引
 */
- (void)reloadLastPageIndex;

/**
 展示当前子界面
 */
- (void)displayCurrentPageIfNeed;

/**
 外界非交互式切换Page
 @param index 指定索引
 @param animated 是否动画
 */
- (void)scrollPageToIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 重载
 */
- (void)reloadData;

/**
 清除缓存
 */
- (void)cleanCache;

@end



@interface UIViewController (MNLinkPage)

@property (nonatomic) NSUInteger pageIndex;

@end


