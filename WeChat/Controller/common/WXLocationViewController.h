//
//  WXLocationViewController.h
//  MNChat
//
//  Created by Vincent on 2019/5/11.
//  Copyright © 2019 Vincent. All rights reserved.
//  选择位置

#import "MNSearchViewController.h"
#import "WXMapLocation.h"

@interface WXLocationViewController : MNSearchViewController

/// 地点选择回调
@property (nonatomic, copy) void (^didSelectHandler) (WXMapLocation *location);

@end
