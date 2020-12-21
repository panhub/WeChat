//
//  MNPlayView.h
//  MNKit
//
//  Created by Vincent on 2018/10/12.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNPlayView;

@protocol MNPlayViewDelegate <NSObject>
@optional;
/**点击操作*/
- (void)playViewDidClicked:(MNPlayView *)playView;
/**即将改变进度 返回当前进度信息*/
- (CGFloat)playViewShouldChangeProgress;
/**将进度信息返回*/
- (void)playViewDidChangeProgress:(CGFloat)progress;
/**滑动操作已经完成*/
- (void)playViewDidEndInteracting:(MNPlayView *)playView;
@end

@interface MNPlayView : UIView
@property (nonatomic, assign, readonly) CGFloat value;
@property (nonatomic, weak) id<MNPlayViewDelegate> delegate;
@property (nonatomic, assign, getter=isTouchEnabled) BOOL touchEnabled;
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled;
@end

