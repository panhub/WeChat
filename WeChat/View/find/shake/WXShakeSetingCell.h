//
//  WXShakeSetingCell.h
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//  摇一摇设置Cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

@interface WXShakeSetingCell : MNTableViewCell
/**数据模型*/
@property (nonatomic, strong) WXDataValueModel *model;
/**值变化回调*/
@property (nonatomic, copy) void(^valueChangedHandler)(BOOL isOn);
@end
