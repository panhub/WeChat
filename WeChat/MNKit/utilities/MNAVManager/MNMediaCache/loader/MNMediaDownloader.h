//
//  MNMediaDownloader.h
//  MNKit
//
//  Created by Vincent on 2018/11/30.
//  Copyright © 2018年 小斯. All rights reserved.
//  媒体文件下载器

#import <Foundation/Foundation.h>
#import "MNMediaInfo.h"
@class MNMediaCacheWorker;
@class MNMediaDownloader;

@interface MNMediaDownloadContainer : NSObject
+ (instancetype)defaultContainer;
- (void)addURL:(NSURL *)url;
- (void)removeURL:(NSURL *)url;
- (BOOL)containsURL:(NSURL *)url;
- (NSSet *)URLS;
@end

@protocol MNMediaDownloaderDelegate <NSObject>

@optional
- (void)mediaDownloader:(MNMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response;
- (void)mediaDownloader:(MNMediaDownloader *)downloader didReceiveData:(NSData *)data;
- (void)mediaDownloader:(MNMediaDownloader *)downloader didFinishWithError:(NSError *)error;

@end

@interface MNMediaDownloader : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, weak) id<MNMediaDownloaderDelegate> delegate;
@property (nonatomic, strong) MNMediaInfo *info;
@property (nonatomic, assign) BOOL saveToCache;

- (instancetype)initWithURL:(NSURL *)URL cacheWorker:(MNMediaCacheWorker *)cacheWorker;

- (void)cancel;

- (void)downloadFromStartToEnd;

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;

@end



