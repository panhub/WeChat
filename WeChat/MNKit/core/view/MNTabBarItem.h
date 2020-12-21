//
//  MNTabBarItem.h
//  MNKit
//
//  Created by Vincent on 2018/12/14.
//  Copyright © 2018年 小斯. All rights reserved.
//  取代系统UITabBarItem

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNTabBadgeAlignment) {
    MNTabBadgeAlignmentLeft = 0,
    MNTabBadgeAlignmentRight,
    MNTabBadgeAlignmentCenter
};

@interface MNTabBarItem : UIControl <UIAppearance>

/**
 正常状态标题
 */
@property (nonatomic, copy) NSString *title;
/**
 选择状态标题
 */
@property (nonatomic, copy) NSString *selectedTitle;
/**
 正常状态标题颜色
 */
@property (nonatomic, copy) UIColor *titleColor UI_APPEARANCE_SELECTOR;
/**
 选择状态标题颜色
 */
@property (nonatomic, copy) UIColor *selectedTitleColor UI_APPEARANCE_SELECTOR;
/**
 标题偏移
 */
@property (nonatomic, assign) UIOffset titleOffset UI_APPEARANCE_SELECTOR;
/**
 标题字体
 */
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
/**
 标题位置
 */
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets UI_APPEARANCE_SELECTOR;
/**
 正常状态图片
 */
@property (nonatomic, strong) UIImage *image;
/**
 选择状态图片
 */
@property (nonatomic, strong) UIImage *selectedImage;
/**
 图片位置
 */
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets UI_APPEARANCE_SELECTOR;
/**
 角标偏移
 */
@property (nonatomic, assign) UIOffset badgeOffset UI_APPEARANCE_SELECTOR;
/**
 角标字体
 */
@property (nonatomic, strong) UIFont *badgeFont UI_APPEARANCE_SELECTOR;
/**
 角标背景颜色
 */
@property (nonatomic, strong) UIColor *badgeColor UI_APPEARANCE_SELECTOR;
/**
 角标字体颜色
 */
@property (nonatomic, strong) UIColor *badgeTextColor UI_APPEARANCE_SELECTOR;
/**
 角标对齐方式<以图片的右上角为焦点对齐>
 */
@property (nonatomic, assign) MNTabBadgeAlignment badgeAlignment UI_APPEARANCE_SELECTOR;
/**
 角标
 */
@property (nonatomic, copy) NSString *badgeValue;

@end
