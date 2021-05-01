//
//  MNCameraPreview.h
//  MNKit
//
//  Created by Vicent on 2021/3/9.
//  Copyright © 2021 Vincent. All rights reserved.
//  相机预览视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNCameraPreview : UIView

/**内容*/
@property (nonatomic, readonly, nullable) id contents;

/**
 暂停视频播放/停止LivePhoto播放
 */
- (void)pause;

/**
 开始视频播放/LivePhoto播放
 */
- (void)play;

/**
 停止一切展示, 重置原位
 */
- (void)stop;

/**
 预览图片
 @param image 图片
 */
- (void)previewImage:(UIImage *)image;

/**
 预览视频
 @param videoURL 视频地址
 */
- (void)previewVideoOfURL:(NSURL *)videoURL;

/**
 展示LivePhoto
 @param imageData 瞬时图数据流
 @param videoURL 视频地址
 */
- (void)previewLivePhotoUsingImageData:(NSData *)imageData videoURL:(NSURL *)videoURL;

@end

NS_ASSUME_NONNULL_END
