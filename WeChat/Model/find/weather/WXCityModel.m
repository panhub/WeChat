//
//  WXCityModel.m
//  MNKit
//
//  Created by Vincent on 2018/12/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "WXCityModel.h"

@implementation WXDistrictModel
+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    NSString *district = [NSDictionary stringValueWithDictionary:dictionary forKey:@"district"];
    if (district.length <= 0) return nil;
    WXDistrictModel *model = [WXDistrictModel new];
    model.name = district;
    return model;
}

@end

@implementation WXCityModel
+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    NSString *city = [NSDictionary stringValueWithDictionary:dictionary forKey:@"city"];
    if (city.length <= 0) return nil;
    NSArray <NSDictionary *>*districts = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"district"];
    NSMutableArray <WXDistrictModel *>*dataSource = [NSMutableArray arrayWithCapacity:districts.count];
    [districts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXDistrictModel *model = [WXDistrictModel modelWithDic:obj];
        model.city = city;
        if (model) [dataSource addObject:model];
    }];
    if (dataSource.count <= 0) return nil;
    WXCityModel *model = [WXCityModel new];
    model.name = city;
    model.dataSource = dataSource.copy;
    return model;
}

@end

@implementation WXProvinceModel
+ (instancetype)modelWithDic:(NSDictionary *)dictionary {
    NSString *province = [NSDictionary stringValueWithDictionary:dictionary forKey:@"province"];
    if (province.length <= 0) return nil;
    NSArray <NSDictionary *>*citys = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"city"];
    NSMutableArray <WXCityModel *>*dataSource = [NSMutableArray arrayWithCapacity:citys.count];
    [citys enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCityModel *model = [WXCityModel modelWithDic:obj];
        model.province = province;
        if (model) [dataSource addObject:model];
    }];
    if (dataSource.count <= 0) return nil;
    WXProvinceModel *model = [WXProvinceModel new];
    model.name = province;
    model.dataSource = dataSource.copy;
    return model;
}

@end




