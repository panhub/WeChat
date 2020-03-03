//
//  WXLocationResultController.h
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置搜索控制器

#import "MNListViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
@class WXMapLocation;

@interface WXLocationResultController : MNListViewController<MNSearchResultUpdating>

/// 位置信息
@property (nonatomic, strong) AMapGeoPoint *location;
@property (nonatomic, strong) AMapLocationReGeocode *address;

/// 选择回调
@property (nonatomic, copy) void (^didSelectHandler) (WXMapLocation *location);

@end
