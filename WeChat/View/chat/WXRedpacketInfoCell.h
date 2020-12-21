//
//  WXRedpacketInfoCell.h
//  MNChat
//
//  Created by Vincent on 2019/5/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包详情表格

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXRedpacketInfoCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
