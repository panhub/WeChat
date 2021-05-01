//
//  Macro.h
//  WeChat
//
//  Created by Vicent on 2020/3/3.
//  Copyright © 2020 Vincent. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

/// 项目ID
#define AppleID @"1448104087"
/// 审核时间
#define REVIEW_TIME     @"2019-11-30"
/// Mob
#define MobAppKey   @"2b056fb118960"
#define MobAppSecret   @"5941c0a3c72df403e285166c29580e80"
/// 高德
#define AMapAppKey  @"6ef6af8f5510a1940068fb4900158960"
/// 友盟
#define UMengAppKey @"5d2d992f0cafb210530002d0"
/// 代理简化
#define AppDelegate   ((WechatDelegate *)[[UIApplication sharedApplication] delegate])
/// 背景色
#define VIEW_COLOR   MN_RGB(237.f)
/// 主题色
#define THEME_COLOR  MN_R_G_B(7.f, 192.f, 96.f)
/// 阴影线颜色
#define SEPARATOR_COLOR   MN_RGB(237.f)
/// 消息背景色
#define BADGE_COLOR  MN_R_G_B(249.f, 81.f, 81.f)
/// 字体颜色
#define TEXT_COLOR   MN_R_G_B(87.f, 106.f, 149.f)
/// 金额数字字体
#define SansFontRegular(fontSize)    [UIFont fontWithName:@"WeChat-Sans-Std-Regular" size:fontSize]
#define SansFontBold(fontSize)    [UIFont fontWithName:@"WeChat-Sans-Std-Bold" size:fontSize]
#define SansFontMedium(fontSize)    [UIFont fontWithName:@"WeChat-Sans-Std-Medium" size:fontSize]
/// 默认地区
#define WXUserDefaultLocation   @"中国 重庆"
/// 资源包
#define WeChatBundle  [NSBundle bundleWithName:@"WeChat"]
/// 苹果登录用户名Key
#define AppleUserIdentifier    @"com.apple.user.identifier"

/// GroupID
#define ShareGroupID    @"group.com.mn.chat.share"
#define TodayGroupID    @"group.com.mn.chat.today"

/// 登录通知名
#define kLoginLastUsername @"com.wx.last.username.key"
#define LOGIN_NOTIFY_NAME   @"com.wx.login.notification.name"
#define LOGOUT_NOTIFY_NAME   @"com.wx.logout.notification.name"

/// 去水印相关
#define kVideoToken @"com.zm.token.key"

#endif /* Macro_h */
