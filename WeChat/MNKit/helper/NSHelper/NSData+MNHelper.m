//
//  NSData+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/8/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSData+MNHelper.h"

@implementation NSData (MNHelper)

#pragma mark - NSData Path
+ (NSData *)dataWithResource:(NSString *)name ofType:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    if (!path) return nil;
    return [NSData dataWithContentsOfFile:path];
}

+ (NSData *)dataWithResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:directory];
    if (!path) return nil;
    return [NSData dataWithContentsOfFile:path];
}

#pragma mark - 归档
+ (NSData *)archivedDataWithRootObject:(id)obj {
    if (obj && [obj conformsToProtocol:@protocol(NSCoding)] && [obj respondsToSelector:@selector(encodeWithCoder:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000
        if (@available(iOS 12.0, *)) {
            return [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:nil];
        }
#endif
        return [NSKeyedArchiver archivedDataWithRootObject:obj];
    }
    return nil;
}

#pragma mark - 解档
- (id)unarchivedObject {
    if (self.length <= 0) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithData:self];
}

- (id)unarchivedObjectOfClass:(Class)cls {
    if (self.length > 0 && cls && [cls conformsToProtocol:@protocol(NSCoding)] && class_respondsToSelector(cls, @selector(initWithCoder:))) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000
        if (@available(iOS 12.0, *)) {
            return [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:self error:nil];
        }
#endif
        return [NSKeyedUnarchiver unarchiveObjectWithData:self];
    }
    return nil;
}

- (NSString *)UTF8EncodedString {
    if (self.length <= 0) return nil;
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSString *)base64EncodedString {
    if (self.length <= 0) return nil;
    return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
