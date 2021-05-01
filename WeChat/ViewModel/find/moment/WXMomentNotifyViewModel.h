//
//  WXMomentNotifyViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/4/25.
//  Copyright © 2021 Vincent. All rights reserved.
//  朋友圈提醒

#import <Foundation/Foundation.h>
#import "WXNotifyViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentNotifyViewModel : NSObject
/**
 数据源
 */
@property (nonatomic, strong, readonly) NSMutableArray <WXNotifyViewModel *>*dataSource;
/**
 刷新表回调
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);
/**
 数据加载结束回调
 */
@property (nonatomic, copy) void (^didLoadFinishHandler) (BOOL hasMore);


/**
 加载朋友圈相册
 */
- (void)loadData;

@end

NS_ASSUME_NONNULL_END
