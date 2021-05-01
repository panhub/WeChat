//
//  WXLocation.h
//  WeChat
//
//  Created by Vincent on 2019/5/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXLocation : NSObject<NSSecureCoding, NSCopying>
/**纬度*/
@property (nonatomic, readonly) CLLocationDegrees latitude;
/**经度*/
@property (nonatomic, readonly) CLLocationDegrees longitude;
/**经纬编码*/
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
/**地点*/
@property (nonatomic, copy, nullable) NSString *name;
/**详细地址*/
@property (nonatomic, copy, nullable) NSString *address;
/**截图*/
@property (nonatomic, copy, nullable) UIImage *snapshot;

/**
 位置构造入口
 @param latitude 纬度
 @param longitude 经度
 @return 位置
 */
+ (instancetype)locationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

/**
 位置构造入口
 @param coordinate 系统位置
 @return 位置
 */
+ (instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 位置构造入口
 @param latitude 纬度
 @param longitude 经度
 @return 位置
*/
- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

/**
 位置构造入口
 @param coordinate 系统位置
 @return 位置
*/
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface NSString (WXLocationGeocode)

/**获取字符串描述的位置信息*/
@property (nonatomic, readonly, nullable) WXLocation *locationValue;

@end

NS_ASSUME_NONNULL_END
