//
//  WXChangeInfoCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱 Info Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXChangeInfoCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
