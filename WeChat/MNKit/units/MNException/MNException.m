//
//  MNExceptionHandler.m
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNException.h"
#import "MNMail.h"
#import "NSBundle+MNHelper.h"
#import "UIDevice+MNHelper.h"
#include <execinfo.h>

static NSUncaughtExceptionHandler MNUncaughtExceptionHandler;
static NSUncaughtExceptionHandler *MNOriginalUncaughtExceptionHandler;
static NSString *MNExceptionEmailRecipient = @"";

void MNExceptionEmailSetRecipient (NSString *recipient) {
    MNExceptionEmailRecipient = recipient ? : @"";
}

@implementation MNException

#pragma mark - UncaughtException
void MNInstallUncaughtExceptionHandler(void) {
    if (NSGetUncaughtExceptionHandler() != MNUncaughtExceptionHandler) {
        //先记录原本的回调者, 便于恢复
        MNOriginalUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    }
    NSSetUncaughtExceptionHandler(&MNUncaughtExceptionHandler);
}

void MNUninstallUncaughtExceptionHandler(void) {
    if (NSGetUncaughtExceptionHandler() == MNUncaughtExceptionHandler) {
        NSSetUncaughtExceptionHandler(MNOriginalUncaughtExceptionHandler);
    }
}

#pragma mark - UncaughtException
void MNUncaughtExceptionHandler(NSException *exception) {
    if (!exception) return;
    //获取崩溃信息
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"<b>name：</b>\n%@\n\n<b>reason：</b>\n%@\n\n<b>callStackSymbols：</b>\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:@"<b>Exception Report\n\n</b>"];
    [body appendFormat:@"<b>Display Name：</b>%@\n", NSBundleDisplayName()];
    [body appendFormat:@"<b>Version：</b>%@\n", NSBundleVersion()];
    [body appendFormat:@"<b>Build：</b>%@\n", NSBuildVersion()];
    [body appendFormat:@"<b>System Version：</b>%@\n\n", IOS_VERSION()];
    [body appendFormat:@"%@", content];
    //发送邮件
    MNExceptionSendMail(body);
}

#pragma mark - SignalException
void MNInstallSignalExceptionHandler(void) {
    signal(SIGHUP, MNSignalExceptionHandler);
    signal(SIGINT, MNSignalExceptionHandler);
    signal(SIGQUIT, MNSignalExceptionHandler);
    signal(SIGABRT, MNSignalExceptionHandler);
    signal(SIGILL, MNSignalExceptionHandler);
    signal(SIGSEGV, MNSignalExceptionHandler);
    signal(SIGFPE, MNSignalExceptionHandler);
    signal(SIGBUS, MNSignalExceptionHandler);
    signal(SIGPIPE, MNSignalExceptionHandler);
}

void MNSignalExceptionHandler(int signal) {
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:@"<b>Exception Report\n\n</b>"];
    [body appendFormat:@"<b>Display Name：</b>%@\n", NSBundleDisplayName()];
    [body appendFormat:@"<b>Version：</b>%@\n", NSBundleVersion()];
    [body appendFormat:@"<b>Build：</b>%@\n", NSBuildVersion()];
    [body appendFormat:@"<b>System Version：</b>%@\n\n", IOS_VERSION()];
    
    [body appendString:@"<b>callStackSymbols</b>:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [body appendFormat:@"%s\n", strs[i]];
    }
    //发送邮件
    MNExceptionSendMail(body);
}

#pragma mark - 发送异常邮件
static void MNExceptionSendMail (NSString *body) {
    if (MNExceptionEmailRecipient.length <= 0 || body.length <= 0) return;
    MNMail *email = MNMailCreate(@[MNExceptionEmailRecipient], nil, @"MNKit Exception", body.copy);
    [email send];
}

@end
