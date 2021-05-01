//
//  AVCaptureDevice+MNFormat.m
//  MNKit
//
//  Created by Vicent on 2021/3/3.
//  Copyright © 2021 Vincent. All rights reserved.
//

#if __has_include(<AVFoundation/AVFoundation.h>)
#import "AVCaptureDevice+MNFormat.h"

@implementation AVCaptureDevice (MNFormat)
- (BOOL)isHighFrameRate {
    AVFrameRateRange *frameRateRange = self.maxFrameRateRange;
    return (frameRateRange && frameRateRange.maxFrameRate >= 30.f);
}

- (AVCaptureDeviceFormat *)maxFrameRateFormat {
    AVFrameRateRange *frameRateRange;
    AVCaptureDeviceFormat *frameRateFormat;
    for (AVCaptureDeviceFormat *format in self.formats) {
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        //codecType 是一个无符号32位的数据类型, 但是是由四个字符对应的四个字节组成, 一般可能值为 "420v" 或 "420f", 这里选取 420v 格式来配置
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            NSArray <AVFrameRateRange *>*frameRateRanges = format.videoSupportedFrameRateRanges;
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > frameRateRange.maxFrameRate) {
                    frameRateRange = range;
                    frameRateFormat = format;
                }
            }
        }
    }
    return frameRateFormat;
}

- (AVFrameRateRange *)maxFrameRateRange {
    AVFrameRateRange *frameRateRange;
    AVCaptureDeviceFormat *frameRateFormat;
    for (AVCaptureDeviceFormat *format in self.formats) {
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        //codecType 是一个无符号32位的数据类型, 但是是由四个字符对应的四个字节组成, 一般可能值为 "420v" 或 "420f", 这里选取 420v 格式来配置
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
            NSArray <AVFrameRateRange *>*frameRateRanges = format.videoSupportedFrameRateRanges;
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > frameRateRange.maxFrameRate) {
                    frameRateRange = range;
                    frameRateFormat = format;
                }
            }
        }
    }
    return frameRateRange;
}

@end
#endif
