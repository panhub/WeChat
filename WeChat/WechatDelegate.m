//
//  WechatDelegate.m
//  WeChat
//
//  Created by Vincent on 2019/2/20.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WechatDelegate.h"
#import "MNDragView.h"
#import "WXTabBarController.h"
#import "WXLoginViewController.h"
#import "WXFavorite.h"
#import "WXMessage.h"
#import "WXSession.h"
#import "WXMoment.h"
#import "WXWebpage.h"
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
#import <AuthenticationServices/AuthenticationServices.h>
#endif

@interface WechatDelegate ()
@property (nonatomic, strong) MNNetworkReachability *reachability;
@property (nonatomic, strong) WXTabBarController *tabBarController;
@end

@implementation WechatDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    /// 注册事件通知
    [self registNotification];
    /// 初始化数据
    [self initialization];
    /// 创建主Window
    [self makeKeyWindow];
    /// 加载会话列表
    [[WechatHelper helper] asyncLoadSessions:^{
        if ([WXUser isLogin]) {
            [self makeWechatAndVisible];
        } else {
            [self makeLoginAndVisible];
        }
    }];
    return YES;
}

#pragma mark - 加载数据/注册通知
- (void)registNotification {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(makeWechatAndVisible)
                                               name:LOGIN_NOTIFY_NAME
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(makeLoginAndVisible)
                                               name:LOGOUT_NOTIFY_NAME
                                             object:nil];
}

- (void)initialization {
    /// 高德地图
    [self AMapSetting];
    /// 加载表
    [[WechatHelper helper] asyncLoadTable];
    /// 加载联系人信息
    [[WechatHelper helper] asyncLoadContacts];
    /// 加载公共数据
    [[MNConfiguration configuration] loadDataWithCompletionHandler:nil];
    /// 触发联网提示
    MNNetworkReachability *reachability = [MNNetworkReachability reachability];
    [reachability startMonitoring];
    self.reachability = reachability;
}

#pragma mark - 开放平台配置信息
/// 高德
- (void)AMapSetting {
    /// 开启ATS
    [AMapServices sharedServices].enableHTTPS = YES;
    /// 设置AppKey
    [AMapServices sharedServices].apiKey = AMapAppKey;
}

#pragma mark - MakeKeyWindow
- (void)makeKeyWindow {
    UIWindow *window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [window makeKeyWindow];
    [window makeKeyAndVisible];
    self.window = window;
    self.window.rootViewController = [NSClassFromString(@"WXLaunchController") new];
}

- (void)makeLoginAndVisible {
    MNNavigationController *nav = [[MNNavigationController alloc] initWithRootViewController:WXLoginViewController.new];
    self.window.rootViewController = nav;
    WXPreference.preference.loginPolicy = WXLoginPolicyNone;
    [self->_tabBarController reset];
    [[WechatHelper helper] reloadData];
    WXPreference.preference.launchState = WXLaunchStateCompleted;
    if (WXPreference.preference.isAllowsDebug) [MNDebuger startDebug];
    [NSUserDefaults setBool:NO forKey:WXShareLoginKey withGroup:WeChatShareSuiteName];
    // 打开外界调用
    NSString *cls = WXPreference.preference.next_cls;
    WXPreference.preference.next_cls = nil;
    [self handOpenViewController:cls];
}

- (void)makeWechatAndVisible {
    self.window.rootViewController = self.tabBarController;
    WXPreference.preference.launchState = WXLaunchStateCompleted;
    // 调试
    if (WXPreference.preference.isAllowsDebug) [MNDebuger startDebug];
    // 更新朋友圈角标
    [self.tabBarController updateMomentBadgeValue];
    // 保存已登录
    [NSUserDefaults setBool:YES forKey:WXShareLoginKey withGroup:WeChatShareSuiteName];
    // 打开外界调用
    NSString *cls = WXPreference.preference.next_cls;
    WXPreference.preference.next_cls = nil;
    [self handOpenViewController:cls];
}

- (void)changeDebugState {
    WXPreference.preference.allowsDebug = !WXPreference.preference.isAllowsDebug;
    [MNDebuger setAllowsDebug:WXPreference.preference.isAllowsDebug];
}

- (void)makeDebugVisible:(BOOL)isVisible {
    if (isVisible && WXPreference.preference.isAllowsDebug) {
        [MNDebuger startDebug];
    } else {
        [MNDebuger endDebug];
    }
}

#pragma mark - Logout
- (void)logout {
    [WXUser logout];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:AppleUserIdentifier];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - Getter
- (WXTabBarController *)tabBarController {
    if (!_tabBarController) {
        WXTabBarController *tabBarController = [WXTabBarController tabBarController];
        tabBarController.controllers = @[@"WXSessionViewController", @"WXContactsViewController", @"WXFindViewController", @"WXMineViewController"];
        _tabBarController = tabBarController;
    }
    return _tabBarController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
    [self checkAppleIDState];
#endif
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /// 在这里刷新外部分享的网页
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self updateFavorites];
        [self updateSessions];
        [self updateMoments];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Open URL
/// <= 9.0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    return [self handOpenUrl:URL.absoluteString];
}

/// > 9.0
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)URL options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self handOpenUrl:URL.absoluteString];
}

- (BOOL)handOpenUrl:(NSString *)url {
    if ([url hasPrefix:@"mnchat://"]) {
        NSArray *components = [url componentsSeparatedByString:@"="];
        if (components.count == 2) {
            if (WXPreference.preference.launchState == WXLaunchStateLoading) {
                WXPreference.preference.next_cls = components.lastObject;
                return YES;
            }
            return [self handOpenViewController:components.lastObject];
        }
    }
    return NO;
}

#pragma mark - OpenViewController
- (BOOL)handOpenViewController:(NSString *)string {
    if (string.length <= 0) return NO;
    UINavigationController *nav = UIWindow.presentedViewController.navigationController;
    UIViewController *vc = [nav.viewControllers lastObject];
    if ([vc isKindOfClass:NSClassFromString(string)] == NO) {
        vc = [NSClassFromString(string) new];
        [nav pushViewController:vc animated:YES];
    }
    return YES;
}

#pragma mark - ShareExtension
- (void)updateFavorites {
    NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WeChatShareSuiteName];
    NSArray <NSDictionary *>*items = [UserDefaults arrayForKey:WXShareFavoritesKey];
    if (items.count <= 0) return;
    [UserDefaults removeObjectForKey:WXShareFavoritesKey];
    [UserDefaults synchronize];
    NSMutableArray <WXFavorite *>*favorites = @[].mutableCopy;
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
        WXFavorite *favorite = [WXFavorite shareWithDictionary:dic];
        if (!favorite) return;
        if ([[MNDatabase database] insertToTable:WXFavoriteTableName model:favorite]) {
            [favorites addObject:favorite];
        }
    }];
    // 按时间将序
    [favorites sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (favorites.count) @PostNotify(WXFavoriteUpdateNotificationName, favorites.copy);
    });
}

- (void)updateSessions {
    NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WeChatShareSuiteName];
    NSArray <NSDictionary *>*items = [UserDefaults arrayForKey:WXShareToSessionKey];
    if (items.count <= 0) return;
    [UserDefaults removeObjectForKey:WXShareToSessionKey];
    [UserDefaults synchronize];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *identifier = item[WXShareSessionIdentifierKey];
        WXSession *session = [WechatHelper.helper sessionForIdentifier:identifier];
        if (!session) return;
        WXWebpage *page = [WXWebpage shareWithDictionary:item[WXShareToSessionWebpageKey]];
        if (!page) return;
        WXMessage *message = [WXMessage createWebpageMsg:page isMine:YES session:session];
        if (message) {
            message.user_info = session.identifier;
            @PostNotify(WXSessionUpdateNotificationName, session);
            dispatch_async(dispatch_get_main_queue(), ^{
                @PostNotify(WXMessageUpdateNotificationName, message);
            });
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        @PostNotify(WXSessionTableReloadNotificationName, nil);
    });
}

- (void)updateMoments {
    NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WeChatShareSuiteName];
    NSArray <NSDictionary *>*items = [UserDefaults arrayForKey:WXShareToMomentKey];
    if (items.count <= 0) return;
    [UserDefaults removeObjectForKey:WXShareToMomentKey];
    [UserDefaults synchronize];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        WXWebpage *webpage = [WXWebpage shareWithDictionary:item[WXShareToMomentWebpageKey]];
        NSData *archivedData = webpage.archivedData;
        if (!archivedData) return;
        WXMoment *moment = WXMoment.new;
        moment.uid = WXUser.shareInfo.uid;
        moment.source = @"网页分享";
        moment.location = @"";
        moment.privacy = NO;
        moment.web = archivedData;
        moment.type = WXMomentTypeWeb;
        moment.content = item[WXShareToMomentTextKey];
        moment.timestamp = webpage.timestamp;
        if (![MNDatabase.database insertToTable:WXMomentTableName model:moment]) return;
        dispatch_async_main(^{
            @PostNotify(WXMomentUpdateNotificationName, moment);
        });
    }];
}

MNKIT_CLANG_AVAILABLE_PUSH
#pragma mark - CheckAppleIDState
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
- (void)checkAppleIDState {
    // 验证是否合法
    NSString *user = [NSUserDefaults.standardUserDefaults objectForKey:AppleUserIdentifier];
    if (user.length <= 0 || !WXUser.isLogin) return;
    [ASAuthorizationAppleIDProvider.new getCredentialStateForUserID:user completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
        dispatch_async_main(^{
            if (credentialState != ASAuthorizationAppleIDProviderCredentialAuthorized) {
                if ([(NSString *)MNAlertView.currentAlertView.title isEqualToString:@"AppleID已失效"]) return;
                [MNAlertView close];
                [[MNAlertView alertViewWithTitle:@"AppleID已失效" message:@"请退出后重新登录!" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                    [self.window showWechatDialogDelay:.3f eventHandler:^{
                        [self logout];
                    } completionHandler:^{
                        [self makeLoginAndVisible];
                    }];
                } ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
        });
    }];
}
#endif
MNKIT_CLANG_POP

@end
