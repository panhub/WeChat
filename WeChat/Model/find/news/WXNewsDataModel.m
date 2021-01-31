//
//  WXNewsDataModel.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsDataModel.h"

@implementation WXNewsDataModel
+ (WXNewsDataModel *)modelWithDictionary:(NSDictionary *)dictionary {
    WXNewsDataModel *m = WXNewsDataModel.new;
    m.title = [NSDictionary stringValueWithDictionary:dictionary forKey:@"title" def:@""];
    m.date = [NSDictionary stringValueWithDictionary:dictionary forKey:@"date" def:@""];
    m.category = [NSDictionary stringValueWithDictionary:dictionary forKey:@"category" def:@""];
    m.author = [NSDictionary stringValueWithDictionary:dictionary forKey:@"author_name" def:@""];
    m.url = [NSDictionary stringValueWithDictionary:dictionary forKey:@"url" def:@""];
    NSString *thumbnail_pic_s = [NSDictionary stringValueWithDictionary:dictionary forKey:@"thumbnail_pic_s" def:@""];
    NSString *thumbnail_pic_s02 = [NSDictionary stringValueWithDictionary:dictionary forKey:@"thumbnail_pic_s02" def:@""];
    NSString *thumbnail_pic_s03 = [NSDictionary stringValueWithDictionary:dictionary forKey:@"thumbnail_pic_s03" def:@""];
    NSMutableArray <NSString *>*imgs = @[].mutableCopy;
    if (thumbnail_pic_s.length) [imgs addObject:thumbnail_pic_s];
    if (thumbnail_pic_s02.length) [imgs addObject:thumbnail_pic_s02];
    if (thumbnail_pic_s03.length) [imgs addObject:thumbnail_pic_s03];
    m.imgs = imgs.count ? imgs : nil;
    return m;
}

@end
