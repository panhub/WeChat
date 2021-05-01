//
//  WXLocationResultController.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置搜索控制器

#import "MNListViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
@class WXLocation;

@interface WXLocationResultController : MNListViewController<MNSearchResultUpdating>

/// 城市
@property (nonatomic, copy) NSString *city;

/// 经纬度
@property (nonatomic) CLLocationCoordinate2D coordinate;

/// 选择回调
@property (nonatomic, copy) void (^didSelectHandler) (WXLocation *location);

@end
