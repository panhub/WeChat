//
//  WXPreference.h
//  WeChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//  偏好设置

#import <Foundation/Foundation.h>
//
typedef NS_ENUM(NSInteger, WXLoginPolicy) {
    WXLoginPolicyNone = 0,
    WXLoginPolicyAccount,
    WXLoginPolicyApple
};

typedef NS_ENUM(NSInteger, WXPlayStyle) {
    WXPlayStyleDark = 0,
    WXPlayStyleLight
};

typedef NS_ENUM(NSInteger, WXLaunchState) {
    WXLaunchStateLoading = 0,
    WXLaunchStateCompleted
};

@interface WXPreference : NSObject
/**
登录方式
*/
@property (nonatomic) WXLoginPolicy loginPolicy;
/**
 音乐播放器背景类型
 */
@property (nonatomic) WXPlayStyle playStyle;
/**
 判断是否结束了启动图过程
 */
@property (nonatomic) WXLaunchState launchState;
/**
 需要加载的控制器
 */
@property (nonatomic, copy) NSString *next_cls;
/**
 零钱
 */
@property (nonatomic, copy) NSString *money;
/**
 支付密码
 */
@property (nonatomic, copy) NSString *payword;
/**
 摇一摇背景图片
 */
@property (nonatomic, copy) UIImage *shakeBackgroundImage;
/**
 摇一摇音效
*/
@property (nonatomic, getter=isAllowsShakeSound) BOOL allowsShakeSound;
/**
 是否允许调试<显示调试悬浮窗>
 */
@property (nonatomic, getter=isAllowsDebug) BOOL allowsDebug;
/**
 是否开启本地支付验证
 */
@property (nonatomic, getter=isAllowsLocalEvaluation) BOOL allowsLocalEvaluation;

/**
 偏好设置实例化入口
*/
+ (instancetype)preference;



@end
