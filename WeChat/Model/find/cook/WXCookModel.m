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
    NSString *img = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"img"];
    NSString *step = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"step"];
    if (step.length <= 0) return nil;
    WXCookMethod *model = [WXCookMethod new];
    model.img = img;
    model.step = step;
    return model;
}

@end

@implementation WXCookRecipe

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    NSString *string = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"method"];
    NSArray <NSDictionary *>*array = string.JsonValue;
    NSMutableArray <WXCookMethod *>*methods = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookMethod *model = [WXCookMethod modelWithDictionary:obj];
        if (model) [methods addObject:model];
    }];
    if (methods.count <= 0) return nil;
    string = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"ingredients"];
    WXCookRecipe *model = [WXCookRecipe new];
    model.methods = methods.copy;
    model.ingredients = string.JsonValue;
    model.img = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"img"];
    model.title = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"title"];
    model.sumary = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"sumary"];
    return model;
}

@end

@implementation WXCookModel
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    NSString *name = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"name"];
    NSString *ctgTitles = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"ctgTitles"];
    NSString *thumbnail = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"thumbnail"];
    if (name.length <= 0 || ctgTitles.length <= 0 || thumbnail.length <= 0) return nil;
    NSDictionary *dic = [MNJSONSerialization dictionaryValueWithJSON:dictionary forKey:@"recipe"];
    WXCookRecipe *recipe = [WXCookRecipe modelWithDictionary:dic];
    if (!recipe) return nil;
    WXCookModel *model = [WXCookModel new];
    model.name = name;
    model.titles = ctgTitles;
    model.thumbnail = thumbnail;
    model.recipe = recipe;
    model.cids = [MNJSONSerialization arrayValueWithJSON:dictionary forKey:@"ctgIds"];
    model.menuId = [MNJSONSerialization stringValueWithJSON:dictionary forKey:@"menuId"];
    return model;
}
@end
