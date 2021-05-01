//
//  UIApplication+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/12/10.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIApplication+MNHelper.h"
#import <objc/message.h>
#import <StoreKit/SKStoreReviewController.h>
#import <StoreKit/SKStoreProductViewController.h>

@interface AppStoreProductDelegate : NSObject <SKStoreProductViewControllerDelegate, UIAlertViewDelegate>

@end

static AppStoreProductDelegate *_delegate;
@implementation AppStoreProductDelegate
#pragma mark - UIAlertViewDelegate<跳转AppStore下载界面>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        _delegate = nil;
        if (alertView.tag <= 0) return;
        [UIApplication handOpenProduct:[NSString stringWithFormat:@"%@", @(alertView.tag)]
                                  type:AppStoreLoadOpen
                            completion:nil];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    _delegate = nil;
    viewController.delegate = nil;
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

#define UIApplicationSourceUnknow  @"com.mn.application.source.unknow"

#define UIApplicationOpenCallback(succeed) \
if (handler) { \
handler(succeed); \
}

@implementation UIApplication (MNHelper)
#pragma mark - 状态栏高度
+ (CGFloat)statusBarHeight {
    static CGFloat status_bar_height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL hidden = [[UIApplication sharedApplication] isStatusBarHidden];
        if (hidden) [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        status_bar_height = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
        if (hidden) [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    });
    return status_bar_height;
}

#pragma mark - 打开网页
+ (void)handOpenUrl:(id)url completion:(UIApplicationOpenHandler)handler {
    NSURL *URL;
    if ([url isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:url];
    } else if ([url isKindOfClass:[NSURL class]]) {
        URL = (NSURL *)url;
    }
    if (!URL) {
        UIApplicationOpenCallback(NO);
        return;
    }
    if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 100000) {
        if (@available(iOS 10.0, *)) {
            //@{UIApplicationOpenURLOptionUniversalLinksOnly:@(YES)}
            //options 不能为nil, 否则崩溃
            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:handler];
        } else {
            UIApplicationOpenCallback([[UIApplication sharedApplication] openURL:URL]);
        }
    } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        UIApplicationOpenCallback([[UIApplication sharedApplication] openURL:URL]);
    } else {
        UIApplicationOpenCallback(NO);
    }
}

+ (void)handOpenQQGroup:(NSString *)group withKey:(NSString *)key completion:(UIApplicationOpenHandler)handler {
    [self handOpenUrl:[NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", group, key] completion:handler];
}

+ (void)handOpenQQUser:(NSString *)account completion:(UIApplicationOpenHandler)handler {
    [self handOpenUrl:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", account] completion:handler];
}

#pragma mark - 打开应用
+ (void)handOpen:(UIApplicationSourceType)type completion:(UIApplicationOpenHandler)handler {
    if ([self canOpen:type]) {
        [self handOpenUrl:[self sourceUrl:type] completion:handler];
    } else {
        UIApplicationOpenCallback(NO);
    }
}

#pragma mark - 是否安装应用
+ (BOOL)canOpen:(UIApplicationSourceType)type {
    NSArray <NSString *>*schemes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSApplicationQueriesSchemes"];
    if (![schemes containsObject:[self sourceScheme:type]]) return NO;
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[self sourceUrl:type]]];
}

#pragma mark - 获取应用白名单
+ (NSString *)sourceScheme:(UIApplicationSourceType)type {
    switch (type) {
        case UIApplicationSourceQQ: return @"mqq";
        case UIApplicationSourceQQGroup: return @"mqqapi";
        case UIApplicationSourceWechat: return @"weixin";
        case UIApplicationSourceSina: return @"sinaweibo";
        case UIApplicationSourceAlipay: return @"alipay";
        case UIApplicationSourceTaobao: return @"taobao";
        case UIApplicationSourceTmall: return @"tmall";
        case UIApplicationSourceJD: return @"openApp.jdMobile";
        case UIApplicationSourceMeituan: return @"imeituan";
        case UIApplicationSourceDingtalk: return @"dingtalk";
        default: break;
    }
    return UIApplicationSourceUnknow;
}

#pragma mark - 获取应用url
+ (NSString *)sourceUrl:(UIApplicationSourceType)type {
    switch (type) {
        case UIApplicationSourceQQ: return @"mqq://";
        case UIApplicationSourceQQGroup: return @"mqqapi://";
        case UIApplicationSourceWechat: return @"weixin://";
        case UIApplicationSourceSina: return @"sinaweibo://";
        case UIApplicationSourceAlipay: return @"alipay://";
        case UIApplicationSourceTaobao: return @"taobao://";
        case UIApplicationSourceTmall: return @"tmall://";
        case UIApplicationSourceJD: return @"openapp.jdmoble://";
        case UIApplicationSourceMeituan: return @"imeituan://";
        case UIApplicationSourceDingtalk: return @"dingtalk://";
        default: break;
    }
    return UIApplicationSourceUnknow;
}

#pragma mark - 打开AppStore评分界面
+ (void)handOpenProductScore:(NSString *)appleID
                        type:(AppStoreLoadType)type
                  completion:(UIApplicationOpenHandler)handler
{
    if (appleID.length <= 0) appleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppleID"];
    if (appleID.length <= 0) {
        UIApplicationOpenCallback(NO);
        return;
    }
    if (type == AppStoreLoadOpen || __IPHONE_OS_VERSION_MAX_ALLOWED < 100300) {
        NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",appleID];
        [self handOpenUrl:url completion:handler];
    } else {
        if (@available(iOS 10.3, *)) {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            [SKStoreReviewController requestReview];
        } else {
            UIApplicationOpenCallback(NO);
        }
    }
}

#pragma mark - 打开AppStore下载界面
+ (void)handOpenProduct:(NSString *)appleID
                   type:(AppStoreLoadType)type
             completion:(UIApplicationOpenHandler)handler
{
    if (appleID.length <= 0) {
        appleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppleID"];
    }
    if (appleID.length <= 0) {
        UIApplicationOpenCallback(NO);
        return;
    }
    if (type == AppStoreLoadOpen) {
        NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
        [self handOpenUrl:url completion:handler];
    } else {
        _delegate = [[AppStoreProductDelegate alloc] init];
        UIViewController* currentViewController = UIWindow.presentedViewController;
        SKStoreProductViewController *appStoreController = [[SKStoreProductViewController alloc] init];
        appStoreController.delegate = _delegate;
        [appStoreController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appleID} completionBlock:^(BOOL result, NSError * _Nullable error) {
            if (error) {
                /**置空代理*/
                appStoreController.delegate = nil;
                /**没有打开App Store错误弹窗*/
                if (currentViewController.presentedViewController == appStoreController) {
                    NSString *msg = [error description];
                    if (msg.length <= 0) msg = @"发生未知错误";
                    msg = [NSString stringWithFormat:@"%@\n无法显示应用信息,\n是否跳转AppStore查看?",msg];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                        message:msg
                                                                       delegate:_delegate
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.tag = [appleID integerValue];
                    [alertView show];
                }
            } else {
                [currentViewController presentViewController:appStoreController animated:YES completion:nil];
            }
            UIApplicationOpenCallback((error == nil));
        }];
    }
}

#pragma mark - 忽略触摸事件
void UIApplicationIgnoringInteractionEvent (CGFloat duration) {
    if ([UIApplication isExtension]) return;
    if (duration == 0.f) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        return;
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (duration < 0.f) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

#pragma mark - 退出应用程序
void UIApplicationExit (void) {
    if ([UIApplication isExtension]) return;
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplicationIgnoringInteractionEvent(-1.f);
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [UIView animateWithDuration:.5f animations:^{
                window.alpha = 0.f;
            } completion:^(BOOL finished) {
                exit(0);
            }];
        });
    } else {
        exit(0);
    }
}

#pragma mark - 是否允许接收推送消息
BOOL UIApplicationRemoteNotificationEnable (void) {
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] <= 8.f) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        return setting.types != UIUserNotificationTypeNone;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        return type != UIRemoteNotificationTypeNone;
#pragma clang diagnostic pop
    }
    return NO;
}

+ (BOOL)isExtension {
    static BOOL isAppExtension = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"UIApplication");
        if (!class || ![class respondsToSelector:@selector(sharedApplication)]) isAppExtension = YES;
        if ([[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) isAppExtension = YES;
    });
    return isAppExtension;
}

+ (UIApplication *)shared_application {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return [self isExtension] ? nil : [UIApplication performSelector:@selector(sharedApplication)];
#pragma clang diagnostic pop
}

@end
