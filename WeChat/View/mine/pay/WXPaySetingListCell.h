//
//  WXPaySetingListCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//  支付设置Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXPaySetingListCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@property (nonatomic, copy) void (^valueDidChangeHandler) (BOOL isOn);

@end

NS_ASSUME_NONNULL_END
