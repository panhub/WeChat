//
//  UIApplication+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/12/10.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 应用名类型
 - UIApplicationSourceQQ: QQ
 - UIApplicationSourceQQGroup: QQ群
 - UIApplicationSourceWechat: 微信
 - UIApplicationSourceSina: 新浪微博
 - UIApplicationSourceAlipay: 支付宝
 - UIApplicationSourceTaobao: 淘宝
 - UIApplicationSourceTmall: 天猫
 - UIApplicationSourceJD: 京东
 - UIApplicationSourceMeituan: 美团
 - UIApplicationSourceDingtalk: 钉钉
 */
typedef NS_ENUM(NSInteger, UIApplicationSourceType) {
    UIApplicationSourceQQ = 0,
    UIApplicationSourceQQGroup,
    UIApplicationSourceWechat,
    UIApplicationSourceSina,
    UIApplicationSourceAlipay,
    UIApplicationSourceTaobao,
    UIApplicationSourceTmall,
    UIApplicationSourceJD,
    UIApplicationSourceMeituan,
    UIApplicationSourceDingtalk
};

/**
 打开AppStore的方式
 - AppStoreLoadInlay: 应用内打开
 - AppStoreLoadOpen: 跳转到AppStore
 */
typedef NS_ENUM(NSInteger, AppStoreLoadType) {
    AppStoreLoadInlay,
    AppStoreLoadOpen
};

/**
 定义跳转结果回调
 @param succeed 是否跳转成功
 */
typedef void(^UIApplicationOpenHandler)(BOOL succeed);

#define MN_STATUS_BAR_HEIGHT  UIApplication.statusBarHeight

@interface UIApplication (MNHelper)

/**线程安全的获取状态栏高度*/
@property (nonatomic, class, readonly) CGFloat statusBarHeight;

/**
 打开网页
 @param url NSURL/NSString
 @param handler 结果回调
 */
+ (void)handOpenUrl:(id)url completion:(UIApplicationOpenHandler)handler;

/**
 打开QQ群
 @param group 指定群
 @param key QQ群配置
 @param handler 结果回调
 */
+ (void)handOpenQQGroup:(NSString *)group withKey:(NSString *)key completion:(UIApplicationOpenHandler)handler;

/**
 打开QQ聊天界面
 @param account QQ号
 @param handler 结果回调
 */
+ (void)handOpenQQUser:(NSString *)account completion:(UIApplicationOpenHandler)handler;

/**
 打开应用
 @param type 指定类型
 @param handler 结果回调
 */
+ (void)handOpen:(UIApplicationSourceType)type completion:(UIApplicationOpenHandler)handler;

/**
 判断是否可以打开应用
 @param type 应用名(类型)
 @return 返回判断结果
 */
+ (BOOL)canOpen:(UIApplicationSourceType)type;

/**
 获取应用白名单
 @param type 应用名(类型)
 @return 白名单配置
 */
+ (NSString *)sourceScheme:(UIApplicationSourceType)type;

/**
 获取应用url
 @param type 应用名(类型)
 @return 应用url
 */
+ (NSString *)sourceUrl:(UIApplicationSourceType)type;

/**
 打开AppStore评分界面
 @param appleID 应用id
 @param type 打开方式
 @param handler 结果回调
 */
+ (void)handOpenProductScore:(NSString *)appleID
                        type:(AppStoreLoadType)type
                  completion:(UIApplicationOpenHandler)handler;

/**
 打开AppStore下载界面
 @param appleID 应用id
 @param type 打开方式
 @param handler 结果回调
 */
+ (void)handOpenProduct:(NSString *)appleID
                   type:(AppStoreLoadType)type
             completion:(UIApplicationOpenHandler)handler;


/**
 忽略触摸事件
 @param duration 间隔时间恢复
 */
UIKIT_EXTERN void UIApplicationIgnoringInteractionEvent (CGFloat duration);

/**
 强制退出应用程序
 */
UIKIT_EXTERN void UIApplicationExit (void);

/**
 是否允许接收推送消息
 */
UIKIT_EXTERN BOOL UIApplicationRemoteNotificationEnable (void);

/**
 是否是主程序
 @return 判断结果
 */
+ (BOOL)isExtension;

/**
 获取主程序
 @return 主程序
 */
+ (UIApplication *)shared_application;


@end
