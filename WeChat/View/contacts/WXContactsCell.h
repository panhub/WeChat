//
//  WXContactsCell.h
//  WeChat
//
//  Created by Vincent on 2019/3/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  联系人列表

#import "WXTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXContactsCell : WXTableViewCell

/**用户模型*/
@property (nonatomic, strong) WXUser *user;

/**是否支持多选*/
@property (nonatomic, getter=isMultipleSelectEnabled) BOOL multipleSelectEnabled;

/**设置是否支持多选*/
- (void)setMultipleSelectEnabled:(BOOL)multipleSelectEnabled animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
