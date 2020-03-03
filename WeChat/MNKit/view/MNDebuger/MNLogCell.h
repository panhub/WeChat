//
//  MNLogCell.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNTableViewCell.h"
@class MNLogModel;

NS_ASSUME_NONNULL_BEGIN

@interface MNLogCell : MNTableViewCell

@property (nonatomic, strong) MNLogModel *model;

@end

NS_ASSUME_NONNULL_END
