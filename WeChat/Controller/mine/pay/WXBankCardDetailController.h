//
//  WXBankCardDetailController.h
//  WeChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//  银行卡详情

#import "MNListViewController.h"
@class WXBankCard;

NS_ASSUME_NONNULL_BEGIN

@interface WXBankCardDetailController : MNListViewController

- (instancetype)initWithCard:(WXBankCard *)card;

@end

NS_ASSUME_NONNULL_END
