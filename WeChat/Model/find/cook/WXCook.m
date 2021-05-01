//
//  WXCook.m
//  WeChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCook.h"

@implementation WXCookMethod

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    NSString *img = [NSDictionary stringValueWithDictionary:dictionary forKey:@"img"];
    NSString *step = [NSDictionary stringValueWithDictionary:dictionary forKey:@"step"];
    if (step.length <= 0) return nil;
    WXCookMethod *model = [WXCookMethod new];
    model.img = img;
    model.step = step;
    return model;
}

@end

@implementation WXCookRecipe

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    NSString *string = [NSDictionary stringValueWithDictionary:dictionary forKey:@"method"];
    NSArray <NSDictionary *>*array = string.JsonValue;
    NSMutableArray <WXCookMethod *>*methods = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookMethod *model = [WXCookMethod modelWithDictionary:obj];
        if (model) [methods addObject:model];
    }];
    if (methods.count <= 0) return nil;
    string = [NSDictionary stringValueWithDictionary:dictionary forKey:@"ingredients"];
    WXCookRecipe *model = [WXCookRecipe new];
    model.methods = methods.copy;
    model.ingredients = string.JsonValue;
    model.img = [NSDictionary stringValueWithDictionary:dictionary forKey:@"img"];
    model.title = [NSDictionary stringValueWithDictionary:dictionary forKey:@"title"];
    model.sumary = [NSDictionary stringValueWithDictionary:dictionary forKey:@"sumary"];
    return model;
}

@end

@implementation WXCookStep
+ (instancetype)modelWithDictionary:(NSDictionary *)dic {
    WXCookStep *m = WXCookStep.new;
    m.img = [NSDictionary stringValueWithDictionary:dic forKey:@"img"];
    m.step = [NSDictionary stringValueWithDictionary:dic forKey:@"step"];
    return m;
}

@end

@implementation WXCook
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    WXCook *model = [WXCook new];
    model.cid = [NSDictionary stringValueWithDictionary:dictionary forKey:@"id"];
    model.title = [NSDictionary stringValueWithDictionary:dictionary forKey:@"title"];
    model.imtro = [NSDictionary stringValueWithDictionary:dictionary forKey:@"imtro"];
    model.tags = [[NSDictionary stringValueWithDictionary:dictionary forKey:@"tags"] componentsSeparatedByString:@","];
    model.ingredients = [[NSDictionary stringValueWithDictionary:dictionary forKey:@"ingredients"] componentsSeparatedByString:@";"];
    model.burdens = [[NSDictionary stringValueWithDictionary:dictionary forKey:@"burden"] componentsSeparatedByString:@";"];
    model.albums = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"albums"];
    NSMutableArray <WXCookStep *>*array = @[].mutableCopy;
    NSArray <NSDictionary *>*steps = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"steps"];
    [steps enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookStep *m = [WXCookStep modelWithDictionary:obj];
        [array addObject:m];
    }];
    model.steps = array;
    return model;
}
@end
