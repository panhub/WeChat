//
//  MNURLDataRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  数据请求体

#import "MNURLRequest.h"

/**
 请求方式
 - MNURLHTTPMethodPost: Post
 - MNURLHTTPMethodGet: Get
 */
typedef NS_ENUM(NSInteger, MNURLHTTPMethod) {
    MNURLHTTPMethodPost = 0,
    MNURLHTTPMethodGet,
};

/**
 数据来源
 - MNURLDataSourceCache: 缓存数据
 - MNURLDataSourceNetwork: 网络数据
 */
typedef NS_ENUM(NSInteger, MNURLDataSource) {
    MNURLDataSourceCache = 0,
    MNURLDataSourceNetwork
};

/**
 数据缓存策略
 - MNURLDataCachePolicyNever: 不缓存
 - MNURLDataCachePolicyDontLoad: 加载前查询缓存
 - MNURLDataCachePolicyElseLoad: 加载失败查询缓存
 */
typedef NS_ENUM(NSInteger, MNURLDataCachePolicy) {
    MNURLDataCachePolicyNever = 0,
    MNURLDataCachePolicyDontLoad,
    MNURLDataCachePolicyElseLoad
};

NS_ASSUME_NONNULL_BEGIN

@interface MNURLDataRequest : MNURLRequest
/**重试次数 失败时依此重新请求 NSURLErrorCancelled 无效*/
@property (nonatomic) int retryCount;
/**当前请求计次 外界不要使用*/
@property (nonatomic) int currentRequestCount;
/**请求方式*/
@property (nonatomic) MNURLHTTPMethod method;
/**是否是缓存数据*/
@property (nonatomic) MNURLDataSource dataSource;
/**缓存超时时间间隔 默认3天*/
@property (nonatomic) NSTimeInterval cacheTimeOutInterval;
/**缓存策略*/
@property (nonatomic) MNURLDataCachePolicy cachePolicy;
/**定制缓存的key*/
@property (nonatomic, copy, nullable) NSString *cacheForUrl;
/**请求事件回调*/
@property (nonatomic, weak, nullable) id<MNURLRequestDelegate> delegate;
/**请求任务实例*/
@property (nonatomic, readonly, nullable) NSURLSessionDataTask *dataTask;


/**
 获取数据请求
 @param startCallback 请求开始回调
 @param finishCallback 请求结束回调
 */
- (void)loadData:(MNURLRequestStartCallback _Nullable)startCallback
      completion:(MNURLRequestFinishCallback _Nullable)finishCallback;

@end

NS_ASSUME_NONNULL_END
