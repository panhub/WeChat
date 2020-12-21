//
//  UIAlertView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/12/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIAlertView+MNHelper.h"

@implementation UIAlertView (MNHelper)

#pragma mark - 显示系统弹出窗
+ (void)showMessage:(NSString *)message {
    [self showAlertWithTitle:nil message:message cancelButtonTitle:nil];
}

+ (void)showMessage:(NSString *)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle {
    [self showAlertWithTitle:nil message:message cancelButtonTitle:cancelButtonTitle];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle {
    if (cancelButtonTitle.length <= 0) cancelButtonTitle = @"取消";
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:cancelButtonTitle
                          otherButtonTitles:nil] show];
    });
}

@end
