//
//  WXAuthListCell.h
//  WeChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//  认证Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXAuthListCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@property (nonatomic) NSInteger section;

@end

NS_ASSUME_NONNULL_END
