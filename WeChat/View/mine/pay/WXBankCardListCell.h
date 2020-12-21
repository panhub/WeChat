//
//  WXBankCardListCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//  绑定银行卡 List Cell

#import "MNTableViewCell.h"
@class WXBankCard;

NS_ASSUME_NONNULL_BEGIN

@interface WXBankCardListCell : MNTableViewCell

@property (nonatomic, strong) WXBankCard *card;

@end

NS_ASSUME_NONNULL_END
