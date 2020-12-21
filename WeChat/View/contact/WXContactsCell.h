//
//  WXContactsCell.h
//  MNChat
//
//  Created by Vincent on 2019/3/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  联系人列表

#import "MNTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXContactsCell : MNTableViewCell

@property (nonatomic, strong) WXUser *user;

@property (nonatomic, getter=isMultipleSelectEnabled) BOOL multipleSelectEnabled;

- (void)setMultipleSelectEnabled:(BOOL)multipleSelectEnabled animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
