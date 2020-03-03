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
    NSDictionary *categoryInfo = [MNJSONSerialization dictionaryValueWithJSON:dic forKey:@"categoryInfo"];
    NSString *cid = [MNJSONSerialization stringValueWithJSON:categoryInfo forKey:@"ctgId"];
    NSString *name = [MNJSONSerialization stringValueWithJSON:categoryInfo forKey:@"name"];
    NSString *parent = [MNJSONSerialization stringValueWithJSON:categoryInfo forKey:@"parentId"];
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
    NSArray <NSDictionary *>*childs = [MNJSONSerialization arrayValueWithJSON:dic forKey:@"childs"];
    if (childs.count <= 0) return nil;
    NSDictionary *categoryInfo = [MNJSONSerialization dictionaryValueWithJSON:dic forKey:@"categoryInfo"];
    NSMutableArray <WXCookName *>*sorts = [NSMutableArray arrayWithCapacity:childs.count];
    [childs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookName *model = [WXCookName modelWithDictionary:obj];
        if (model) [sorts addObject:model];
    }];
    if (sorts.count <= 0) return nil;
    WXCookSort *model = [WXCookSort new];
    model.sorts = sorts.copy;
    model.cid = [MNJSONSerialization stringValueWithJSON:categoryInfo forKey:@"ctgId"];
    model.name = [MNJSONSerialization stringValueWithJSON:categoryInfo forKey:@"name"];
    model.parent = [MNJSONSerialization stringValueWithJSON:categoryInfo forKey:@"parentId"];
    return model;
}



@end
