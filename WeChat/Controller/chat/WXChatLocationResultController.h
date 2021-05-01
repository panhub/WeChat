//
//  WXChatLocationResultController.h
//  WeChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置搜索结果

#import "MNListViewController.h"

@interface WXChatLocationResultController : MNListViewController<MNSearchResultUpdating>

/// 经纬度
@property (nonatomic) CLLocationCoordinate2D coordinate;

/// 选择回调
@property (nonatomic, copy) void (^didSelectHandler) (NSString *name, NSString *address, AMapGeoPoint *location);

@end
