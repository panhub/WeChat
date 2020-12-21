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

/**调整后的旋转方向*/
@property (nonatomic, readonly) CGAffineTransform positiveTransform;

/**
 获取视频在渲染尺寸下所需坐标转换
 @param renderSize 渲染尺寸<分辨率>
 @return 坐标转换
 */
- (CGAffineTransform)transformWithRenderSize:(CGSize)renderSize;

/**
 获取视频区域裁剪所需坐标转换
 @param outputRect 裁剪区域
 @param renderSize 分辨率
 @return 坐标转换
 */
- (CGAffineTransform)transformWithRect:(CGRect)outputRect renderSize:(CGSize)renderSize;

@end
