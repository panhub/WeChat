//
//  WXBankCardAlertView.h
//  WeChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//  选择银行卡弹窗

#import <UIKit/UIKit.h>
#import "WXBankCard.h"
@class WXBankCardAlertView;

typedef NS_ENUM(NSInteger, WXBankCardAlertViewType) {
    WXBankCardAlertViewRecharge = 0,
    WXBankCardAlertViewWithdraw
};

@protocol WXBankCardAlertViewDelegate <NSObject>

- (void)alertViewNeedsAddNewCard:(WXBankCardAlertView *)alertView;

- (void)alertView:(WXBankCardAlertView *)alertView didSelectCard:(WXBankCard *)card;

@end

@interface WXBankCardAlertView : UIView

@property (nonatomic) WXBankCardAlertViewType type;

@property (nonatomic, weak) id<WXBankCardAlertViewDelegate> delegate;

- (void)show;

- (void)dismiss;

@end
