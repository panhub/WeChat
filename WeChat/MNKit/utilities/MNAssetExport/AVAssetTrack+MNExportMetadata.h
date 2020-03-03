//
//  AVAssetTrack+MNExportMetadata.h
//  MNKit
//
//  Created by Vincent on 2019/12/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源输出

#import <AVFoundation/AVFoundation.h>

@interface AVAssetTrack (MNExportMetadata)

/**旋转弧度*/
@property (nonatomic, readonly) CGFloat rotateRadian;

/**视频尺寸*/
@property (nonatomic, readonly) CGSize naturalSizeOfVideo;

/**
 获取视频区域裁剪所需坐标转换
 @param outputRect 裁剪区域
 @param renderSize 分辨率
 @return 坐标转换
 */
- (CGAffineTransform)naturalTransformWithRect:(CGRect)outputRect renderSize:(CGSize)renderSize;

@end
