//
//  MNRecordView.h
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//  微信录音视图

#import <UIKit/UIKit.h>

/**
 录音状态
 - MNRecordViewStateNormal: 正常状态
 - MNRecordViewStateCancel: 松开取消
 - MNRecordViewStateTimeout: 即将超时
 - MNRecordViewStateStop: 已超时主动停止
 */
typedef NS_ENUM(NSInteger, MNRecordViewState) {
    MNRecordViewStateNormal = 0,
    MNRecordViewStateCancel,
    MNRecordViewStateTimeout,
    MNRecordViewStateStop
};

@protocol MNRecordViewViewDelegate <NSObject>

- (void)voiceRecordTimeoutNeedStop:(int)duration;

@end

@interface MNRecordView : UIView

@property (nonatomic) MNRecordViewState state;

@property (nonatomic) id<MNRecordViewViewDelegate> delegate;

- (void)show;

- (void)dismiss;

- (void)setDuration:(int)duration power:(float)power;

@end
