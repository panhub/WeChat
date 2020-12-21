//
//  WXCookSort.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookSort.h"

@implementation WXCookName
+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    NSDictionary *categoryInfo = [NSDictionary dictionaryValueWithDictionary:dic forKey:@"categoryInfo"];
    NSString *cid = [NSDictionary stringValueWithDictionary:categoryInfo forKey:@"ctgId"];
    NSString *name = [NSDictionary stringValueWithDictionary:categoryInfo forKey:@"name"];
    NSString *parent = [NSDictionary stringValueWithDictionary:categoryInfo forKey:@"parentId"];
    if (cid.length <= 0 || name.length <= 0) return nil;
    WXCookName *model = [WXCookName new];
    model.cid = cid;
    model.name = name;
    model.parent = parent;
    return model;
}
@end

@implementation WXCookSort
+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    NSArray <NSDictionary *>*childs = [NSDictionary arrayValueWithDictionary:dic forKey:@"childs"];
    if (childs.count <= 0) return nil;
    NSDictionary *categoryInfo = [NSDictionary dictionaryValueWithDictionary:dic forKey:@"categoryInfo"];
    NSMutableArray <WXCookName *>*sorts = [NSMutableArray arrayWithCapacity:childs.count];
    [childs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookName *model = [WXCookName modelWithDictionary:obj];
        if (model) [sorts addObject:model];
    }];
    if (sorts.count <= 0) return nil;
    WXCookSort *model = [WXCookSort new];
    model.sorts = sorts.copy;
    model.cid = [NSDictionary stringValueWithDictionary:categoryInfo forKey:@"ctgId"];
    model.name = [NSDictionary stringValueWithDictionary:categoryInfo forKey:@"name"];
    model.parent = [NSDictionary stringValueWithDictionary:categoryInfo forKey:@"parentId"];
    return model;
}



@end
