//
//  WXChangePasswordCell.h
//  MNChat
//
//  Created by Vincent on 2019/8/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXChangePasswordCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

- (void)setModel:(WXDataValueModel *)model row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
