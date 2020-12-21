//
//  WXSendCardAlertView.h
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//  推荐联系人弹窗

#import <UIKit/UIKit.h>
@class WXUser, WXSendCardAlertView;

@interface WXSendCardAlertView : UIView
/**名片联系人*/
@property (nonatomic, strong) WXUser *user;
/**发送给联系人*/
@property (nonatomic, strong) WXUser *toUser;
/**发送信息*/
@property (nonatomic, readonly) NSString *text;
/**用户点击回调*/
@property (nonatomic, copy) void(^userClickHandler)(WXSendCardAlertView *);

/**
 展示名片发送弹窗
 @param completionHandler 确定事件回调
 */
- (void)showWithCompletionHandler:(void(^)(WXSendCardAlertView *alertView))completionHandler;
/**
 在指定视图上展示名片发送弹窗
 @param superview 指定视图
 @param completionHandler 确定事件回调
 */
- (void)showInView:(UIView *)superview completionHandler:(void(^)(WXSendCardAlertView *alertView))completionHandler;

@end
