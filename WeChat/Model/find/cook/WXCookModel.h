//
//  WXCookModel.h
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱请求

#import <Foundation/Foundation.h>

@interface WXCookMethod : NSObject

@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *step;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

@interface WXCookRecipe : NSObject

@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sumary;
@property (nonatomic, strong) NSArray <NSString *>*ingredients;
@property (nonatomic, strong) NSArray <WXCookMethod *>*methods;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

@interface WXCookModel : NSObject

@property (nonatomic, copy) NSString *titles;
@property (nonatomic, copy) NSString *menuId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, strong) NSArray <NSString *>*cids;
@property (nonatomic, strong) WXCookRecipe *recipe;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

