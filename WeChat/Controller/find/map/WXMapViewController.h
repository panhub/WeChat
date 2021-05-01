//
//  WXMapViewController.h
//  WeChat
//
//  Created by Vincent on 2019/5/16.
//  Copyright © 2019 Vincent. All rights reserved.
//  地图

#import "MNBaseViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "WXLocation.h"

@interface WXMapViewController : MNBaseViewController

/**
 实例化地图控制器
 @param coordinate 经纬信息
 @return 地图控制器
 */
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 实例化地图控制器
 @param location 位置信息
 @return 地图控制器
 */
- (instancetype)initWithLocation:(WXLocation *)location;

@end
