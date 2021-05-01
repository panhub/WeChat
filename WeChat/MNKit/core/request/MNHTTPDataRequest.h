//
//  MNHTTPDataRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/21.
//  Copyright © 2018年 小斯. All rights reserved.
//  数据请求者

#import "MNURLDataRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNHTTPDataRequest : MNURLDataRequest

/**此次请求的页数*/
@property (nonatomic) NSUInteger page;
/**是否可以加载更多,有下一页*/
@property (nonatomic, getter=hasMore) BOOL more;
/**根据method设置值*/
@property (nonatomic, copy, nullable) id parameter;
/**是否空数据*/
@property (nonatomic, readonly) BOOL isDataEmpty;
/**是否允许分页*/
@property (nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;
/**盛放数据模型*/
@property (nonatomic, strong, readonly) NSMutableArray *dataArray;

/**
 处理参数
 */
- (void)handQuery;

/**
 处理请求体
 */
- (void)handBody;

/**
 处理请求头
 */
- (void)handHeaderField;

/**
 处理缓存链接
 */
- (void)handCacheUrl;

/**
 标记开始刷新数据
 */
- (void)prepareReloadData;

/**
 添加请求体<请求前有效 body=value>
 @param value 参数值
 @param parameter 参数key
 */
- (void)setValue:(nullable NSString *)value forParameter:(NSString *)parameter;

/**
 *清除缓存
 */
- (void)cleanMemory;

@end

NS_ASSUME_NONNULL_END
