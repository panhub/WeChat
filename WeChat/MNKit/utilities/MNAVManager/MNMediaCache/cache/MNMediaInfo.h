//
//  MNMediaInfo.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//  媒体文件信息

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNMediaInfo : NSObject<NSCoding>

@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, assign) BOOL byteRangeAccessSupported;
@property (nonatomic, assign) unsigned long long contentLength;
@property (nonatomic) unsigned long long downloadedContentLength;

@end

NS_ASSUME_NONNULL_END
