//
//  WXBankCardAlertViewCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//  选择银行卡弹窗Cell

#import "MNTableViewCell.h"
@class WXBankCard;

@interface WXBankCardAlertViewCell : MNTableViewCell

/**
 是否是取钱
 */
@property (nonatomic) BOOL withdraw;
/**
 银行卡
 */
@property (nonatomic, strong) WXBankCard *card;

@end

