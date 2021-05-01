//
//  WXDataValueCell.h
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  资料设置Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXDataValueCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@property (nonatomic, strong, readonly) UISwitch *switchButton;

@property (nonatomic, copy) void(^valueChangedHandler)(NSIndexPath *indexPath, BOOL isOn);

@end

NS_ASSUME_NONNULL_END
