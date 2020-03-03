//
//  WXWeatherModel.h
//  MNKit
//
//  Created by Vincent on 2018/12/27.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXAirDataModel : NSObject

@property (nonatomic, copy) NSString *aqi;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *quality;
@property (nonatomic, copy) NSString *dateTime;

@end

@interface WXAirQualityModel : NSObject

@property (nonatomic, copy) NSString *aqi;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *no2;
@property (nonatomic, copy) NSString *pm10;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *quality;
@property (nonatomic, copy) NSString *so2;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, strong) NSArray <WXAirDataModel *>*fetureData;
@property (nonatomic, strong) NSArray <WXAirDataModel *>*hourData;

@end

@interface WXFutureModel : NSObject

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *dayTime;
@property (nonatomic, copy) NSString *night;
@property (nonatomic, copy) NSString *temperature;
@property (nonatomic, copy) NSString *week;
@property (nonatomic, copy) NSString *wind;

@end

@interface WXWeatherModel : NSObject

@property (nonatomic, copy) NSString *airCondition;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *coldIndex;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *distrct;
@property (nonatomic, copy) NSString *dressingIndex;
@property (nonatomic, copy) NSString *exerciseIndex;
@property (nonatomic, copy) NSString *humidity;
@property (nonatomic, copy) NSString *pollutionIndex;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *sunrise;
@property (nonatomic, copy) NSString *sunset;
@property (nonatomic, copy) NSString *temperature;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *washIndex;
@property (nonatomic, copy) NSString *weather;
@property (nonatomic, copy) NSString *week;
@property (nonatomic, copy) NSString *wind;
@property (nonatomic, strong) WXAirQualityModel *airQuality;
@property (nonatomic, strong) NSArray <WXFutureModel *>*future;

+ (instancetype)modelWithDic:(NSDictionary *)dictionary;

@end

