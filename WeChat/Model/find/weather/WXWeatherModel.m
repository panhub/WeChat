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
    model.aqi = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"aqi"];
    model.date = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"date"];
    model.quality = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"quality"];
    model.dateTime = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"dateTime"];
    return model;
}

@end

@implementation WXAirQualityModel

+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    WXAirQualityModel *model = [WXAirQualityModel new];
    model.aqi = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"aqi"];
    model.city = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"city"];
    model.district = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"district"];
    model.no2 = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"no2"];
    model.pm10 = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"pm10"];
    model.province = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"province"];
    model.quality = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"quality"];
    model.so2 = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"so2"];
    model.updateTime = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"updateTime"];
    NSArray <NSDictionary *>*temp = [MNJSONSerialization arrayValueWithJSON:dictionary forKey:@"fetureData"];
    NSMutableArray <WXAirDataModel *>*array = [NSMutableArray arrayWithCapacity:temp.count];
    [temp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXAirDataModel *dataModel = [WXAirDataModel modelWithDic:obj];
        [array addObject:dataModel];
    }];
    model.fetureData = array.copy;
    temp = [MNJSONSerialization arrayValueWithJSON:dictionary forKey:@"hourData"];
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
    model.date = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"date"];
    model.dayTime = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"dayTime"];
    model.night = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"night"];
    model.temperature = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"temperature"];
    model.week = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"week"];
    model.wind = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"wind"];
    return model;
}

@end

@implementation WXWeatherModel

+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    WXWeatherModel *model = [WXWeatherModel new];
    model.airCondition = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"airCondition"];
    model.city = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"city"];
    model.coldIndex = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"coldIndex"];
    model.date = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"date"];
    model.distrct = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"distrct"];
    model.dressingIndex = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"dressingIndex"];
    model.exerciseIndex = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"exerciseIndex"];
    model.humidity = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"humidity"];
    model.pollutionIndex = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"pollutionIndex"];
    model.province = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"province"];
    model.sunrise = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"sunrise"];
    model.sunset = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"sunset"];
    model.temperature = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"temperature"];
    model.time = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"time"];
    model.updateTime = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"updateTime"];
    model.washIndex = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"washIndex"];
    model.weather = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"weather"];
    model.week = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"week"];
    model.wind = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"wind"];
    model.airQuality = [WXAirQualityModel modelWithDic:[MNJSONSerialization dictionaryValueWithJSON:dictionary forKey:@"airQuality"]];
    NSArray <NSDictionary *>*temp = [MNJSONSerialization arrayValueWithJSON:dictionary forKey:@"future"];
    NSMutableArray <WXFutureModel *>*future = [NSMutableArray arrayWithCapacity:temp.count];
    [temp enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXFutureModel *dataModel = [WXFutureModel modelWithDic:obj];
        [future addObject:dataModel];
    }];
    model.future = future.copy;
    return model;
}

@end
