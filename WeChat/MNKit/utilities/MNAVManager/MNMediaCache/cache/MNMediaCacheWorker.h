//
//  MNMediaCacheWorker.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNMediaCacheConfiguration.h"
#import "MNMediaSeekAction.h"

@interface MNMediaCacheWorker : NSObject

@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readonly) MNMediaCacheConfiguration *configuration;

- (instancetype)initWithURL:(NSURL *)URL;

- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error;
- (NSArray<MNMediaSeekAction *> *)cacheDataActionForRange:(NSRange)range;
- (NSData *)cacheDataForRange:(NSRange)range error:(NSError **)error;

- (void)setMediaInfo:(MNMediaInfo *)mediaInfo error:(NSError **)error;

- (void)save;

- (void)startWritting;
- (void)finishWritting;

@end
