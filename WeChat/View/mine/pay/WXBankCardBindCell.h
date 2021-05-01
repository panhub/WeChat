//
//  WXBankCardBindCell.h
//  WeChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//  绑定银行卡Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

@interface WXBankCardBindCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@end
