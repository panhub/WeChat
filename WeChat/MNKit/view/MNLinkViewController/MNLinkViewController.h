//
//  MNLinkViewController.h
//  MNKit
//
//  Created by Vincent on 2018/12/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLinkController.h"
#import "MNLinkTableConfiguration.h"
#import "MNLinkViewControllerProtocol.h"
#import "MNLinkSubpageControllerProtocol.h"

@interface MNLinkViewController : MNLinkController
/**
 交互代理
 */
@property (nonatomic, weak) id<MNLinkViewControllerDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNLinkViewControllerDataSource> dataSource;
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


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 刷新
 */
- (void)reloadData;

@end

