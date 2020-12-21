//
//  WXCookSort.h
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱类别

#import <Foundation/Foundation.h>

@interface WXCookName : NSObject

@property (nonatomic, strong) NSString *cid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parent;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

@interface WXCookSort : NSObject

@property (nonatomic, strong) NSString *cid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parent;

@property (nonatomic, strong) NSArray <WXCookName *>*sorts;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end
