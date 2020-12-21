//
//  WXWeatherModel.m
//  MNKit
//
//  Created by Vincent on 2018/12/27.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "WXWeatherModel.h"

@implementation WXAirDataModel

+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    WXAirDataModel *model = [WXAirDataModel new];
    model.aqi = [NSDictionary stringValueWithDictionary:dictionary forKey:@"aqi"];
    model.date = [NSDictionary stringValueWithDictionary:dictionary forKey:@"date"];
    model.quality = [NSDictionary stringValueWithDictionary:dictionary forKey:@"quality"];
    model.dateTime = [NSDictionary stringValueWithDictionary:dictionary forKey:@"dateTime"];
    return model;
}

@end

@implementation WXAirQualityModel

+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    WXAirQualityModel *model = [WXAirQualityModel new];
    model.aqi = [NSDictionary stringValueWithDictionary:dictionary forKey:@"aqi"];
    model.city = [NSDictionary stringValueWithDictionary:dictionary forKey:@"city"];
    model.district = [NSDictionary stringValueWithDictionary:dictionary forKey:@"district"];
    model.no2 = [NSDictionary stringValueWithDictionary:dictionary forKey:@"no2"];
    model.pm10 = [NSDictionary stringValueWithDictionary:dictionary forKey:@"pm10"];
    model.province = [NSDictionary stringValueWithDictionary:dictionary forKey:@"province"];
    model.quality = [NSDictionary stringValueWithDictionary:dictionary forKey:@"quality"];
    model.so2 = [NSDictionary stringValueWithDictionary:dictionary forKey:@"so2"];
    model.updateTime = [NSDictionary stringValueWithDictionary:dictionary forKey:@"updateTime"];
    NSArray <NSDictionary *>*temp = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"fetureData"];
    NSMutableArray <WXAirDataModel *>*array = [NSMutableArray arrayWithCapacity:temp.count];
    [temp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXAirDataModel *dataModel = [WXAirDataModel modelWithDic:obj];
        [array addObject:dataModel];
    }];
    model.fetureData = array.copy;
    temp = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"hourData"];
    [array removeAllObjects];
    [temp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXAirDataModel *dataModel = [WXAirDataModel modelWithDic:obj];
        [array addObject:dataModel];
    }];
    model.hourData = array.copy;
    return model;
}

@end

@implementation WXFutureModel

+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    WXFutureModel *model = [WXFutureModel new];
    model.date = [NSDictionary stringValueWithDictionary:dictionary forKey:@"date"];
    model.dayTime = [NSDictionary stringValueWithDictionary:dictionary forKey:@"dayTime"];
    model.night = [NSDictionary stringValueWithDictionary:dictionary forKey:@"night"];
    model.temperature = [NSDictionary stringValueWithDictionary:dictionary forKey:@"temperature"];
    model.week = [NSDictionary stringValueWithDictionary:dictionary forKey:@"week"];
    model.wind = [NSDictionary stringValueWithDictionary:dictionary forKey:@"wind"];
    return model;
}

@end

@implementation WXWeatherModel

+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    WXWeatherModel *model = [WXWeatherModel new];
    model.airCondition = [NSDictionary stringValueWithDictionary:dictionary forKey:@"airCondition"];
    model.city = [NSDictionary stringValueWithDictionary:dictionary forKey:@"city"];
    model.coldIndex = [NSDictionary stringValueWithDictionary:dictionary forKey:@"coldIndex"];
    model.date = [NSDictionary stringValueWithDictionary:dictionary forKey:@"date"];
    model.distrct = [NSDictionary stringValueWithDictionary:dictionary forKey:@"distrct"];
    model.dressingIndex = [NSDictionary stringValueWithDictionary:dictionary forKey:@"dressingIndex"];
    model.exerciseIndex = [NSDictionary stringValueWithDictionary:dictionary forKey:@"exerciseIndex"];
    model.humidity = [NSDictionary stringValueWithDictionary:dictionary forKey:@"humidity"];
    model.pollutionIndex = [NSDictionary stringValueWithDictionary:dictionary forKey:@"pollutionIndex"];
    model.province = [NSDictionary stringValueWithDictionary:dictionary forKey:@"province"];
    model.sunrise = [NSDictionary stringValueWithDictionary:dictionary forKey:@"sunrise"];
    model.sunset = [NSDictionary stringValueWithDictionary:dictionary forKey:@"sunset"];
    model.temperature = [NSDictionary stringValueWithDictionary:dictionary forKey:@"temperature"];
    model.time = [NSDictionary stringValueWithDictionary:dictionary forKey:@"time"];
    model.updateTime = [NSDictionary stringValueWithDictionary:dictionary forKey:@"updateTime"];
    model.washIndex = [NSDictionary stringValueWithDictionary:dictionary forKey:@"washIndex"];
    model.weather = [NSDictionary stringValueWithDictionary:dictionary forKey:@"weather"];
    model.week = [NSDictionary stringValueWithDictionary:dictionary forKey:@"week"];
    model.wind = [NSDictionary stringValueWithDictionary:dictionary forKey:@"wind"];
    model.airQuality = [WXAirQualityModel modelWithDic:[NSDictionary dictionaryValueWithDictionary:dictionary forKey:@"airQuality"]];
    NSArray <NSDictionary *>*temp = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"future"];
    NSMutableArray <WXFutureModel *>*future = [NSMutableArray arrayWithCapacity:temp.count];
    [temp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXFutureModel *dataModel = [WXFutureModel modelWithDic:obj];
        [future addObject:dataModel];
    }];
    model.future = future.copy;
    return model;
}

@end
