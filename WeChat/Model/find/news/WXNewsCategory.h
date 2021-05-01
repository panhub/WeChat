//
//  WXNewsCategory.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//  新闻类型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXNewsCategory : NSObject

/**类型名*/
@property (nonatomic, copy) NSString *title;

/**请求类型*/
@property (nonatomic, copy) NSString *type;

/**
 实例化新闻类型
 */
+ (WXNewsCategory *)modelWithTitle:(NSString *)title type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
