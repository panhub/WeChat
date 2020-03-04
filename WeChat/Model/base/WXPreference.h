//
//  WXPreference.h
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//  偏好设置

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXLoginType) {
    WXLoginTypeNone = 0,
    WXLoginTypeWeChat,
    WXLoginTypeApple
};

typedef NS_ENUM(NSInteger, WXMusicPlayStyle) {
    WXMusicPlayStyleDark = 0,
    WXMusicPlayStyleLight
};

typedef NS_ENUM(NSInteger, WXAppLaunchState) {
    WXAppLaunchStateUnknown = 0,
    WXAppLaunchStateFinish
};

@interface WXPreference : NSObject
/**
登录方式
*/
@property (nonatomic) WXLoginType loginType;
/**
 音乐播放器背景类型
 */
@property (nonatomic) WXMusicPlayStyle playStyle;
/**
 判断是否结束了启动图过程
 */
@property (nonatomic) WXAppLaunchState launchState;
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
 是否开启指纹支付
 */
@property (nonatomic, getter=isAllowsFingerprint) BOOL allowsFingerprint;

/**
 偏好设置实例化入口
*/
+ (instancetype)preference;

@end
