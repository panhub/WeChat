//
//  MNTouchContext.m
//  MNKit
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTouchContext.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define MNTouchIDLockoutKey     @"com.mn.touch.id.lockout.key"

@implementation MNTouchContext

+ (BOOL)canTouchBiometry {
    BOOL result = NO;
    if (TARGET_IPHONE_SIMULATOR == NO) {
        result = [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    }
    return result;
}

+ (void)touchEvaluateLocalizedReason:(NSString *)reason
                            password:(void(^)(void))handler
                               reply:(void(^)(BOOL, NSError *))reply {
    if ([self canTouchBiometry] == NO) {
        if (handler) {
            handler();
        } else if (reply) {
            reply(NO, [self evaluateErrorWithCode:LAErrorTouchIDNotAvailable]);
        }
        return;
    }
    /// 创建上下文
    LAContext *context = [[LAContext alloc] init];
    /// 判断是否被锁定, 选择密码解锁
    if ([[NSUserDefaults standardUserDefaults] boolForKey:MNTouchIDLockoutKey]) {
        /// 这里不判断版本是因为只用符合条件时 MNTouchIDLockoutKey 才会有值
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        /// 把本地标识改为NO，表示指纹解锁解除锁定
                        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:MNTouchIDLockoutKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        if (reply) {
                            reply(YES, nil);
                        }
                    }
                });
            }];
        } else {
            if (reply) {
                reply(NO, [self evaluateErrorWithCode:LAErrorAuthenticationFailed description:@"请前往 设置-触控ID与密码 解锁"]);
            }
        }
#pragma clang diagnostic pop
    } else if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        /// 使用低版本方式验证, 目的是获取三次失败事件
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    if (reply) {
                        reply(YES, nil);
                    }
                } else {
                    if (error.code == LAErrorUserFallback) {
                        if (handler) {
                            handler();
                            return;
                        }
                    } else if (error.code == LAErrorAuthenticationFailed) {
                        /// 三次失败
                        if (handler) {
                            handler();
                            return;
                        } else if (reply) {
                            reply(NO, [self evaluateErrorWithCode:LAErrorAuthenticationFailed]);
                            return;
                        }
                    }
                    if (@available(iOS 9.0, *)) {
                        if (error.code == LAErrorTouchIDLockout) {
                            /// 指纹锁定
                            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:MNTouchIDLockoutKey];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            /// 再次请求验证, 系统调起密码验证
                            [self touchEvaluateLocalizedReason:reason password:handler reply:reply];
                            return;
                        }
                    }
                    if (reply) {
                        reply(NO, [self evaluateErrorWithCode:error.code]);
                    }
                }
            });
        }];
    } else {
        if (handler) {
            handler();
        } else if (reply) {
            reply(NO, [self evaluateErrorWithCode:LAErrorTouchIDNotAvailable description:@"Touch ID 不可用"]);
        }
    }
}

+ (NSError *)evaluateErrorWithCode:(LAError)code {
    NSString *desc = @"";
    if (@available(iOS 9.0, *)) {
        if (code == LAErrorTouchIDLockout) {
            desc = @"Touch ID功能已锁定";
        } else if (code == LAErrorAppCancel) {
            desc = @"应用已挂起";
        } else if (code == LAErrorInvalidContext) {
            desc = @"上下文已经失效";
        }
    }
    if (@available(iOS 11.0, *)) {
        if (code == LAErrorBiometryLockout) {
            desc = @"Touch ID功能已锁定";
        } else if (code == LAErrorBiometryNotAvailable) {
            desc = @"Touch ID不可用";
        } else if (code == LAErrorBiometryNotEnrolled) {
            desc = @"未检测到指纹录入";
        } else if (code == LAErrorBiometryLockout) {
            desc = @"Touch ID功能已锁定";
        }
    }
    if (desc.length <= 0) {
        switch (code) {
            case LAErrorAuthenticationFailed:
            {
                desc = @"Touch ID验证失败";
            } break;
            case LAErrorUserCancel:
            {
                desc = @"已取消Touch ID验证";
            } break;
            case LAErrorUserFallback:
            {
                desc = @"选择验证密码";
            } break;
            case LAErrorSystemCancel:
            {
                desc = @"系统已取消授权";
            } break;
            case LAErrorPasscodeNotSet:
            {
                desc = @"未检测到密码录入";
            } break;
            case LAErrorTouchIDNotAvailable:
            {
                desc = @"Touch ID不可用";
            } break;
            case LAErrorTouchIDNotEnrolled:
            {
                desc = @"未检测到指纹录入";
            } break;
            case LAErrorNotInteractive:
            {
                desc = @"操作不合法, 因为要显示被禁止UI";
            } break;
            default:
            {
                desc = @"发生未知错误";
            } break;
        }
    }
    return [self evaluateErrorWithCode:code description:desc];
}

+ (NSError *)evaluateErrorWithCode:(LAError)code description:(NSString *)desc {
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey:desc, NSLocalizedFailureReasonErrorKey:desc}];
}

@end
