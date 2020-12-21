//
//  NSBundle+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/2/7.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSBundle+MNHelper.h"

@implementation NSBundle (MNHelper)
#pragma mark - 获取工程内Bundle
+ (NSBundle *)bundleWithName:(NSString *)name {
    if (name.length <= 0) return nil;
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"bundle"]];
}

NSBundle * NSBundleWithName (NSString *name) {
    return [NSBundle bundleWithName:name];
}

#pragma mark - 工程plist配置信息字典
+ (NSDictionary<NSString *, id>*)bundleInfo {
    static NSDictionary<NSString *, id>* bundle_info;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle_info = [[NSBundle mainBundle] infoDictionary];
    });
    return bundle_info;
}

NSDictionary<NSString *, id>* NSBundleInfo (void) {
    return [NSBundle bundleInfo];
}

#pragma mark - 工程唯一标识
+ (NSString *)identifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

NSString * NSBundleIdentifier (void) {
    return [NSBundle identifier];
}

#pragma mark - 项目版本号
+ (NSString *)buildVersion {
    return [[self bundleInfo] objectForKey:@"CFBundleVersion"];
}

NSString * NSBuildVersion (void) {
    return [NSBundle buildVersion];
}

#pragma mark - Bundle版本号
+ (NSString *)bundleVersion {
    return [[self bundleInfo] objectForKey:@"CFBundleShortVersionString"];
}

NSString * NSBundleVersion (void) {
    return [NSBundle bundleVersion];
}

#pragma mark - 项目工程名
+ (NSString *)displayName {
    NSString *displayName = [[self bundleInfo] objectForKey:@"CFBundleDisplayName"];
    if (!displayName) displayName = [[self bundleInfo] objectForKey:@"CFBundleName"];
    return displayName;
}

NSString * NSBundleDisplayName (void) {
    return [NSBundle displayName];
}

#pragma mark - 获取白名单
+ (NSArray <NSString *>*)schemes {
    return [[self bundleInfo] objectForKey:@"LSApplicationQueriesSchemes"];
}

NSArray <NSString *>* NSBundleSchemes (void) {
    return [NSBundle schemes];
}

#pragma mark - 获取图片路径
- (NSString *)imagePathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
    BOOL stop = NO;
    NSString *filePath = nil;
    do {
        filePath = directory ? [self pathForResource:name ofType:type inDirectory:directory] : [self pathForResource:name ofType:type];
        if (filePath || stop) break;
        if ([name containsString:@"@2x"]) {
            stop = YES;
            name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@"@3x"];
        } else if ([name containsString:@"@3x"]) {
            stop = YES;
            name = [name stringByReplacingOccurrencesOfString:@"@3x" withString:@"@2x"];
        } else {
            CGFloat scale = [[UIScreen mainScreen] scale];
            if (scale <= 1) break;
            name = [name stringByAppendingString:[NSString stringWithFormat:@"@%@x", [NSNumber numberWithInteger:scale]]];
        }
    } while (!filePath);
    return filePath;
}

@end


@implementation MNBundle
#pragma mark - MNKit内置Bundle
+ (NSBundle *)mainBundle {
    static NSBundle *mnbundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mnbundle = [NSBundle bundleWithName:MNResourceBundleName];
    });
    return mnbundle;
}

+ (UIImage *)imageForResource:(NSString *)name {
    return [self imageForResource:name ofType:@"png"];
}

+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type {
    return [self imageForResource:name ofType:type inDirectory:@"image"];
}

+ (UIImage *)imageForResource:(NSString *)name inDirectory:(NSString *)directory {
    return [self imageForResource:name ofType:@"png" inDirectory:directory];
}

+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
    return [UIImage imageWithBundle:[self mainBundle] forResource:name ofType:type inDirectory:directory];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    return [self.mainBundle localizedStringForKey:key value:@"" table:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value {
    return [self.mainBundle localizedStringForKey:key value:value table:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    return [self.mainBundle localizedStringForKey:key value:value table:tableName];
}

NSString *MNLocalizedString(NSString *key) {
    return [MNBundle.mainBundle localizedStringForKey:key value:@"" table:nil];
}

@end


@implementation UIImage (MNBundle)
#pragma mark - UIImage
+ (UIImage *)imageForResource:(NSString *)name {
    return [self imageForResource:name ofType:@"png"];
}

+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type {
    return [self imageForResource:name ofType:type inDirectory:nil];
}

+ (UIImage *)imageForResource:(NSString *)name inDirectory:(NSString *)directory {
    return [self imageForResource:name ofType:@"png" inDirectory:directory];
}

+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
    return [self imageWithBundle:[NSBundle mainBundle] forResource:name ofType:type inDirectory:directory];
}

+ (UIImage *)imageWithBundle:(NSBundle *)bundle forResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
    NSString *filePath = [bundle imagePathForResource:name ofType:type inDirectory:directory];
    if (filePath.length <= 0) return nil;
    return [UIImage imageWithContentsOfFile:filePath];
}

@end
