//
//  MNMediaCacheConfiguration.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//  缓存配置信息

#import <Foundation/Foundation.h>
#import "MNMediaInfo.h"

@interface MNMediaCacheConfiguration : NSObject<NSCoding, NSCopying>

/**媒体文件URL*/
@property (nonatomic, strong) NSURL *URL;
/**媒体文件信息*/
@property (nonatomic, strong) MNMediaInfo *mediaInfo;
/**缓存路径*/
@property (nonatomic, copy, readonly) NSString *filePath;

+ (NSString *)getConfigurationFilePath:(NSString *)filePath;

+ (instancetype)configurationWithFilePath:(NSString *)filePath;

/**缓存碎片*/
- (NSArray<NSValue *> *)cacheFragments;

/**
 *  cached progress
 */
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) long long downloadedBytes;
@property (nonatomic, readonly) float downloadSpeed;

- (void)save;

- (void)addCacheFragment:(NSRange)fragment;

- (void)addDownloadBytes:(long long)bytes spent:(NSTimeInterval)time;

@end


@interface MNMediaCacheConfiguration (MNConvenient)

+ (BOOL)createAndSaveDownloadConfigurationForURL:(NSURL *)URL error:(NSError **)error;

@end
