//
//  MNHTTPDataRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/21.
//  Copyright © 2018年 小斯. All rights reserved.
//  数据请求者

#import "MNURLDataRequest.h"

@interface MNHTTPDataRequest : MNURLDataRequest

/**是否可以加载更多,有下一页*/
@property (nonatomic, getter=hasMore) BOOL more;
/**此次请求的页数*/
@property (nonatomic) NSUInteger page;
/**是否允许分页*/
@property (nonatomic) BOOL pagingEnabled;
/**盛放数据模型*/
@property (nonatomic, strong, readonly) NSMutableArray *dataArray;


/**
 标记开始刷新数据
 */
- (void)prepareReloadData;

/**
 目前数据是否为空
 @return 是否空数据
 */
- (BOOL)isDataEmpty;

/**
 *清除缓存
 */
- (void)cleanMemoryCache;


@end

