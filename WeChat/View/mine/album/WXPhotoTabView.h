//
//  WXPhotoTabView.h
//  WeChat
//
//  Created by Vicent on 2021/4/23.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册-底部控制

#import <UIKit/UIKit.h>
@class WXProfile;

NS_ASSUME_NONNULL_BEGIN

@interface WXPhotoTabView : UIView

/**图片数据模型*/
@property (nonatomic, strong) WXProfile *profile;

/**
 设置点赞交互
 @param target 响应对象
 @param action 响应方法
 */
- (void)addLikeTargetForTouchEvent:(id)target action:(SEL)action;

/**
 设置评论交互
 @param target 响应对象
 @param action 响应方法
 */
- (void)addCommentTargetForTouchEvent:(id)target action:(SEL)action;

/**
 设置详情交互
 @param target 响应对象
 @param action 响应方法
 */
- (void)addDetailTargetForTouchEvent:(id)target action:(SEL)action;

/**
 更新视图
 */
- (void)update;

/**
 开始点赞动画
 */
- (void)startLikeAnimation;

@end

NS_ASSUME_NONNULL_END
