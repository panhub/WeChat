//
//  MNCaptureToolBar.h
//  MNKit
//
//  Created by Vincent on 2019/6/13.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频录制/拍照控制

#import <UIKit/UIKit.h>
@class MNCaptureToolBar;

typedef NS_OPTIONS(NSInteger, MNCaptureOptions) {
    MNCaptureOptionNone = 0,
    MNCaptureOptionPhoto = 1 << 1,
    MNCaptureOptionVideo = 1 << 2
};

UIKIT_EXTERN const CGFloat MNCaptureToolBarMinHeight;
UIKIT_EXTERN const CGFloat MNCaptureToolBarMaxHeight;
UIKIT_EXTERN const NSTimeInterval MNCaptureToolBarAnimationDuration;

@protocol MNCaptureToolDelegate <NSObject>
@optional;
- (BOOL)captureToolBarShouldTakingPhoto:(MNCaptureToolBar *)toolBar;
- (BOOL)captureToolBarShouldCapturingVideo:(MNCaptureToolBar *)toolBar;
- (void)captureToolBarCloseButtonClicked:(MNCaptureToolBar *)toolBar;
- (void)captureToolBarBackButtonClicked:(MNCaptureToolBar *)toolBar;
- (void)captureToolBarDoneButtonClicked:(MNCaptureToolBar *)toolBar;
- (void)captureToolBarDidBeginCapturingVideo:(MNCaptureToolBar *)toolBar;
- (void)captureToolBarDidEndCapturingVideo:(MNCaptureToolBar *)toolBar;
- (void)captureToolBarDidBeginTakingPhoto:(MNCaptureToolBar *)toolBar;
@end

@interface MNCaptureToolBar : UIView

/**功能选项*/
@property (nonatomic) MNCaptureOptions options;

/**最大时长*/
@property (nonatomic) NSTimeInterval timeoutInterval;

/**事件代理*/
@property (nonatomic, weak) id<MNCaptureToolDelegate> delegate;

/**开始拍摄*/
- (void)startCapturing;

/**停止拍摄*/
- (void)stopCapturing;

/**重置*/
- (void)resetCapturing;

@end
