//
//  WXLabelCell.h
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  标签

#import "MNTableViewCell.h"
@class WXLabel;

NS_ASSUME_NONNULL_BEGIN

@interface WXLabelCell : MNTableViewCell

/**数据*/
@property (nonatomic, strong) WXLabel *label;

@end

NS_ASSUME_NONNULL_END
