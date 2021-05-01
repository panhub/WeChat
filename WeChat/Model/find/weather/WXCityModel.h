//
//  WXCityModel.h
//  MNKit
//
//  Created by Vincent on 2018/12/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 县 地区
 */
@interface WXDistrictModel : NSObject

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *name;

@end

/**
 城市
 */
@interface WXCityModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, strong) NSArray <WXDistrictModel *>*dataSource;

@end

/**
 省
 */
@interface WXProvinceModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray <WXCityModel *>*dataSource;

+ (instancetype)modelWithDic:(NSDictionary *)dictionary;

@end






