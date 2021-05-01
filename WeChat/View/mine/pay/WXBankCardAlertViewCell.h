//
//  WXBankCardAlertViewCell.h
//  WeChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//  选择银行卡弹窗Cell

#import "WXTableViewCell.h"
@class WXBankCard;

@interface WXBankCardAlertViewCell : WXTableViewCell

/**
 是否是取钱
 */
@property (nonatomic) BOOL withdraw;
/**
 银行卡
 */
@property (nonatomic, strong) WXBankCard *card;

@end

