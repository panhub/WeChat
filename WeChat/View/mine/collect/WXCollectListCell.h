//
//  WXCollectListCell.h
//  MNChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  收藏

#import "MNTableViewCell.h"
@class WXWebpage;

NS_ASSUME_NONNULL_BEGIN

@interface WXCollectListCell : MNTableViewCell

@property (nonatomic, unsafe_unretained) WXWebpage *model;

@end

NS_ASSUME_NONNULL_END
