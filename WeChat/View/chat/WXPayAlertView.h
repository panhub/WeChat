//
//  WXPayAlertView.h
//  WeChat
//
//  Created by Vincent on 2019/5/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账 - 支付弹窗

#import <UIKit/UIKit.h>
@class WXPayAlertView;

@protocol WXPayAlertViewDelegate <NSObject>

- (void)payAlertViewShouldNeedPassword:(WXPayAlertView *)alertView;

- (void)payAlertViewShouldPayment:(WXPayAlertView *)alertView;

@end

@interface WXPayAlertView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, weak) id<WXPayAlertViewDelegate> delegate;

- (void)show;

- (void)dismiss;

@end
