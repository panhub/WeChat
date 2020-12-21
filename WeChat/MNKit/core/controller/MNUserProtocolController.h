//
//  MNUserProtocolController.h
//  MNKit
//
//  Created by Vicent on 2020/10/18.
//  用户协议控制器

#import "MNWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNUserProtocolController : MNWebViewController

/**
 展示弹窗控制器
 @param userProtocolURL 用户协议
 @param privacyProtocolURL 隐私协议
 @param saveForKey 判断是否满足弹出条件
 */
+ (void)presentWithUserProtocolURL:(NSURL *_Nullable)userProtocolURL privacyProtocolURL:(NSURL *_Nullable)privacyProtocolURL forKey:(NSString *_Nullable)saveForKey;

/**
 展示弹窗控制器
 @param viewControllerToPresent 父控制器
 @param userProtocolURL 用户协议
 @param privacyProtocolURL 隐私协议
 @param saveForKey 判断是否满足弹出条件
 */
+ (void)presentInController:(UIViewController *_Nullable)viewControllerToPresent userProtocolURL:(NSURL *_Nullable)userProtocolURL privacyProtocolURL:(NSURL *_Nullable)privacyProtocolURL forKey:(NSString *_Nullable)saveForKey;

@end

NS_ASSUME_NONNULL_END
