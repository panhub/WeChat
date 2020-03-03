//
//  MNMediaResourceLoader.h
//  MNKit
//
//  Created by Vincent on 2018/11/30.
//  Copyright © 2018年 小斯. All rights reserved.
//  视音频下载器

#import <Foundation/Foundation.h>
@import AVFoundation;
@class MNMediaResourceLoader;

@protocol MNMediaResourceLoaderDatagate <NSObject>

- (void)mediaResourceLoader:(MNMediaResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

@end

@interface MNMediaResourceLoader : NSObject

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, weak) id<MNMediaResourceLoaderDatagate> delegate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL;

- (void)addRequest:(AVAssetResourceLoadingRequest *)request;
- (void)removeRequest:(AVAssetResourceLoadingRequest *)request;

- (void)cancel;

@end
