//
//  WXTableViewCell.h
//  WeChat
//
//  Created by Vicent on 2021/3/25.
//  Copyright © 2021 Vincent. All rights reserved.
//  解决新版分割线问题

#import "MNTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXTableViewCell : MNTableViewCell

/**顶部分割线约束*/
@property (nonatomic) UIEdgeInsets topSeparatorInset;

/**底部分割线约束*/
@property (nonatomic) UIEdgeInsets bottomSeparatorInset;

@end

NS_ASSUME_NONNULL_END
