//
//  WXLocationViewController.h
//  MNChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置

#import "MNSearchViewController.h"
#import "WXMapLocation.h"

@interface WXChatLocationController : MNSearchViewController
/**
 地点选择回调
 @param location 位置信息封装
 */
@property (nonatomic, copy) void (^didSelectHandler) (WXMapLocation *location);

@end
