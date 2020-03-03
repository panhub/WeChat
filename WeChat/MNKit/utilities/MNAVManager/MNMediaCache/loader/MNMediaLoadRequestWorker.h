//
//  MNMediaLoadRequestWorker.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MNMediaLoadRequestWorker;
@class MNMediaDownloader;
@class AVAssetResourceLoadingRequest;

@protocol MNMediaLoadRequestWorkerDelegate <NSObject>

- (void)mediaLoadRequestWorker:(MNMediaLoadRequestWorker *)requestWorker didCompleteWithError:(NSError *)error;

@end

@interface MNMediaLoadRequestWorker : NSObject

- (instancetype)initWithMediaDownloader:(MNMediaDownloader *)mediaDownloader loadingRequest:(AVAssetResourceLoadingRequest *)request;

@property (nonatomic, weak) id<MNMediaLoadRequestWorkerDelegate> delegate;

@property (nonatomic, strong, readonly) AVAssetResourceLoadingRequest *request;

- (void)startWork;
- (void)cancel;
- (void)finish;

@end
