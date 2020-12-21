//
//  MNLocalEvaluation.m
//  MNKit
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLocalEvaluation.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define kMNLocalEvaluating  @"com.mn.local.evaluating"

@interface MNLocalEvaluation ()
@property (nonatomic, class, getter=isEvaluating) BOOL evaluating;
@end

@implementation MNLocalEvaluation
@dynamic evaluating;

+ (BOOL)isEnabled {
    if ([LAContext.new canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) return YES;
    if (@available(iOS 9.0, *)) {
        return [LAContext.new canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil];
    }
    return NO;
}

+ (BOOL)isTouchEnabled {
    LAContext *context = LAContext.new;
    BOOL flag = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (@available(iOS 11.0, *)) {
        return context.biometryType == LABiometryTypeTouchID;
    } else if (@available(iOS 9.0, *)) {
        if (!flag) flag = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil];
    }
    return flag;
}

+ (BOOL)isFaceEnabled {
    LAContext *context = LAContext.new;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (@available(iOS 11.0, *)) {
        return context.biometryType == LABiometryTypeFaceID;
    }
    return NO;
}

+ (void)evaluateReason:(NSString *)reason
              password:(void(^)(void))handler
                 reply:(void(^)(BOOL, NSError *))reply {
    if ([self isEnabled] == NO) {
        if (handler) {
            handler();
        } else if (reply) {
            reply(NO, [self evaluateErrorWithCode:LAErrorTouchIDNotAvailable]);
        }
        return;
    }
    /// 记录在验证
    self.evaluating = YES;
    /// 创建上下文
    LAContext *context = [[LAContext alloc] init];
    /// 判断是否被锁定, 选择密码解锁
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        /// 这里触发系统验证密码
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                /// 指纹解锁解除锁定
                self.evaluating = NO;
                if (reply) {
                    reply(success, error ? [self evaluateErrorWithCode:error.code] : nil);
                }
            });
        }];
#pragma clang diagnostic pop
    } else {
        /// 使用低版本方式验证, 目的是获取三次失败事件
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.evaluating = NO;
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
                        } else if (reply) {
                            reply(NO, [self evaluateErrorWithCode:LAErrorAuthenticationFailed]);
                        }
                        return;
                    }
                    if (@available(iOS 9.0, *)) {
                        if (error.code == LAErrorTouchIDLockout) {
                            /// 再次请求验证, 系统调起密码验证
                            [self evaluateReason:reason password:handler reply:reply];
                            return;
                        }
                    }
                    if (reply) {
                        reply(NO, [self evaluateErrorWithCode:error.code]);
                    }
                }
            });
        }];
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
                desc = @"验证密码以继续";
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
                desc = @"操作不合法";
            } break;
            default:
            {
                desc = @"发生未知错误";
            } break;
        }
    }
    if ([self isFaceEnabled]) {
        desc = [desc stringByReplacingOccurrencesOfString:@"Touch ID" withString:@"Face ID"];
    }
    return [self evaluateErrorWithCode:code description:desc];
}

+ (NSError *)evaluateErrorWithCode:(LAError)code description:(NSString *)desc {
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey:desc, NSLocalizedFailureReasonErrorKey:desc}];
}

+ (void)setEvaluating:(BOOL)evaluating {
    [NSUserDefaults.standardUserDefaults setBool:evaluating forKey:kMNLocalEvaluating];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)isEvaluating {
    return [NSUserDefaults.standardUserDefaults boolForKey:kMNLocalEvaluating];
}

@end
