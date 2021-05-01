//
//  MNSingleInstance.h
//  MNKit
//
//  Created by Vincent on 2018/3/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  创建单例类

#ifndef MNSingleton_h
#define MNSingleton_h

/**.h文件*/
#define MN_SINGLETON_INTERFACE(method_name)\
+ (instancetype)method_name;

/**.m文件*/
#define MN_SINGLETON_IMPLEMENTATION(method_name)\
static id single_instance;\
+ (instancetype)method_name\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        if (!single_instance) {\
            single_instance = [[self alloc] init];\
        }\
    });\
    return _instace;\
}\
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        single_instance = [super allocWithZone:zone];\
    });\
    return single_instance;\
}\
\
- (instancetype)init \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        single_instance = [super init]; \
    }); \
    return single_instance; \
} \
\
- (id)copyWithZone:(nullable NSZone *)zone \
{\
    return single_instance;\
}\
\
- (id)mutableCopyWithZone:(nullable NSZone *)zone \
{\
    return single_instance;\
}\
\

#endif /* MNSingleton_h */
