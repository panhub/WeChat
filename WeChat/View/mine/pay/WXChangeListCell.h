//
//  WXChangeListCell.h
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱 List Cell

#import "MNTableViewCell.h"
@class WXChangeModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXChangeListCell : MNTableViewCell

@property (nonatomic, strong) WXChangeModel *model;

@end

NS_ASSUME_NONNULL_END
