//
//  WXAppletListCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXAppletListCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
