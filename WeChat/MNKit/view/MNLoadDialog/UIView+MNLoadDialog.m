//
//  UIView+MNLoadDialog.m
//  MNKit
//
//  Created by Vincent on 2020/1/11.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "UIView+MNLoadDialog.h"
#import <objc/message.h>

static NSString * MNLoadDialogAssociatedKey = @"com.mn.view.dialog.associated.key";

@implementation UIView (MNLoadDialog)
#pragma mark - Load弹窗
- (void)showDialog {
    [self showLoadDialog:nil];
}

- (void)showLoadDialog:(NSString *)message {
    [self showDialog:MNLoadDialogGetDefaultStyle() message:message];
}

- (void)showLoadDialog:(NSString *)message eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler {
    [self showLoadDialog:message];
    if (eventHandler) eventHandler();
    [self closeDialogWithCompletionHandler:completionHandler];
}

#pragma mark - Mask弹窗
- (void)showMaskDialog:(NSString *)message {
    [self showDialog:MNLoadDialogStyleMask message:message];
}

#pragma mark - Activity弹窗
- (void)showActivityDialog:(NSString *)message {
    [self showDialog:MNLoadDialogStyleActivity message:message];
}

#pragma mark - Rotate弹窗
- (void)showRotateDialog:(NSString *)message {
    [self showDialog:MNLoadDialogStyleRotation message:message];
}

#pragma mark - Dot弹窗
- (void)showDotDialog {
    [self showDialog:MNLoadDialogStyleDot message:nil];
}

#pragma mark - 错误弹窗
- (void)showErrorDialog:(NSString *)message {
    [self showDialog:MNLoadDialogStyleError message:message];
}

- (void)showErrorDialog:(NSString *)message completionHandler:(void(^)(void))completionHandler {
    [self showErrorDialog:message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
}

#pragma mark - Completed弹窗
- (void)showCompletedDialog:(NSString *)message {
    [self showDialog:MNLoadDialogStyleCompletion message:message];
}

- (void)showCompletedDialog:(NSString *)message completionHandler:(void(^)(void))completionHandler {
    [self showCompletedDialog:message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.63*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) {
            completionHandler();
        }
    });
}

#pragma mark - 提示弹窗
- (void)showInfoDialog:(NSString *)info {
    [self showDialog:MNLoadDialogStyleInfo message:info];
}

#pragma mark - 进度弹窗
- (void)showProgressDialog:(NSString *)message {
    [self showDialog:MNLoadDialogStyleProgress message:message];
}

#pragma mark - 更新进度弹窗
- (BOOL)updateDialogProgress:(CGFloat)progress {
    MNLoadDialog *dialog = [self loadDialog_];
    if (!dialog) return NO;
    return [dialog updateProgress:progress];
}

#pragma mark - 显示弹窗
- (void)showDialog:(MNLoadDialogStyle)style message:(NSString *)message {
    [self closeDialog];
    MNLoadDialog *dialog = [MNLoadDialog loadDialogWithStyle:style message:message];
    if (!dialog) return;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([dialog showInView:self]) {
            [self setLoadDialog_:dialog];
        }
    }];
}

#pragma mark - 更新提示信息
- (BOOL)updateDialogMessage:(NSString *)message {
    MNLoadDialog *dialog = [self loadDialog_];
    if (!dialog || dialog.style >= MNLoadDialogStyleInfo) return NO;
    return [dialog updateMessage:message];
}

#pragma mark - 关闭弹窗
- (void)closeDialog {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        MNLoadDialog *alert = [self loadDialog_];
        if (alert && alert.superview) [alert dismiss];
        [self setLoadDialog_:nil];
    }];
}

- (void)closeDialogWithCompletionHandler:(void(^)(void))completion {
    [self closeDialog];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

- (void)closeProgressDialogWithCompletionHandler:(void(^)(void))completion {
    [self updateDialogProgress:1.f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

#pragma mark - Getter
- (BOOL)isDialoging {
    MNLoadDialog *v = self.loadDialog_;
    return (v && v.superview);
}

#pragma mark - MNLoadDialog
- (MNLoadDialog *)loadDialog_ {
    return objc_getAssociatedObject(self, &MNLoadDialogAssociatedKey);
}

- (void)setLoadDialog_:(MNLoadDialog *)loadDialog_ {
    objc_setAssociatedObject(self, &MNLoadDialogAssociatedKey, loadDialog_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIView (MNWechatDialog)

#pragma mark - 微信弹窗
- (void)showWechatDialog {
    [self showDialog:MNLoadDialogStyleWechat message:nil];
}

- (void)showWechatDialogDelay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler {
    [self showWechatDialogNeeds:YES delay:delay eventHandler:nil completionHandler:completionHandler];
}

- (void)showWechatDialogDelay:(NSTimeInterval)delay eventHandler:(void(^)(void))eventHandler  completionHandler:(void(^)(void))completionHandler {
    [self showWechatDialogNeeds:YES delay:delay eventHandler:eventHandler completionHandler:completionHandler];
}

- (void)showWechatDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler {
    [self showWechatDialogNeeds:isNeed delay:delay eventHandler:nil completionHandler:completionHandler];
}

- (void)showWechatDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler {
    if (!isNeed) {
        if (eventHandler) eventHandler();
        [self closeDialogWithCompletionHandler:completionHandler];
        return;
    }
    [self showWechatDialog];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay/2.f * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (eventHandler) eventHandler();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay/2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self closeDialogWithCompletionHandler:completionHandler];
        });
    });
}

#pragma mark - 支付弹窗
- (void)showPayDialog {
    [self showDialog:MNLoadDialogStylePay message:nil];
}

- (void)showPayDialogDelay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler {
    [self showPayDialogNeeds:YES delay:delay eventHandler:nil completionHandler:completionHandler];
}

- (void)showPayDialogDelay:(NSTimeInterval)delay eventHandler:(void(^)(void))eventHandler  completionHandler:(void(^)(void))completionHandler {
    [self showPayDialogNeeds:YES delay:delay eventHandler:eventHandler completionHandler:completionHandler];
}

- (void)showPayDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler {
    [self showPayDialogNeeds:isNeed delay:delay eventHandler:nil completionHandler:completionHandler];
}

- (void)showPayDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay  eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler {
    if (!isNeed) {
        if (eventHandler) eventHandler();
        [self closeDialogWithCompletionHandler:completionHandler];
        return;
    }
    [self showPayDialog];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay/2.f * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (eventHandler) eventHandler();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay/2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self closeDialogWithCompletionHandler:completionHandler];
        });
    });
}

@end

