//
//  MNCapturingToolBar.h
//  MNKit
//
//  Created by Vincent on 2019/6/13.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频录制/拍照控制

#import <UIKit/UIKit.h>
@class MNCapturingToolBar;

typedef NS_OPTIONS(NSInteger, MNCapturingOptions) {
    MNCapturingOptionPhoto = 1 << 0,
    MNCapturingOptionVideo = 1 << 1
};

UIKIT_EXTERN const CGFloat MNCaptureToolBarMinHeight;
UIKIT_EXTERN const CGFloat MNCaptureToolBarMaxHeight;

@protocol MNCapturingToolDelegate <NSObject>
@optional;
- (void)capturingToolBarCloseButtonClicked:(MNCapturingToolBar *)toolBar;
- (void)capturingToolBarBackButtonClicked:(MNCapturingToolBar *)toolBar;
- (void)capturingToolBarDoneButtonClicked:(MNCapturingToolBar *)toolBar;
- (void)capturingToolBarShoudBeginCapturing:(MNCapturingToolBar *)toolBar;
- (void)capturingToolBarDidEndCapturing:(MNCapturingToolBar *)toolBar;
- (void)capturingToolBarShoudTakeStillImage:(MNCapturingToolBar *)toolBar;
@end

@interface MNCapturingToolBar : UIView

/**功能选项*/
@property (nonatomic) MNCapturingOptions options;

/**最大时长*/
@property (nonatomic) NSTimeInterval timeoutInterval;

/**事件代理*/
@property (nonatomic, weak) id<MNCapturingToolDelegate> delegate;

/**开始拍摄*/
- (void)startCapturing;

/**停止拍摄*/
- (void)stopCapturing;

/**重置*/
- (void)resetCapturing;

@end
