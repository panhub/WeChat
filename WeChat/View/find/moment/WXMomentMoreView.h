//
//  WXMomentMoreView.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  更多操作视图

#import <UIKit/UIKit.h>

@interface WXMomentMoreView : UIView

/**目标视图*/
@property (nonatomic, weak) UIView *targetView;

/**是否已点赞*/
@property (nonatomic, getter=isLiked) BOOL liked;

/**按钮点击事件*/
@property (nonatomic, copy) void (^eventHandler) (NSUInteger idx);

- (void)show;

- (void)showAtView:(UIView *)view;

- (void)showAtView:(UIView *)view animated:(BOOL)animated;

- (void)dismiss;

- (void)dismissWithAnimated:(BOOL)animated;

- (void)dismissWithCompletionHandler:(void (^)(BOOL finished))completion;

@end
