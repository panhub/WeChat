//
//  WXCook.h
//  WeChat
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
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *sumary;
@property (nonatomic, strong) NSArray <NSString *>*ingredients;
@property (nonatomic, strong) NSArray <WXCookMethod *>*methods;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

@interface WXCookStep : NSObject
/**步骤图*/
@property (nonatomic, copy) NSString *img;
/**步骤介绍*/
@property (nonatomic, copy) NSString *step;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

@interface WXCook : NSObject
/**ID*/
@property (nonatomic, copy) NSString *cid;
/**名称*/
@property (nonatomic, copy) NSString *title;
/**简介*/
@property (nonatomic, copy) NSString *imtro;
/**标签*/
@property (nonatomic, copy) NSArray <NSString *>*tags;
/**食材*/
@property (nonatomic, copy) NSArray <NSString *>*ingredients;
/**配料*/
@property (nonatomic, copy) NSArray <NSString *>*burdens;
/**配图*/
@property (nonatomic, copy) NSArray <NSString *>*albums;
/**步骤*/
@property (nonatomic, copy) NSArray <WXCookStep *>*steps;

@property (nonatomic, copy) NSString *titles;
@property (nonatomic, copy) NSString *menuId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, strong) NSArray <NSString *>*cids;
@property (nonatomic, strong) WXCookRecipe *recipe;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

