//
//  NSDictionary+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MNHelper)

/**
 以&拼接字符串
 @return 拼接后的字符串
 */
- (NSString *)urlString;

/**
 以=拼接字符串
 @return 拼接后的字符串
 */
- (NSString *)componentString;

/**
 以指定分割符拼接为字符串
 @param separator 分割符
 @return 分割拼接后的字符串
 */
- (NSString *)componentsJoinedByString:(NSString *)separator;

@end

