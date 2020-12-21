//
//  WXCookModel.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookModel.h"

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

@implementation WXCookModel
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    NSString *name = [NSDictionary stringValueWithDictionary:dictionary forKey:@"name"];
    NSString *ctgTitles = [NSDictionary stringValueWithDictionary:dictionary forKey:@"ctgTitles"];
    NSString *thumbnail = [NSDictionary stringValueWithDictionary:dictionary forKey:@"thumbnail"];
    if (name.length <= 0 || ctgTitles.length <= 0 || thumbnail.length <= 0) return nil;
    NSDictionary *dic = [NSDictionary dictionaryValueWithDictionary:dictionary forKey:@"recipe"];
    WXCookRecipe *recipe = [WXCookRecipe modelWithDictionary:dic];
    if (!recipe) return nil;
    WXCookModel *model = [WXCookModel new];
    model.name = name;
    model.titles = ctgTitles;
    model.thumbnail = thumbnail;
    model.recipe = recipe;
    model.cids = [NSDictionary arrayValueWithDictionary:dictionary forKey:@"ctgIds"];
    model.menuId = [NSDictionary stringValueWithDictionary:dictionary forKey:@"menuId"];
    return model;
}
@end
