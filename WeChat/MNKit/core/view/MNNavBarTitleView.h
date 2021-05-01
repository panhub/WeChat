//
//  MCTCustomTitleView.h
//  MNKit
//
//  Created by Vincent on 2017/6/19.
//  Copyright © 2017年 小斯. All rights reserved.
//  自定义导航栏上的标题视图

#import <UIKit/UIKit.h>

@interface MNNavBarTitleView : UIView

/**
 如非必要, 不建议直接使用, 使用controller.title修改更优雅
 */
@property (nonatomic, copy) NSString *title;
/**
 如非必要, 不建议直接使用, 使用导航栏属性修改更优雅
 */
@property (nonatomic, readonly, strong) UILabel *titleLabel;

@end
