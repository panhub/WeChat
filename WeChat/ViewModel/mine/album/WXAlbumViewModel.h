//
//  WXAlbumViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册配置模型

#import <Foundation/Foundation.h>
#import "WXYearViewModel.h"
@class WXProfile;

@interface WXAlbumViewModel : NSObject
/**
 数据源
 */
@property (nonatomic, strong, readonly) NSMutableArray <WXYearViewModel *>*dataSource;
/**
 刷新表回调
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);
/**
 数据加载结束回调
 */
@property (nonatomic, copy) void (^didLoadFinishHandler) (BOOL hasMore);
/**
 配图点击事件
 */
@property (nonatomic, copy) void (^touchEventHandler) (WXProfile *picture);

/**
 加载朋友圈相册
 */
- (void)loadData;

@end
