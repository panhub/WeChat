//
//  MNTableViewController.h
//  MNKit
//
//  Created by Vincent on 2017/6/6.
//  Copyright © 2017年 小斯. All rights reserved.
//  带有可刷新列表基类控制器

#import "MNExtendViewController.h"
#import "MNCollectionViewCell.h"
#import "MNCollectionLayout.h"

/**
 列表类型
 - MNListViewTypeTable: 表格类型
 - MNListViewTypeGrid: 瀑布流类型
 */
typedef NS_ENUM(NSInteger, MNListViewType) {
    MNListViewTypeTable = 1,
    MNListViewTypeGrid
};

@interface MNListViewController : MNExtendViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource, MNCollectionViewLayoutDataSource, UIScrollViewDelegate>
/**
 TableView
 */
@property (nonatomic, strong, readonly) UITableView *tableView;
/**
 CollectionView
 */
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
/**
 TableView,CollectionView
 */
@property (nonatomic, unsafe_unretained, readonly) UIScrollView *listView;
/**
 是否具有下拉刷新功能, default NO
 */
@property (nonatomic) BOOL pullRefreshEnabled;
/**
 是否具有加载更多功能, default NO
 */
@property (nonatomic) BOOL loadMoreEnabled;
/**
 是否在加载更多
 */
@property (nonatomic, getter=isLoadMore, readonly) BOOL loadMore;
/**
 是否在刷新
 */
@property (nonatomic, getter=isRefreshing, readonly) BOOL refreshing;
/**
 加载更多控件是否处于不可暂无更多数据状态
 */
@property (nonatomic, getter=isNeedsLoadMoreReset, readonly) BOOL needsLoadMoreReset;

/**
 结束刷新行为
 */
- (void)endRefreshing;

/**
 指定列表类型
 default MNListViewTypeTable
 @return 列表类型
 */
- (MNListViewType)listViewType;

/**
 指定表格类型
 default UITableViewStylePlain
 @return 表格类型
 */
- (UITableViewStyle)tableViewStyle;

/**
 指定瀑布流约束对象
 @return 瀑布流约束对象
 */
- (__kindof UICollectionViewLayout *)collectionViewLayout;

/**
 下拉刷新触发
 */
- (void)beginPullRefresh;

/**
 结束下拉刷新视图
 */
- (void)endPullRefresh;

/**
 删除刷新控件
 */
- (void)removeRefreshHeader;

/**
 加载更多触发
 */
- (void)beginLoadMore;

/**
 结束加载更多视图
 */
- (void)endLoadMore;

/**
 删除加载更多控件
 */
- (void)removeLoadMoreFooter;

/**
解除不能加载更多
*/
- (void)resetLoadMoreFooter;

/**
丧失加载更多能力
*/
- (void)relieveLoadMoreFooter;

/**
 定制下拉刷新控件类
 */
- (NSString *)refreshHeaderClass;

/**
 定制加载更多控件类
 */
- (NSString *)loadMoreFooterClass;

/**
 滑动列表到顶部可视部分
 @param animated 是否动态
 @return 是否操作成功
 */
- (BOOL)scrollToTopWithAnimated:(BOOL)animated;

/**
 滑动列表到底部<可视尺寸足够大时>
 @param animated 是否动态
 @return 是否操作成功
 */
- (BOOL)scrollToBottomWithAnimated:(BOOL)animated;

/**
 刷新列表数据, 不触发请求
 */
- (void)reloadList;

/**
 设置需要刷新列表flag, 视图即将出现时会检查刷新列表
 */
- (void)setNeedsReloadList;

/**
 检查刷新列表flag, 立即刷新列表
 */
- (void)reloadListIfNeeded;

/**
 根据inset调整mj控件
 */
- (void)adaptHeaderInsetBehavior;

/**
 根据inset调整mj控件
 */
- (void)adaptFooterInsetBehavior;

@end
