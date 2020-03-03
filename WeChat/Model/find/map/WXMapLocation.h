//
//  WXMapLocation.h
//  MNChat
//
//  Created by Vincent on 2019/5/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WXMapLocation : NSObject<NSSecureCoding>
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) UIImage *snapshot;

/**
 微信位置构造入口
 @param latitude 纬度
 @param longitude 经度
 @return 微信位置
 */
+ (instancetype)pointWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

/**
 微信位置构造入口
 @param coordinate 系统位置
 @return 微信位置
 */
+ (instancetype)pointWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 微信位置构造入口
 @param latitude 纬度
 @param longitude 经度
 @return 微信位置
*/
- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

/**
 微信位置构造入口
 @param coordinate 系统位置
 @return 微信位置
*/
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
