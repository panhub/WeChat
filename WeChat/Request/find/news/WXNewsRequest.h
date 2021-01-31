//
//  WXNewsRequest.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//  新闻列表请求

#import "MNHTTPDataRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXNewsRequest : MNHTTPDataRequest

/**新闻类型*/
@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
