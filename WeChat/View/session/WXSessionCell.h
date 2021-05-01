//
//  WXSessionCell.h
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  会话列表cell

#import "MNTableViewCell.h"
@class WXSession;

@interface WXSessionCell : MNTableViewCell

@property (nonatomic, strong) WXSession *session;

@end
