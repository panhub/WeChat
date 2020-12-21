//
//  MNCapturingView.h
//  MNKit
//
//  Created by Vincent on 2019/6/13.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频录制/拍照控制

#import <UIKit/UIKit.h>
@class MNCapturingView;

/**
 控制栏状态
 - MNCapturingViewStateNormal: 正常
 - MNCapturingViewStateWaiting: 等待下一步指示
 - MNCapturingViewStateCapturing: 捕获数据<工作中>
 - MNCapturingViewStateFinished: 播放状态
 */
typedef NS_ENUM(NSInteger, MNCapturingViewState) {
    MNCapturingViewStateNormal = 0,
    MNCapturingViewStateWaiting,
    MNCapturingViewStateCapturing,
    MNCapturingViewStateFinished
};

typedef NS_OPTIONS(NSInteger, MNCapturingOptions) {
    MNCapturingOptionPhoto = 1 << 0,
    MNCapturingOptionVideo = 1 << 1
};

@protocol MNCapturingViewDelegate <NSObject>
@optional;
- (void)capturingViewCloseButtonClicked:(MNCapturingView *)capturingView;
- (void)capturingViewBackButtonClicked:(MNCapturingView *)capturingView;
- (void)capturingViewDoneButtonClicked:(MNCapturingView *)capturingView;
- (void)capturingViewShoudBeginCapturing:(MNCapturingView *)capturingView;
- (void)capturingViewDidEndCapturing:(MNCapturingView *)capturingView;
- (void)capturingViewShoudCapturingStillImage:(MNCapturingView *)capturingView;
@end

@interface MNCapturingView : UIView

@property (nonatomic) MNCapturingViewState state;

@property (nonatomic) MNCapturingOptions options;

@property (nonatomic) NSTimeInterval timeoutInterval;

@property (nonatomic, weak) id<MNCapturingViewDelegate> delegate;

- (void)startCapturing;

- (void)stopCapturing;

- (void)resetCapturing;

@end
