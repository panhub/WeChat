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
 - MNURLDataCacheNever: 不缓存
 - MNURLDataCacheUseTime: 利用 cacheOutInterval 缓存
 - MNURLDataCacheAllowable: 直接缓存
 */
typedef NS_ENUM(NSInteger, MNURLDataCachePolicy) {
    MNURLDataCacheNever = 0,
    MNURLDataCacheUseTime,
    MNURLDataCacheAllowable
};

@interface MNURLDataRequest : MNURLRequest

/**请求任务实例*/
@property (nonatomic, readonly) NSURLSessionDataTask *dataTask;
/**请求方式*/
@property (nonatomic, assign) MNURLHTTPMethod method;
/**是否是缓存数据*/
@property (nonatomic, assign) MNURLDataSource dataSource;
/**缓存超时天数*/
@property (nonatomic, assign) NSTimeInterval cacheOutInterval;
/**缓存策略*/
@property (nonatomic, assign) MNURLDataCachePolicy cachePolicy;


/**
 获取数据请求
 @param startCallback 请求开始回调
 @param finishCallback 请求结束回调
 */
- (void)loadData:(MNURLRequestStartCallback)startCallback
      completion:(MNURLRequestFinishCallback)finishCallback;

@end

