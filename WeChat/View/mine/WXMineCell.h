//
//  WXMineCell.h
//  MNChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMineCell : MNTableViewCell

@property (nonatomic, weak) WXDataValueModel *model;

@end

NS_ASSUME_NONNULL_END
