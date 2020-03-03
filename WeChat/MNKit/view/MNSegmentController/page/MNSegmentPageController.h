//
//  MNSegmentPageController.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentBaseController.h"
#import "MNSegmentPageProtocol.h"
#import "MNSegmentSubpageProtocol.h"

@interface MNSegmentPageController : MNSegmentBaseController

/**外界控制是否允许滑动<默认与重载YES>*/
@property (nonatomic) BOOL scrollEnabled;
/**解决与导航的手势冲突*/
@property (nonatomic) UIGestureRecognizer *failToGestureRecognizer;
/**数据源代理*/
@property (nonatomic, weak)  id<MNSegmentPageDataSource> dataSource;
/**交互代理*/
@property (nonatomic, weak)  id<MNSegmentPageDelegate> delegate;

/**
 刷新当前页面索引
 @param pageIndex 指定索引
 */
- (void)updateCurrentPageIndex:(NSInteger)pageIndex;

/**
 刷新上一页面索引
 */
- (void)reloadLastPageIndex;

/**
 更新内容视图大小
 */
- (void)updateContentIfNeed;

/**
 展示当前子页面
 */
- (void)displayCurrentPageIfNeed;

/**非交互切换page*/
- (void)scrollPageToIndex:(NSInteger)index animated:(BOOL)animated;

/**清空缓存*/
- (void)cleanCache;

/**重载page*/
- (void)reloadData;

/**外界获取子界面*/
- (UIViewController <MNSegmentSubpageDataSource>*)pageCacheOfIndex:(NSUInteger)index;

@end
