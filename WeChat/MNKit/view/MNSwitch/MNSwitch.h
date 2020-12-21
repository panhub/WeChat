//
//  MNSwitch.h
//  SHPhoto
//
//  Created by Vicent on 2020/6/2.
//  Copyright © 2020 Vicent. All rights reserved.
//  开关按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNSwitch : UIView

/**开启时的颜色*/
@property(nullable, nonatomic, strong) UIColor *onTintColor;

/**开关标志颜色*/
@property(nullable, nonatomic, strong) UIColor *thumbTintColor;

/**是否开启状态*/
@property(nonatomic,getter=isOn) BOOL on;

/**
 设置开启状态
 @param on 开启状态
 @param animated 是否有动画
 */
- (void)setOn:(BOOL)on animated:(BOOL)animated;

/**
 添加是否允许修改开关 <必须以BOOL类型返回>
 @param target 响应者
 @param action 响应方法
 */
- (void)addTarget:(id)target forValueShouldChange:(SEL)action;

/**
  添加开关改变响应方法
  @param target 响应者
  @param action 响应方法
 */
- (void)addTarget:(id)target forValueChanged:(SEL)action;

@end

NS_ASSUME_NONNULL_END
