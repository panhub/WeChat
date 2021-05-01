//
//  MNAlertProtocol.h
//  MNKit
//
//  Created by Vicent on 2020/7/27.
//  Copyright © 2020 Vincent. All rights reserved.
//  关于弹框统一定制方法

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MNAlertProtocol <NSObject>
@optional
/**是否在展示中*/
@property (nonatomic, readonly, class) BOOL isPresenting;
/**
 弹出视图到window
 */
- (void)show;
/**
 弹出到指定视图
 @param superview 指定父视图
 */
- (void)showInView:(UIView *_Nullable)superview;
/**
 消失
 */
- (void)dismiss;
/**
 取消弹出视图
 */
+ (void)close;

@end

NS_ASSUME_NONNULL_END
