//
//  WXMyTimelineViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈

#import <Foundation/Foundation.h>
#import "WXMyMomentYearModel.h"
@class WXMoment, WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyTimelineViewModel : NSObject

/**数据源*/
@property (nonatomic, strong, readonly) NSMutableArray <WXMyMomentYearModel *>*dataSource;
/**
 刷新表回调
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);
/**
 数据加载结束回调
 */
@property (nonatomic, copy) void (^didLoadFinishHandler) (BOOL hasMore);
/**
 点击事件
 */
@property (nonatomic, copy) void (^touchEventHandler) (WXMoment *moment);

/**用户模型*/
@property (nonatomic, strong) WXUser *user;

/**
 依据用户模型实例化
 @param user 指定用户
 @return 用户朋友圈模型
 */
- (instancetype)initWithUser:(WXUser *)user;

/**
 加载朋友圈相册
 */
- (void)loadData;

/**
 加载今日数据
 */
- (void)loadToday;

@end

NS_ASSUME_NONNULL_END
