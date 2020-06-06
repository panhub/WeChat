//
//  WeAppDelegate.m
//  MNChat
//
//  Created by Vincent on 2019/2/20.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WeAppDelegate.h"
#import "MNDragView.h"
#import "WXTabBarController.h"
#import "MNLoginViewController.h"
#import "WXWebpage.h"
#import "WXMessage.h"
#import "WXSession.h"
#import "WXMoment.h"
#import "WXMomentWebpage.h"
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
#import <AuthenticationServices/AuthenticationServices.h>
#endif

@interface WeAppDelegate ()<MNPurchaseDelegate>
@property (nonatomic, strong) WXTabBarController *tabBarController;
@end

@implementation WeAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //famous.default
    /*
    NSString *gifPath = [[MNBundle.mainBundle pathForResource:@"emotion" ofType:nil] stringByAppendingPathComponent:[@"动态表情" stringByAppendingPathComponent:[@"01" stringByAppendingPathExtension:@"gif"]]];
    NSData *gifData = [NSData dataWithContentsOfFile:gifPath];
    UIImage *image = [UIImage animatedImageWithData:gifData];
    NSData *d = [NSData dataWithAnimatedImage:image];
    NSString *file = MNCachePathAppending([MNFileHandle fileNameWithExtension:@"gif"]);
    if ([d writeToFile:file atomically:YES]) {
        NSData *gd = [NSData dataWithContentsOfFile:file];
        UIImage *di = [UIImage animatedImageWithData:gd];
        NSLog(@"");
    }
    */
    /*
    NSMutableArray *array = @[].mutableCopy;
    [[NSFileManager.defaultManager subpathsAtPath:[MNBundle.mainBundle pathForResource:@"famous.default" ofType:nil]] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        NSString *n = obj.stringByDeletingPathExtension;
        NSString *e = obj.pathExtension;
        [dic setObject:n forKey:@"img"];
        [dic setObject:e forKey:@"extension"];
        [dic setObject:@(1) forKey:@"type"];
        [dic setObject:@"描述" forKey:@"desc"];
        [array addObject:dic];
    }];
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:@"网络表情包" forKey:@"desc"];
    [dic setObject:@"动态表情" forKey:@"name"];
    [dic setObject:@"default" forKey:@"img"];
    [dic setObject:@(1) forKey:@"state"];
    [dic setObject:@(1) forKey:@"type"];
    [dic setObject:@"famous.default" forKey:@"uuid"];
    [dic setObject:array.copy forKey:@"emotions"];
    NSString *ppp = MNCachePathAppending([MNFileHandle fileNameWithExtension:@"plist"]);
    if ([dic writeToFile:ppp atomically:YES]) {
        NSLog(@"%@", ppp);
    }
    */
    /*
    NSString *path = [[MNBundle mainBundle] pathForResource:@"emotions" ofType:@"plist" inDirectory:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *mu = @[].mutableCopy;
    NSArray *array = dic[@"emotions"];
    [array enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dic, NSUInteger i, BOOL * _Nonnull s) {
        NSMutableDictionary *d = dic.mutableCopy;
        [d setObject:@"png" forKey:@"extension"];
        [mu addObject:d.copy];
    }];
    NSMutableDictionary *dics = dic.mutableCopy;
    [dics setObject:mu.copy forKey:@"emotions"];
    NSString *ppp = MNCachePathAppending([MNFileHandle fileNameWithExtension:@"plist"]);
    if ([dics writeToFile:ppp atomically:YES]) {
        NSLog(@"%@", ppp);
    }
    */
    // emoticon_favorites
    // emoticon_packet
    // keyboard_add
    /*
    UIImageView *imageview = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 120.f, 120.f) image:[UIImage imageNamed:@"wx_mine_select_avatar"].templateImage];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.clipsToBounds = YES;
    imageview.tintColor = THEME_COLOR;
    UIImage *image = [UIImage imageWithLayer:imageview.layer];
    NSString *file = MNCachePathAppending([MNFileHandle fileNameWithExtension:@"png"]);
    if ([MNFileHandle writeImage:image toFile:file error:nil]) {
        NSLog(@"");
    }
    */
    /// 初始化数据
    [self initialization];
    /// 创建主Window
    [self makeKeyWindow];
    /// 加载会话列表
    [[MNChatHelper helper] asyncLoadSessions:^{
        if ([WXUser isLogin]) {
            [self makeKeyAndVisible];
        } else {
            [self makeLoginAndVisible];
        }
    }];
    return YES;
}

#pragma mark - 加载数据
- (void)initialization {
    /// 高德地图
    [self configAMapSetting];
    /// 加载表
    [[MNChatHelper helper] asyncLoadTable];
    /// 加载联系人信息
    [[MNChatHelper helper] asyncLoadContacts];
    /// 加载公共数据
    [[MNConfiguration configuration] loadDataWithCompletionHandler:nil];
    /// 内购
    MNPurchaseManager.defaultManager.delegate = self;
    MNPurchaseManager.defaultManager.receiptMaxFailCount = 3;
    MNPurchaseManager.defaultManager.receiptMaxSubmitCount = 3;
    MNPurchaseManager.defaultManager.allowsAlertIfNeeded = YES;
    MNPurchaseManager.defaultManager.useItunesSubmitReceipt = YES;
    MNPurchaseManager.defaultManager.secretKey = @"062dbdb74e1a4407988fbaf00ae6f98c";
    [MNPurchaseManager.defaultManager becomeTransactionObserver];
    /// 触发联网提示
    MNNetworkReachability *reachability = [MNNetworkReachability reachability];
    [reachability startMonitoring];
    /// 截屏通知
    [self handNotification:UIApplicationUserDidTakeScreenshotNotification eventHandler:^(NSNotification *notify) {
        dispatch_after_main(.8f, ^{
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                UIImage *image = [[[UIApplication sharedApplication] keyWindow] snapshotImage];
                MNAlertView *alertView = [MNAlertView alertViewWithTitle:@"截屏通知" image:image message:@"已截取快照" handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView resizingImageToHeight:100.f];
                [alertView show];
            }
        });
    }];
}

#pragma mark - MNPurchaseDelegate
- (void)purchaseManagerStartSubmitLocalReceipts:(NSArray <MNPurchaseReceipt *>*)receipts {
    [UIAlertView showAlertWithTitle:nil message:[NSString stringWithFormat:@"本地订单校验中(%@)", @(receipts.count)] cancelButtonTitle:@"确定"];
}

- (void)purchaseManagerDidFinishSubmitReceipt:(MNPurchaseReceipt *)receipt response:(MNPurchaseResponse *)response {
    if (receipt.isLocalReceipt) {
        [UIAlertView showAlertWithTitle:nil message:@"本地凭据验证失败" cancelButtonTitle:@"确定"];
    }
}

#pragma mark - 开放平台配置信息
/// 高德
- (void)configAMapSetting {
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
    
    UIViewController *rootViewController = [UIViewController new];
    [rootViewController layoutExtendAdjustEdges];
    rootViewController.view.backgroundImage = [UIImage launchImage];
    self.window.rootViewController = rootViewController;
}

- (void)makeLoginAndVisible {
    WXPreference.preference.loginType = WXLoginTypeNone;
    MNLoginViewController *vc = [MNLoginViewController new];
    MNNavigationController *nav = [[MNNavigationController alloc] initWithRootViewController:vc];
    UIViewController *rootViewController = self.window.rootViewController;
    self.window.rootViewController = nav;
    UIView *snapshotView = [rootViewController.view snapshotImageView];
    [self.window addSubview:snapshotView];
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.window duration:.5f options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            @strongify(self);
            [self.window sendSubviewToBack:snapshotView];
        } completion:^(BOOL finished) {
            @strongify(self);
            [self->_tabBarController reset];
            [[MNChatHelper helper] reloadData];
            [snapshotView removeFromSuperview];
            WXPreference.preference.launchState = WXAppLaunchStateFinish;
            if (WXPreference.preference.isAllowsDebug) [MNDebuger startDebug];
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:WXShareExtensionSandboox];
            [userDefaults setBool:NO forKey:WXShareExtensionLogin];
            [userDefaults synchronize];
            // 打开外界调用
            NSString *cls = WXPreference.preference.next_cls;
            WXPreference.preference.next_cls = nil;
            [self handOpenViewController:cls];
        }];
    });
}

- (void)makeKeyAndVisible {
    UIViewController *tabBarController = self.tabBarController;
    UIViewController *rootViewController = self.window.rootViewController;
    self.window.rootViewController = tabBarController;
    UIView *snapshotView = [rootViewController.view snapshotImageView];
    [self.window addSubview:snapshotView];
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.window duration:.5f options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            @strongify(self);
            [self.window sendSubviewToBack:snapshotView];
        } completion:^(BOOL finished) {
            @strongify(self);
            [snapshotView removeFromSuperview];
            WXPreference.preference.launchState = WXAppLaunchStateFinish;
            // 调试
            if (WXPreference.preference.isAllowsDebug) [MNDebuger startDebug];
            // 更新朋友圈角标
            [self.tabBarController updateMomentBadgeValue];
            // 保存已登录
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:WXShareExtensionSandboox];
            [userDefaults setBool:YES forKey:WXShareExtensionLogin];
            [userDefaults synchronize];
            // 打开外界调用
            NSString *cls = WXPreference.preference.next_cls;
            WXPreference.preference.next_cls = nil;
            [self handOpenViewController:cls];
        }];
    });
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
    dispatch_async(dispatch_get_high_queue(), ^{
        [self updateFavoritesIfNeeded];
        [self updateSessionsIfNeeded];
        [self updateMomentsIfNeeded];
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
            if (WXPreference.preference.launchState == WXAppLaunchStateUnknown) {
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
- (void)updateFavoritesIfNeeded {
    NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WXShareExtensionSandboox];
    NSArray <NSDictionary *>*items = [UserDefaults arrayForKey:WXShareWebpageToFavorites];
    if (items.count <= 0) return;
    [UserDefaults removeObjectForKey:WXShareWebpageToFavorites];
    [UserDefaults synchronize];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
        WXWebpage *page = [WXWebpage webpageWithSandbox:dic];
        if (!page) return;
        NSArray *rows = [MNDatabase.sharedInstance selectRowsModelFromTable:WXWebpageTableName where:@{sql_field(page.url):sql_pair(page.url)}.componentString limit:NSRangeZero class:WXWebpage.class];
        if (rows.count <= 0) [[MNDatabase sharedInstance] insertIntoTable:WXWebpageTableName model:page];
    }];
    dispatch_async_main(^{
        @PostNotify(WXWebpageReloadNotificationName, nil);
    });
}

- (void)updateSessionsIfNeeded {
    NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WXShareExtensionSandboox];
    NSArray <NSDictionary *>*items = [UserDefaults arrayForKey:WXShareWebpageToSession];
    if (items.count <= 0) return;
    [UserDefaults removeObjectForKey:WXShareWebpageToSession];
    [UserDefaults synchronize];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *identifier = [MNJSONSerialization stringValueWithJSON:item forKey:WXShareSessionIdentifier];
        WXSession *session = [MNChatHelper.helper sessionForIdentifier:identifier];
        if (!session) return;
        WXWebpage *page = [WXWebpage webpageWithSandbox:[MNJSONSerialization dictionaryValueWithJSON:item forKey:WXShareExtensionWebpage]];
        if (!page) return;
        if ([WXMessage createWebpageMsg:page isMine:YES session:session]) {
            @PostNotify(WXSessionUpdateNotificationName, session);
            @PostNotify(WXChatListReloadNotificationName, session);
        }
    }];
    dispatch_async_main(^{
        @PostNotify(WXSessionReloadNotificationName, nil);
    });
}

- (void)updateMomentsIfNeeded {
    NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WXShareExtensionSandboox];
    NSArray <NSDictionary *>*items = [UserDefaults arrayForKey:WXShareWebpageToMoment];
    if (items.count <= 0) return;
    [UserDefaults removeObjectForKey:WXShareWebpageToMoment];
    [UserDefaults synchronize];
    [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        WXWebpage *page = [WXWebpage webpageWithSandbox:[MNJSONSerialization dictionaryValueWithJSON:item forKey:WXShareExtensionWebpage]];
        if (!page) return;
        WXMomentPicture *pic = [[WXMomentPicture alloc] initWithImage:page.thumbnail];
        if (![MNChatHelper.helper.cache setObject:pic forKey:pic.identifier]) return;
        WXMomentWebpage *webpage = WXMomentWebpage.new;
        webpage.title = page.title;
        webpage.url = page.url;
        webpage.img = pic.identifier;
        if (![MNDatabase.sharedInstance insertIntoTable:WXMomentWebpageTableName model:webpage]) return;
        WXMoment *moment = WXMoment.new;
        moment.uid = WXUser.shareInfo.uid;
        moment.source = @"网页分享";
        moment.location = @"";
        moment.privacy = NO;
        moment.content = [MNJSONSerialization stringValueWithJSON:item forKey:WXShareMomentText];
        moment.timestamp = [MNJSONSerialization stringValueWithJSON:item forKey:WXShareWebpageDate def:NSDateTimestamps()];
        moment.web = webpage.identifier;
        if (![MNDatabase.sharedInstance insertIntoTable:WXMomentTableName model:moment]) return;
        dispatch_async_main(^{
            @PostNotify(WXMomentAddNotificationName, moment);
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
                if ([MNAlertView.currentAlertView.titleText isEqualToString:@"AppleID已失效"]) return;
                [MNAlertView closeAlertView];
                [[MNAlertView alertViewWithTitle:@"AppleID已失效" message:@"请退出后重新登录!" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                    [self.window showWeChatDialogDelay:.3f eventHandler:^{
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
