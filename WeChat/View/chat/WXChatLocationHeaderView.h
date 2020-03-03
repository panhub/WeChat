//
//  WXChatLocationHeaderView.h
//  MNChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天-位置 表头

#import "MNAdsorbView.h"
@class WXChatLocationHeaderView;

@protocol WXChatLocationHeaderViewDelegate <NSObject>

- (void)headerView:(WXChatLocationHeaderView *)headerView didUpdateUserLocation:(CLLocation *)location;

@end

@interface WXChatLocationHeaderView : MNAdsorbView

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, weak) id<WXChatLocationHeaderViewDelegate> delegate;

///经纬度
@property (nonatomic, strong) AMapGeoPoint *location;


- (void)takeSnapshotCompletion:(void(^)(UIImage *image))handler;

@end
