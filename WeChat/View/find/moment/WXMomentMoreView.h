//
//  WXMomentMoreView.h
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  更多操作视图

#import <UIKit/UIKit.h>

@interface WXMomentMoreView : UIView

@property (nonatomic, copy) void (^eventHandler) (NSUInteger idx);

@property (nonatomic, weak) UIView *targetView;

- (void)show;

- (void)showAtView:(UIView *)view;

- (void)showAtView:(UIView *)view animated:(BOOL)animated;

- (void)dismiss;

- (void)dismissWithAnimated:(BOOL)animated;

- (void)dismissWithCompletionHandler:(void (^)(BOOL finished))completion;

@end
