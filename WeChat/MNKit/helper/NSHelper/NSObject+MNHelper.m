//
//  NSObject+MNCoding.m
//  MNKit
//
//  Created by Vincent on 2018/10/9.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSObject+MNHelper.h"
#import <CoreFoundation/CFBase.h>
#import <objc/runtime.h>

static NSString * NSObjectAssociatedUserInfoKey = @"com.mn.obj.user.info.key";

@implementation NSObject (MNHelper)

#pragma mark - 获取引用计数
- (NSInteger)retaincount {
#if __has_feature(objc_arc)
    return CFGetRetainCount((__bridge CFTypeRef)(self));
#else
    return [self retainCount];
# endif
}

#pragma mark - 预留值捕获
- (void)setUser_info:(id)user_info {
    objc_setAssociatedObject(self, &NSObjectAssociatedUserInfoKey, user_info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)user_info {
    return objc_getAssociatedObject(self, &NSObjectAssociatedUserInfoKey);
}

#pragma mark - 判断是否为空对象
+ (BOOL)isEmptying:(id)obj {
    return (obj == nil || obj == NULL || [obj isKindOfClass:[NSNull class]] || [obj isEqual:[NSNull null]] ||
            ([obj respondsToSelector:@selector(length)] && [obj length] <= 0) ||
            ([obj respondsToSelector:@selector(count)] && [obj count] <= 0) ||
            ([obj respondsToSelector:@selector(allKeys)] && [obj allKeys] <= 0));
}

#pragma mark - 替换空对象
+ (void)replacingBlankObject:(id*)aObj withObject:(id)bObj {
    if ([self isEmptying:*aObj]) {
        *aObj = bObj;
    }
}

#pragma mark - 转换为Json格式字符串
- (NSString *)JsonString {
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    }
    if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
    if (data.length <= 0) return nil;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - JSONData
- (NSData *)JsonData {
    if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    if ([self isKindOfClass:[NSString class]]) {
        return [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
}

#pragma mark - JsonValue
- (id)JsonValue {
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) return self;
    NSData *data = [self JsonData];
    if (data.length <= 0) return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

#pragma mark - 获取属性列表
- (NSArray <NSString *>*)properties {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self.class, &count);
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        [names addObject:[NSString stringWithCString:cName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    return names.copy;
}

#pragma mark - 对象序列化
- (NSData *)archivedData {
    if (([self conformsToProtocol:@protocol(NSSecureCoding)] || [self conformsToProtocol:@protocol(NSCoding)]) && [self respondsToSelector:@selector(encodeWithCoder:)]) {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000
        if (@available(iOS 12.0, *)) {
            return [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:nil];
        }
        #endif
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    return nil;
}

#pragma mark - 对象反序列化
+ (id)unarchiveFromData:(NSData *)data {
    if (data.length > 0 && ([self conformsToProtocol:@protocol(NSSecureCoding)] || [self conformsToProtocol:@protocol(NSCoding)]) && class_respondsToSelector(self, @selector(initWithCoder:))) {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000
        if (@available(iOS 12.0, *)) {
            return [NSKeyedUnarchiver unarchivedObjectOfClass:self.class fromData:data error:nil];
        }
        #endif
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - 对象序列化到指定路径
- (BOOL)archiveToFile:(NSString *)filePath {
    if ([self conformsToProtocol:@protocol(NSCoding)] && [self respondsToSelector:@selector(encodeWithCoder:)] && [MNFileManager createDirectoryAtPath:filePath error:nil]) {
        return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    }
    return NO;
}

#pragma mark - 从指定文件路径反序列化
+ (id)unarchiveFromFile:(NSString *)filePath {
    if ([self conformsToProtocol:@protocol(NSCoding)] && class_respondsToSelector(self, @selector(initWithCoder:)) && [MNFileManager itemExistsAtPath:filePath isDirectory:nil]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return nil;
}

@end
