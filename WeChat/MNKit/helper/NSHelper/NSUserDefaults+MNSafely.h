//
//  NSUserDefaults+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/9/24.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSUserDefaults (MNSafely)

+ (id _Nullable)objectForKey:(NSString *)key def:(id _Nullable)def;

+ (NSString *_Nullable)stringForKey:(NSString *)key def:(NSString *_Nullable)def;

+ (BOOL)boolForKey:(NSString *)key;

+ (BOOL)boolForKey:(NSString *)key def:(BOOL)def;

+ (NSData *_Nullable)dataForKey:(NSString *)key def:(NSData *_Nullable)def;

+ (NSArray *_Nullable)arrayForKey:(NSString *)key def:(NSArray *_Nullable)def;

+ (NSArray<NSString *> *_Nullable)stringArrayForKey:(NSString *)key def:(NSArray <NSString *>*_Nullable)def;

+ (NSDictionary<NSString *, id> *_Nullable)dictionaryForKey:(NSString *)key def:(NSDictionary<NSString *, id> *_Nullable)def;

#pragma mark -
- (BOOL)setImage:(UIImage *_Nullable)image forKey:(NSString *)defaultName;

- (UIImage *_Nullable)imageForKey:(NSString *)key;

- (UIImage *_Nullable)imageForKey:(NSString *)key def:(UIImage *_Nullable)def;

#pragma mark -
+ (void)synchronly:(void(^)(NSUserDefaults *userDefaults))handler;

@end
NS_ASSUME_NONNULL_END

