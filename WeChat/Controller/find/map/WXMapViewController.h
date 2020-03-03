//
//  WXMapViewController.h
//  MNChat
//
//  Created by Vincent on 2019/5/16.
//  Copyright © 2019 Vincent. All rights reserved.
//  地图

#import "MNBaseViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "WXMapLocation.h"

@interface WXMapViewController : MNBaseViewController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (instancetype)initWithPoint:(WXMapLocation *)point;

@end
