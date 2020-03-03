//
//  MNMediaCacheManager.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaCacheManager.h"
#import "NSString+MNMediaMD5.h"
#import "MNMediaCacheConfiguration.h"
#import "MNMediaDownloader.h"

NSString *MNMediaCacheManagerDidUpdateCacheNotification = @"com.media.cache.did.update";
NSString *MNMediaCacheManagerDidFinishCacheNotification = @"com.media.cache.did.finish";

NSString *MNMediaCacheConfigurationKey = @"com.media.cache.configuration.key";
NSString *MNMediaCacheFinishedErrorKey = @"com.media.cache.finished.error.key";

static NSString *MNMediaCacheDirectory;
static NSTimeInterval MNMediaCacheNotifyInterval;
static NSString *(^MNMediaCacheFileNameRules)(NSURL *URL);

@implementation MNMediaCacheManager
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        [self setCacheDirectory:[cachePath stringByAppendingPathComponent:@"mnmedia"]];
        [self setCacheUpdateNotifyInterval:0.1];
    });
}

+ (void)setCacheDirectory:(NSString *)cacheDirectory {
    MNMediaCacheDirectory = cacheDirectory;
}

+ (NSString *)cacheDirectory {
    return MNMediaCacheDirectory;
}

+ (void)setCacheUpdateNotifyInterval:(NSTimeInterval)interval {
    MNMediaCacheNotifyInterval = interval;
}

+ (NSTimeInterval)cacheUpdateNotifyInterval {
    return MNMediaCacheNotifyInterval;
}

+ (void)setFileNameRules:(NSString *(^)(NSURL *url))rules {
    MNMediaCacheFileNameRules = rules;
}

+ (NSString *)cacheFilePathForURL:(NSURL *)URL {
    NSString *pathComponent = nil;
    if (MNMediaCacheFileNameRules) {
        pathComponent = MNMediaCacheFileNameRules(URL);
    } else {
        pathComponent = [URL.absoluteString mediaMD5String];
        pathComponent = [pathComponent stringByAppendingPathExtension:URL.pathExtension];
    }
    return [[self cacheDirectory] stringByAppendingPathComponent:pathComponent];
}

+ (MNMediaCacheConfiguration *)cacheConfigurationForURL:(NSURL *)URL {
    NSString *filePath = [self cacheFilePathForURL:URL];
    MNMediaCacheConfiguration *configuration = [MNMediaCacheConfiguration configurationWithFilePath:filePath];
    return configuration;
}

+ (unsigned long long)cacheSizeWithError:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirectory = [self cacheDirectory];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
    unsigned long long size = 0;
    if (files) {
        for (NSString *path in files) {
            NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
            NSDictionary<NSFileAttributeKey, id> *attribute = [fileManager attributesOfItemAtPath:filePath error:error];
            if (!attribute) {
                size = -1;
                break;
            }
            size += [attribute fileSize];
        }
    }
    return size;
}

+ (void)cleanAllCacheWithError:(NSError **)error {
    // Find downloaing file
    NSMutableSet *downloadingFiles = [NSMutableSet set];
    [[[MNMediaDownloadContainer defaultContainer] URLS] enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *file = [self cacheFilePathForURL:obj];
        [downloadingFiles addObject:file];
        NSString *configurationPath = [MNMediaCacheConfiguration getConfigurationFilePath:file];
        [downloadingFiles addObject:configurationPath];
    }];
    
    // Remove files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirectory = [self cacheDirectory];
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
    if (files) {
        for (NSString *path in files) {
            NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
            if ([downloadingFiles containsObject:filePath]) {
                continue;
            }
            if (![fileManager removeItemAtPath:filePath error:error]) {
                break;
            }
        }
    }
}

+ (void)cleanCacheForURL:(NSURL *)URL error:(NSError **)error {
    if ([[MNMediaDownloadContainer defaultContainer] containsURL:URL]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"clean cache for url `%@` can't be done, because it's downloading", nil), URL];
        if (error) {
            *error = [NSError errorWithDomain:@"com.mediadownload" code:2 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self cacheFilePathForURL:URL];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        if (![fileManager removeItemAtPath:filePath error:error]) {
            return;
        }
    }
    
    NSString *configurationPath = [MNMediaCacheConfiguration getConfigurationFilePath:filePath];
    if ([fileManager fileExistsAtPath:configurationPath]) {
        if (![fileManager removeItemAtPath:configurationPath error:error]) {
            return;
        }
    }
}

+ (BOOL)addCacheFile:(NSString *)filePath forURL:(NSURL *)URL error:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cachePath = [self cacheFilePathForURL:URL];
    NSString *cacheFolder = [cachePath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:cacheFolder]) {
        if (![fileManager createDirectoryAtPath:cacheFolder
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:error]) {
            return NO;
        }
    }
    
    if (![fileManager copyItemAtPath:filePath toPath:cachePath error:error]) {
        return NO;
    }
    
    if (![MNMediaCacheConfiguration createAndSaveDownloadConfigurationForURL:URL error:error]) {
        [fileManager removeItemAtPath:cachePath error:nil]; // if remove failed, there is nothing we can do.
        return NO;
    }
    
    return YES;
}

@end
