//
//  WXEditUserInfoCell.h
//  WeChat
//
//  Created by Vincent on 2019/3/23.
//  Copyright © 2019 Vincent. All rights reserved.
//  编辑用户资料列表

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXEditUserInfoCell : MNTableViewCell

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, strong) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
