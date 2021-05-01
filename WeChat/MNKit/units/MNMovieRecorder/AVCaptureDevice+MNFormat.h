//
//  AVCaptureDevice+MNFormat.h
//  MNKit
//
//  Created by Vicent on 2021/3/3.
//  Copyright © 2021 Vincent. All rights reserved.
//

#if __has_include(<AVFoundation/AVFoundation.h>)
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureDevice (MNFormat)

/**是否高帧率*/
@property (nonatomic, readonly) BOOL isHighFrameRate;

/**最大的帧率支持格式*/
@property (nonatomic, readonly, nullable) AVFrameRateRange *maxFrameRateRange;

/**最大的帧率支持格式*/
@property (nonatomic, readonly, nullable) AVCaptureDeviceFormat *maxFrameRateFormat;

@end

NS_ASSUME_NONNULL_END
#endif
