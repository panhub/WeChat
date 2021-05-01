//
//  WXAddUserInfoCell.h
//  WeChat
//
//  Created by Vincent on 2019/4/6.
//  Copyright © 2019 Vincent. All rights reserved.
//  添加用户

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXAddUserInfoCell : MNTableViewCell

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, strong) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
