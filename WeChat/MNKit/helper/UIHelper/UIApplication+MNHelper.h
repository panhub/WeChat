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

@interface UIApplication (MNHelper)
/**
 打开网页
 @param url NSURL/NSString
 @param handler 结果回调
 */
+ (void)handOpenUrl:(id)url completion:(UIApplicationOpenHandler)handler;

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
void UIApplicationIgnoringInteractionEvent (CGFloat duration);

/**
 强制退出应用程序
 */
void UIApplicationExit (void);

/**
 是否允许接收推送消息
 */
BOOL UIApplicationRemoteNotificationEnable (void);

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
