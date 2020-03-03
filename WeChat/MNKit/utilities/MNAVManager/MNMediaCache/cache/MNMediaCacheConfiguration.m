//
//  MNMediaCacheConfiguration.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaCacheConfiguration.h"
#import "MNMediaCacheManager.h"
#import <CoreServices/UTType.h>

@interface MNMediaCacheConfiguration ()
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSArray<NSValue *> *cacheFragments;
@property (nonatomic, copy) NSArray *downloadInfo;
@end

#define MNMediaConfigurationExtension  @"mn_cfg"

static NSString *MNMediaConfigurationFileNameKey = @"mn.media.configuration.filename.key";
static NSString *MNMediaConfigurationCacheFragmentsKey = @"mn.media.configuration.cache.fragments.key";
static NSString *MNMediaConfigurationDownloadInfoKey = @"mn.media.configuration.download.info.key";
static NSString *MNMediaConfigurationInfoKey = @"mn.media.configuration.info.key";
static NSString *MNMediaConfigurationURLKey = @"mn.media.configuration.URL.key";

@implementation MNMediaCacheConfiguration

+ (instancetype)configurationWithFilePath:(NSString *)filePath {
    filePath = [self getConfigurationFilePath:filePath];
    MNMediaCacheConfiguration *configuration = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (!configuration) {
        configuration = [[MNMediaCacheConfiguration alloc] init];
        configuration.fileName = [filePath lastPathComponent];
    }
    configuration.filePath = filePath;
    return configuration;
}

+ (NSString *)getConfigurationFilePath:(NSString *)filePath {
    return [filePath stringByAppendingPathExtension:MNMediaConfigurationExtension];
}

- (NSArray<NSValue *> *)cacheFragments {
    if (!_cacheFragments) {
        _cacheFragments = [NSArray new];
    }
    return _cacheFragments;
}

- (NSArray *)downloadInfo {
    if (!_downloadInfo) {
        _downloadInfo = [NSArray array];
    }
    return _downloadInfo;
}

- (float)progress {
    float progress = self.downloadedBytes/(float)(self.mediaInfo.contentLength);
    return progress;
}

- (long long)downloadedBytes {
    float bytes = 0;
    @synchronized (self.cacheFragments) {
        for (NSValue *range in self.cacheFragments) {
            bytes += range.rangeValue.length;
        }
    }
    return bytes;
}

- (float)downloadSpeed {
    long long bytes = 0;
    NSTimeInterval time = 0;
    @synchronized (self.downloadInfo) {
        for (NSArray *a in self.downloadInfo) {
            bytes += [[a firstObject] longLongValue];
            time += [[a lastObject] doubleValue];
        }
    }
    return bytes / 1024.0 / time;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fileName forKey:MNMediaConfigurationFileNameKey];
    [aCoder encodeObject:self.cacheFragments forKey:MNMediaConfigurationCacheFragmentsKey];
    [aCoder encodeObject:self.downloadInfo forKey:MNMediaConfigurationDownloadInfoKey];
    [aCoder encodeObject:self.mediaInfo forKey:MNMediaConfigurationInfoKey];
    [aCoder encodeObject:self.URL forKey:MNMediaConfigurationURLKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _fileName = [aDecoder decodeObjectForKey:MNMediaConfigurationFileNameKey];
        _cacheFragments = [[aDecoder decodeObjectForKey:MNMediaConfigurationCacheFragmentsKey] mutableCopy];
        if (!_cacheFragments) {
            _cacheFragments = [NSArray array];
        }
        _downloadInfo = [aDecoder decodeObjectForKey:MNMediaConfigurationDownloadInfoKey];
        _mediaInfo = [aDecoder decodeObjectForKey:MNMediaConfigurationInfoKey];
        _URL = [aDecoder decodeObjectForKey:MNMediaConfigurationURLKey];
    }
    return self;
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    MNMediaCacheConfiguration *configuration = [MNMediaCacheConfiguration allocWithZone:zone];
    configuration.fileName = self.fileName;
    configuration.filePath = self.filePath;
    configuration.downloadInfo = self.downloadInfo;
    configuration.cacheFragments = self.cacheFragments;
    configuration.URL = self.URL;
    configuration.mediaInfo = self.mediaInfo;
    return configuration;
}

#pragma mark - Update
- (void)save {
    @synchronized (self.cacheFragments) {
        [NSKeyedArchiver archiveRootObject:self toFile:self.filePath];
    }
}

- (void)addCacheFragment:(NSRange)fragment {
    /**判断位置是否有用*/
    if (fragment.location == NSNotFound || fragment.length == 0) return;
    /**加锁*/
    @synchronized (self.cacheFragments) {
        NSMutableArray <NSValue *>*cacheFragments = [self.cacheFragments mutableCopy];
        NSValue *fragmentValue = [NSValue valueWithRange:fragment];
        NSInteger count = cacheFragments.count;
        if (count == 0) {
            [cacheFragments addObject:fragmentValue];
        } else {
            /**判断位置*/
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            /**子前往后遍历*/
            [cacheFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = value.rangeValue;
                if ((fragment.location + fragment.length) <= range.location) {
                    if (indexSet.count == 0) {
                        [indexSet addIndex:idx];
                    }
                    *stop = YES;
                } else if (fragment.location <= (range.location + range.length) && (fragment.location + fragment.length) > range.location) {
                    [indexSet addIndex:idx];
                } else if (fragment.location >= range.location + range.length) {
                    if (idx == count - 1) {
                        [indexSet addIndex:idx];
                    }
                }
            }];
            /***/
            if (indexSet.count > 1) {
                /**包含多个片段*/
                NSRange firstRange = self.cacheFragments[indexSet.firstIndex].rangeValue;
                NSRange lastRange = self.cacheFragments[indexSet.lastIndex].rangeValue;
                NSInteger location = MIN(firstRange.location, fragment.location);
                NSInteger endOffset = MAX(lastRange.location + lastRange.length, fragment.location + fragment.length);
                NSRange combineRange = NSMakeRange(location, endOffset - location);
                [cacheFragments removeObjectsAtIndexes:indexSet];
                [cacheFragments insertObject:[NSValue valueWithRange:combineRange] atIndex:indexSet.firstIndex];
            } else if (indexSet.count == 1) {
                NSRange firstRange = self.cacheFragments[indexSet.firstIndex].rangeValue;
                
                NSRange expandFirstRange = NSMakeRange(firstRange.location, firstRange.length + 1);
                NSRange expandFragmentRange = NSMakeRange(fragment.location, fragment.length + 1);
                /**交集*/
                NSRange intersectionRange = NSIntersectionRange(expandFirstRange, expandFragmentRange);
                
                if (intersectionRange.length > 0) {
                    //有交集
                    NSInteger location = MIN(firstRange.location, fragment.location);
                    NSInteger endOffset = MAX(firstRange.location + firstRange.length, fragment.location + fragment.length);
                    NSRange combineRange = NSMakeRange(location, endOffset - location);
                    [cacheFragments removeObjectAtIndex:indexSet.firstIndex];
                    [cacheFragments insertObject:[NSValue valueWithRange:combineRange] atIndex:indexSet.firstIndex];
                } else {
                    //没交集
                    if (firstRange.location > fragment.location) {
                        //最后一个
                        [cacheFragments insertObject:fragmentValue atIndex:[indexSet lastIndex]];
                    } else {
                        [cacheFragments insertObject:fragmentValue atIndex:[indexSet lastIndex] + 1];
                    }
                }
            }
        }
        
        self.cacheFragments = [cacheFragments copy];
    }
}

- (void)addDownloadBytes:(long long)bytes spent:(NSTimeInterval)time {
    @synchronized (self.downloadInfo) {
        self.downloadInfo = [self.downloadInfo arrayByAddingObject:@[@(bytes), @(time)]];
    }
}

@end


@implementation MNMediaCacheConfiguration (MNConvenient)

+ (BOOL)createAndSaveDownloadConfigurationForURL:(NSURL *)URL error:(NSError **)error {
    NSString *filePath = [MNMediaCacheManager cacheFilePathForURL:URL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary<NSFileAttributeKey, id> *attributes = [fileManager attributesOfItemAtPath:filePath error:error];
    if (!attributes) return NO;
    
    NSUInteger fileSize = (NSUInteger)attributes.fileSize;
    NSRange range = NSMakeRange(0, fileSize);
    
    MNMediaCacheConfiguration *configuration = [MNMediaCacheConfiguration configurationWithFilePath:filePath];
    configuration.URL = URL;
    MNMediaInfo *mediaInfo = [MNMediaInfo new];
    
    NSString *fileExtension = [URL pathExtension];
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        contentType = @"application/octet-stream";
    }
    mediaInfo.contentType = contentType;
    mediaInfo.contentLength = fileSize;
    mediaInfo.byteRangeAccessSupported = YES;
    mediaInfo.downloadedContentLength = fileSize;
    
    configuration.mediaInfo = mediaInfo;
    
    [configuration addCacheFragment:range];
    [configuration save];
    
    return YES;
}

@end
