//
//  MNSegmentController.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
// 

#import "MNSegmentBaseController.h"
#import "MNSegmentConfiguration.h"
#import "MNSegmentSubpageProtocol.h"
#import "MNSegmentControllerProtocol.h"

@interface MNSegmentController : MNSegmentBaseController
/**开启/禁用交互滑动<默认与重载YES>*/
@property (nonatomic) BOOL scrollEnabled;
/**外界控制是否允许选择<默认与重载YES>*/
@property (nonatomic) BOOL selectEnabled;
/**表头滑动, 预留高度*/
@property (nonatomic) CGFloat fixedHeight;
/**代表偏移量*/
@property (nonatomic) CGPoint contentOffset;
/**刷新时, 是否刷新头视图, 默认NO*/
@property (nonatomic) BOOL reloadHeaderIfNeed;
/**加载头视图与分段选择视图*/
@property (nonatomic, readonly, strong) UIView *profileView;
/**公共头视图, 外部提供*/
@property (nonatomic, readonly, strong) UIView *headerView;
/**分段选择视图*/
@property (nonatomic, readonly, strong) UIView *segmentView;
/**解决与导航的手势冲突*/
@property (nonatomic, weak) UIGestureRecognizer *failToGestureRecognizer;
/**交互代理*/
@property (nonatomic, weak) id<MNSegmentControllerDelegate> delegate;
/**数据源代理*/
@property (nonatomic, weak) id<MNSegmentControllerDataSource> dataSource;
/**分段视图配置*/
@property (nonatomic, readonly, strong) MNSegmentConfiguration *configuration;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**重载*/
- (void)reloadData;

/**
 滚动到指定界面
 @param pageIndex 指定索引
 */
- (void)scrollPageToIndex:(NSUInteger)pageIndex;

/**
 外界获取指定界面(只取缓存, 不会触发创建)
 @param index 指定索引
 @return 子界面
 */
- (UIViewController <MNSegmentSubpageDataSource>*)pageCacheOfIndex:(NSUInteger)index;

@end

