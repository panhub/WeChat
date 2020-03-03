//
//  MNTouchContext.h
//  MNKit
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  指纹验证辅助

#import <Foundation/Foundation.h>

@interface MNTouchContext : NSObject

/**
 判断是否支持指纹验证
 @return 判断结果
 */
+ (BOOL)canTouchBiometry;

/**
 Touch ID 验证
 @param reason 验证提示信息
 @param handler 输入密码回调
 @param reply 验证结果回调
 */
+ (void)touchEvaluateLocalizedReason:(NSString *)reason
                            password:(void(^)(void))handler
                               reply:(void(^)(BOOL succeed, NSError *error))reply;

@end

