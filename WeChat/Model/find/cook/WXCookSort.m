//
//  WXCookSort.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookSort.h"

@implementation WXCookMenu
+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    WXCookMenu *model = [WXCookMenu new];
    model.cid = [NSDictionary stringValueWithDictionary:dic forKey:@"id"];
    model.name = [NSDictionary stringValueWithDictionary:dic forKey:@"name"];
    return model;
}
@end

@implementation WXCookSort
+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    WXCookSort *model = [WXCookSort new];
    model.cid = [NSDictionary stringValueWithDictionary:dic forKey:@"id"];
    model.title = [NSDictionary stringValueWithDictionary:dic forKey:@"name"];
    NSMutableArray <WXCookMenu *>*array = @[].mutableCopy;
    NSArray <NSDictionary *>*list = [NSDictionary arrayValueWithDictionary:dic forKey:@"list"];
    [list enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookMenu *m = [WXCookMenu modelWithDictionary:obj];
        [array addObject:m];
    }];
    model.list = array.copy;
    return model;
}

@end
