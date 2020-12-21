//
//  MNAdsorbView.h
//  MNKit
//
//  Created by Vincent on 2018/12/10.
//  Copyright © 2018年 小斯. All rights reserved.
//  吸附效果图

#import <UIKit/UIKit.h>

@interface MNAdsorbView : UIView
/**
 推荐将控件添加到内容视图上
 */
@property (nonatomic, strong, readonly) UIView *contentView;
/**
 吸附效果图
 */
@property (nonatomic, weak, readonly) UIImageView *imageView;


/**
 子类若实现相同方法, 必须调用super
 */
- (void)createView __attribute__((objc_requires_super));

@end


