//
//  MNMediaCacheManager.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MNMediaCacheConfiguration;

extern NSString *MNMediaCacheManagerDidUpdateCacheNotification;
extern NSString *MNMediaCacheManagerDidFinishCacheNotification;

extern NSString *MNMediaCacheConfigurationKey;
extern NSString *MNMediaCacheFinishedErrorKey;

@interface MNMediaCacheManager : NSObject

+ (void)setCacheDirectory:(NSString *)cacheDirectory;
+ (NSString *)cacheDirectory;

+ (void)setCacheUpdateNotifyInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)cacheUpdateNotifyInterval;

+ (void)setFileNameRules:(NSString *(^)(NSURL *url))rules;

+ (NSString *)cacheFilePathForURL:(NSURL *)URL;
+ (MNMediaCacheConfiguration *)cacheConfigurationForURL:(NSURL *)URL;


+ (unsigned long long)cacheSizeWithError:(NSError **)error;
+ (void)cleanAllCacheWithError:(NSError **)error;
+ (void)cleanCacheForURL:(NSURL *)URL error:(NSError **)error;
+ (BOOL)addCacheFile:(NSString *)filePath forURL:(NSURL *)URL error:(NSError **)error;

@end

