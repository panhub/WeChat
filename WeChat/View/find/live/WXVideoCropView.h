//
//  WXVideoCropView.h
//  KPoint
//
//  Created by 小斯 on 2019/8/19.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXVideoCropView;

@protocol WXVideoCropDelegate <NSObject>
@optional;
/// 将要加载缩略图
- (void)videoCropViewWillLoadThumbnails:(WXVideoCropView *)cropView;
/// 加载缩略图失败
- (void)videoCropViewLoadThumbnailsFailure:(WXVideoCropView *)cropView;
/// 加载缩略图完成
- (void)videoCropViewLoadThumbnailsFinish:(WXVideoCropView *)cropView;
/// 想要拖拽
- (BOOL)videoCropViewShouldBeginDragging:(WXVideoCropView *)cropView;
/// 即将开始拖拽
- (void)videoCropViewWillBeginDragging:(WXVideoCropView *)cropView;
/// 左滑手拖拽中
- (void)videoCropViewLeftHandlerDidDragging:(WXVideoCropView *)cropView;
/// 右滑手拖拽中
- (void)videoCropViewRightHandlerDidDragging:(WXVideoCropView *)cropView;
/// 左滑手结束拖拽
- (void)videoCropViewLeftHandlerDidEndDragging:(WXVideoCropView *)cropView;
/// 右滑手结束拖拽
- (void)videoCropViewRightHandlerDidEndDragging:(WXVideoCropView *)cropView;
/// 已经到达最大限制
- (void)videoCropViewDidEndLimiting:(WXVideoCropView *)cropView;
@end

@interface WXVideoCropView : UIView
/**
 视频资源路径
 */
@property (nonatomic, copy) NSString *videoPath;
/**
 视频资源时长
 */
@property (nonatomic, readonly) NSTimeInterval duration;
/**
 事件代理
 */
@property (nonatomic, weak) id<WXVideoCropDelegate> delegate;
/**
 是否在拖拽
 */
@property (nonatomic, readonly, getter=isDragging) BOOL dragging;
/**
 左滑手
 */
@property (nonatomic, strong, readonly) UIImageView *leftHandler;
/**
 播放进度
 */
@property (nonatomic) float progress;
/**
 左滑手进度
 */
@property (nonatomic, readonly) float leftProgress;
/**
 右滑手进度
 */
@property (nonatomic, readonly) float rightProgress;
/**
 裁剪区间<进度形式>
 */
@property (nonatomic, readonly) MNRange cropRange;

/**
 调整裁剪片段到指定时长
 @param duration 指定时长
 */
- (void)resizingCropFragmentToDuration:(CGFloat)duration;

@end

