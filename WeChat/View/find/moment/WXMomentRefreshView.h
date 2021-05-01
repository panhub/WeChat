//
//  WXMomentRefreshView.h
//  WeChat
//
//  Created by Vicent on 2021/3/27.
//  Copyright © 2021 Vincent. All rights reserved.
//  朋友圈刷新

#import <UIKit/UIKit.h>
@class WXMomentRefreshView;

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentRefreshView : UIView

/**是否刷新状态*/
@property (nonatomic, readonly) BOOL isRefreshing;

/**监听视图偏移变化*/
- (void)observeScrollView:(UIScrollView *_Nullable)scrollView;

/**添加刷新响应消息*/
- (void)setTarget:(id)target forRefreshAction:(SEL)action;

/**结束刷新*/
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
