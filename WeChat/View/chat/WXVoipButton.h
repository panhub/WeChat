//
//  WXVoipButton.h
//  WeChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//  微信语音通话按钮

#import <UIKit/UIKit.h>

/**
 外界标记拨打/接收
 - WXVoipStyleSend 拨打
 - WXVoipStyleReceive 接受
 */
typedef NS_ENUM(NSInteger, WXVoipStyle) {
    WXVoipStyleSend = 0,
    WXVoipStyleReceive
};

/**
外界获取是否接通
- WXVoipStateWaiting 等待中
- WXVoipStateAnswer 已接通
- WXVoipStateRefuse 拒绝
- WXVoipStateDecline 挂断
*/
typedef NS_ENUM(NSInteger, WXVoipState) {
    WXVoipStateWaiting = 0,
    WXVoipStateAnswer,
    WXVoipStateRefuse,
    WXVoipStateDecline
};

@interface WXVoipButton : UIControl

/**背景图*/
@property (nonatomic, copy) UIImage *image;

/**选择图*/
@property (nonatomic, copy) UIImage *selectedImage;

/**标题*/
@property (nonatomic, copy) NSString *title;

@end
