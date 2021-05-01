//
//  WXBankCardView.h
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱 充值/提现 当前银行卡视图

#import <UIKit/UIKit.h>
@class WXBankCard;

typedef NS_ENUM(NSInteger, WXBankCardViewType) {
    WXBankCardViewRecharge = 0,
    WXBankCardViewWithdraw
};

@interface WXBankCardView : UIView

@property (nonatomic, strong) WXBankCard *card;

@property (nonatomic) WXBankCardViewType type;

@end
