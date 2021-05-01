//
//  MNRefreshFooter.h
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  加载更多

#import "MJRefreshBackFooter.h"

typedef NS_ENUM(NSInteger, MNRefreshFooterType) {
    MNRefreshFooterTypeNormal = 0,
    MNRefreshFooterTypeMargin
};

NS_ASSUME_NONNULL_BEGIN

@interface MNRefreshFooter : MJRefreshBackFooter

/**无更多数据时的文字*/
@property (nonatomic, copy) NSString *text;

/**标记类型*/
@property (nonatomic) MNRefreshFooterType type;

/**
 实例化加载更多视图
 @param type 类型
 @return 加载更多实例
 */
- (instancetype)initWithType:(MNRefreshFooterType)type;

@end

NS_ASSUME_NONNULL_END
