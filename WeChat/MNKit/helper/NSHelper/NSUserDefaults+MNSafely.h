//
//  NSUserDefaults+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/9/24.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (MNSafely)

+ (id)objectForKey:(NSString *)key def:(id)def;

+ (NSString *)stringForKey:(NSString *)key def:(NSString *)def;

+ (BOOL)boolForKey:(NSString *)key;

+ (BOOL)boolForKey:(NSString *)key def:(BOOL)def;

+ (NSData *)dataForKey:(NSString *)key def:(NSData *)def;

+ (NSArray *)arrayForKey:(NSString *)key def:(NSArray *)def;

+ (NSArray<NSString *> *)stringArrayForKey:(NSString *)key def:(NSArray <NSString *>*)def;

+ (NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)key def:(NSDictionary<NSString *, id> *)def;

#pragma mark -
- (void)setImage:(UIImage *)image forKey:(NSString *)defaultName;

- (UIImage *)imageForKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)key def:(UIImage *)def;

#pragma mark -
+ (void)synchronly:(void(^)(NSUserDefaults *userDefaults))handler;

@end


