//
//  WXPasswordAlertView.h
//  WeChat
//
//  Created by Vincent on 2019/5/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账 - 密码弹窗

#import <UIKit/UIKit.h>
@class WXPasswordAlertView;

@protocol WXPasswordAlertViewDelegate <NSObject>

- (void)passwordAlertViewDidSucceed:(WXPasswordAlertView *)alertView;

@end

@interface WXPasswordAlertView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, weak) id<WXPasswordAlertViewDelegate> delegate;

- (void)show;

- (void)dismiss;

@end
