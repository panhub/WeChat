//
//  MNMediaLoaderManager.h
//  MNKit
//
//  Created by Vincent on 2018/11/30.
//  Copyright © 2018年 小斯. All rights reserved.
//  媒体资源加载代理

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MNMediaLoaderManagerDelegate <NSObject>

- (void)mediaLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface MNMediaLoaderManager : NSObject

@property (nonatomic, weak) id<MNMediaLoaderManagerDelegate> delegate;

- (void)cleanCache;

- (void)cancelAllLoader;

@end



@interface MNMediaLoaderManager (PlayerItem)

- (AVPlayerItem *)playerItemWithURL:(NSURL *)URL;

+ (NSURL *)assetURLWithURL:(NSURL *)URL;

@end

