//
//  NSDictionary+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MNHelper)

/**以"&"拼接字符串*/
@property (nonatomic, readonly, nullable) NSString *queryValue;

/**以","拼接字符串*/
@property (nonatomic, readonly, nullable) NSString *componentString;

/**
 以指定分割符拼接为字符串
 @param separator 拼接字符串
 @return 分割拼接后的字符串
 */
- (NSString *_Nullable)componentsJoinedByString:(NSString *)separator;

/**
 以指定分割符拼接为字符串
 @param byString k v拼接
 @param joined 整体拼接
 @return 拼接结果
 */
- (NSString *_Nullable)componentsBy:(NSString *)byString joined:(NSString *)joined;

@end

NS_ASSUME_NONNULL_END

