//
//  ZMVideoUrlRequest.h
//  WeChat
//
//  Created by Vicent on 2021/1/30.
//  Copyright © 2021 Vincent. All rights reserved.
//  视频链接请求

#import "MNHTTPDataRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMVideoUrlRequest : MNHTTPDataRequest

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, copy) NSString *downloadUrl;

- (instancetype)initWithVideoUrl:(NSString *_Nullable)url;

@end

NS_ASSUME_NONNULL_END
