//
//  MNLinkTableController.h
//  MNKit
//
//  Created by Vincent on 2018/12/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLinkViewController.h"
#import "MNLinkTableConfiguration.h"
#import "MNLinkTableControllerProtocol.h"
#import "MNLinkSubpageProtocol.h"

@interface MNLinkTableController : MNLinkViewController
/**
 交互代理
 */
@property (nonatomic, weak) id<MNLinkTableControllerDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNLinkTableControllerDataSource> dataSource;
/**
 视图配置
 */
@property (nonatomic, strong, readonly) MNLinkTableConfiguration *configuration;
/**
 当前选择索引
 */
@property (nonatomic, readonly) NSUInteger selectedIndex;
/**
 上一次选择索引
 */
@property (nonatomic, readonly) NSUInteger lastSelectedIndex;
/**
 开启/禁用交互滑动
 */
@property (nonatomic) BOOL scrollEnabled;
/**
 外界控制是否允许选择<默认与重载YES>
 */
@property (nonatomic) BOOL selectEnabled;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 刷新
 */
- (void)reloadData;

@end

