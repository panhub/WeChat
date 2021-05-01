//
//  MNVideoTailorView.h
//  MNKit
//
//  Created by Vicent on 2020/8/10.
//  视频裁剪缩略图

#import <UIKit/UIKit.h>
#import "MNVideoKeyfram.h"
#import "MNTailorHandler.h"
@class MNVideoTailorView;

@protocol MNVideoTailorViewDelegate <NSObject>
@optional
/**开始加载截图*/
- (void)tailorViewBeginLoadThumbnails:(MNVideoTailorView *_Nonnull)tailorView;
/**已经加载截图*/
- (void)tailorViewDidLoadThumbnails:(MNVideoTailorView *_Nonnull)tailorView;
/**加载截图失败*/
- (void)tailorViewLoadThumbnailsFailed:(MNVideoTailorView *_Nonnull)tailorView;
/**左滑手开始拖拽*/
- (void)tailorViewLeftHandlerBeginDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**左滑手拖拽中*/
- (void)tailorViewLeftHandlerDidDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**左滑手停止拖拽*/
- (void)tailorViewLeftHandlerEndDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**右滑手开始拖拽*/
- (void)tailorViewRightHandlerBeginDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**右滑手拖拽中*/
- (void)tailorViewRightHandlerDidDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**右滑手拖拽中*/
- (void)tailorViewRightHandlerEndDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**指针开始拖拽*/
- (void)tailorViewPointerBeginDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**指针拖拽中*/
- (void)tailorViewPointerDidDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**指针停止拖拽*/
- (void)tailorViewPointerEndDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**截图开始拖拽*/
- (void)tailorViewBeginDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**截图拖拽中*/
- (void)tailorViewDidDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**截图停止拖拽*/
- (void)tailorViewEndDragging:(MNVideoTailorView *_Nonnull)tailorView;
/**播放到指定位置*/
- (void)tailorViewDidEndPlaying:(MNVideoTailorView *_Nonnull)tailorView;
@end

#define MNVideoTailorWhiteColor [UIColor colorWithHex:@"F7F7F7"]
#define MNVideoTailorBlackColor [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f]

NS_ASSUME_NONNULL_BEGIN

@interface MNVideoTailorView : UIView
/**进度*/
@property (nonatomic) float progress;
/**开始位置进度*/
@property (nonatomic, readonly) float begin;
/**结束进度*/
@property (nonatomic, readonly) float end;
/**视频文件路径*/
@property (nonatomic, copy) NSString *videoPath;
/**指针*/
@property (nonatomic, strong, readonly) UIView *pointer;
/**最小裁剪时长*/
@property (nonatomic) NSTimeInterval minTailorDuration;
/**最大裁剪时长*/
@property (nonatomic) NSTimeInterval maxTailorDuration;
/**是否在拖拽左右滑手*/
@property (nonatomic, getter=isDragging) BOOL dragging;
/**滑动视图*/
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
/**裁剪滑手*/
@property (nonatomic, strong, readonly) MNTailorHandler *tailorHandler;
/**事件代理*/
@property (nonatomic, weak) id<MNVideoTailorViewDelegate> delegate;
/**是否已经播放到了结束位置*/
@property (nonatomic, readonly) BOOL isEndPlaying;
/**携带附加信息*/
@property (nonatomic, strong) id userInfo;

/**禁止直接初始化*/
- (instancetype)init NS_UNAVAILABLE;

/**
 设置圆角
 @param maskRadius 圆角半径
 */
- (void)setMaskRadius:(CGFloat)maskRadius;

/**
 加载视频截图
 */
- (void)loadThumbnails;

/**
 移动指针到起始位置
 */
- (void)movePointerToBegin;

/**
 移动指针到结束位置
 */
- (void)movePointerToEnd;

@end

NS_ASSUME_NONNULL_END
