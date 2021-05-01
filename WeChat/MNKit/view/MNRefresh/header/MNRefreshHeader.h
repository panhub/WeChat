//
//  MNRefreshHeader.h
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  微信刷新

#import "MJRefreshHeader.h"

typedef NS_ENUM(NSInteger, MNRefreshHeaderType) {
    MNRefreshHeaderTypeNormal = 0,
    MNRefreshHeaderTypeMargin
};

NS_ASSUME_NONNULL_BEGIN

@interface MNRefreshHeader : MJRefreshHeader

/**标记类型*/
@property (nonatomic) MNRefreshHeaderType type;

/**
 实例化刷新视图
 @param type 类型
 @return 刷新实例
 */
- (instancetype)initWithType:(MNRefreshHeaderType)type;

@end

NS_ASSUME_NONNULL_END
