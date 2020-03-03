//
//  UIAlertController+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2019/2/26.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "UIAlertController+MNHelper.h"
#import "UIWindow+MNHelper.h"

@implementation UIAlertController (MNHelper)

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message actions:(UIAlertAction *)action,...NS_REQUIRES_NIL_TERMINATION {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    if (!action) return alertController;
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:0];
    [actions addObject:action];
    va_list args;
    va_start(args, action);
    while ((action = va_arg(args, UIAlertAction *))) {
        [actions addObject:action];
    }
    va_end(args);
    [actions.copy enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:obj];
    }];
    return alertController;
}

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message textFieldHandler:(void (^)(UITextField *textField))handler actions:(UIAlertAction *)action,...NS_REQUIRES_NIL_TERMINATION {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:handler];
    if (!action) return alertController;
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:0];
    [actions addObject:action];
    va_list args;
    va_start(args, action);
    while ((action = va_arg(args, UIAlertAction *))) {
        [actions addObject:action];
    }
    va_end(args);
    [actions.copy enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:obj];
    }];
    return alertController;
}

+ (void)showMessage:(NSString *)message {
    [UIAlertController showTitle:@"提示" message:message action:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
}

+ (void)showTitle:(NSString *)title message:(NSString *)message action:(UIAlertAction *)action {
    if (!action) return;
    [[UIAlertController alertControllerWithTitle:title message:message actions:action, nil] show];
}

- (void)show {
    [UIWindow.presentedViewController presentViewController:self animated:YES completion:nil];
}

@end
