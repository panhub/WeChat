//
//  MNCardLayout.h
//  MNKit
//
//  Created by Vincent on 2018/3/28.
//  Copyright © 2018年 小斯. All rights reserved.
//  卡片浏览器 布局对象

#import <UIKit/UIKit.h>

/**
 约束类型
 - MNCardLayoutTypeZoom: 缩放效果<默认>
 - MNCardLayoutTypeRotation: 翻转效果
 */
typedef NS_ENUM(NSInteger, MNCardLayoutType) {
    MNCardLayoutTypeZoom = 0,
    MNCardLayoutTypeRotation
};

@interface MNCardLayout : UICollectionViewFlowLayout

/**
 约束类型, 决定采用的动画
 */
@property (nonatomic, assign) MNCardLayoutType type;

@end
