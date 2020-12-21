//
//  MNSegmentConfiguration.h
//  MNKit
//
//  Created by Vincent on 2018/12/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 分段内容不足时补全方案
 - MNSegmentContentModeNormal: 不做处理<其后留白>
 - MNSegmentContentModeFit: 居中<前后留白>s
 - MNSegmentContentModeFill: 充满<无留白>
 */
typedef NS_ENUM(NSInteger, MNSegmentContentMode) {
    MNSegmentContentModeNormal = 0,
    MNSegmentContentModeFit,
    MNSegmentContentModeFill
};

/**
 当前选择项标记视图
 - MNSegmentShadowMaskFit: 与标题一致
 - MNSegmentShadowMaskFill: 与item等宽
 - MNSegmentShadowMaskAspectFit: 标题宽度一半
 - MNSegmentShadowMaskUsingWidth: 使用 shadowSize.width
 */
typedef NS_ENUM(NSInteger, MNSegmentShadowMask) {
    MNSegmentShadowMaskFit = 0,
    MNSegmentShadowMaskFill,
    MNSegmentShadowMaskAspectFit,
    MNSegmentShadowMaskUsingWidth
};

/**
 当前选择项标记视图
 - MNSegmentShadowVerticalAlignmentTop: 顶部
 - MNSegmentShadowVerticalAlignmentCenter: 中间
 - MNSegmentShadowVerticalAlignmentBottom: 底部
 */
typedef NS_ENUM(NSInteger, MNSegmentShadowVerticalAlignment) {
    MNSegmentShadowVerticalAlignmentTop = -2,
    MNSegmentShadowVerticalAlignmentCenter = -1,
    MNSegmentShadowVerticalAlignmentBottom = 0
};

/**
 当前选择项标记视图
 - MNSegmentShadowHorizontalAlignmentLeft: 左对齐
 - MNSegmentShadowHorizontalAlignmentCenter: 中间位置
 - MNSegmentShadowHorizontalAlignmentRight: 右对齐
 */
typedef NS_ENUM(NSInteger, MNSegmentShadowHorizontalAlignment) {
    MNSegmentShadowHorizontalAlignmentLeft = -1,
    MNSegmentShadowHorizontalAlignmentCenter = 0,
    MNSegmentShadowHorizontalAlignmentRight = 1
};

/**
 标题栏选择后滚动位置
 - MNSegmentScrollPositionNone: 不允许滚动
 - MNSegmentScrollPositionLeft: 左侧
 - MNSegmentScrollPositionCenter: 中间
 - MNSegmentScrollPositionRight: 右侧
 */
typedef NS_ENUM(NSUInteger, MNSegmentScrollPosition) {
    MNSegmentScrollPositionNone = 0,
    MNSegmentScrollPositionLeft,
    MNSegmentScrollPositionCenter,
    MNSegmentScrollPositionRight
};

@interface MNSegmentConfiguration : NSObject
/**分段列表高度*/
@property (nonatomic) CGFloat height;
/**当标题不够时的处理方案*/
@property (nonatomic) MNSegmentContentMode contentMode;
/**当前选择项标记视图的宽度解决方案*/
@property (nonatomic) MNSegmentShadowMask shadowMask;
/**标题栏选择后滚动位置处理方案*/
@property (nonatomic) MNSegmentScrollPosition scrollPosition;
/**选择线宽高, 宽度使用需 shadowMask 配合*/
@property (nonatomic) CGSize shadowSize;
/**选择线颜色*/
@property (nonatomic, copy) UIColor *shadowColor;
/**标题正常颜色*/
@property (nonatomic, copy) UIColor *titleColor;
/**标题选择颜色*/
@property (nonatomic, copy) UIColor *selectedColor;
/**底部分割线颜色*/
@property (nonatomic, copy) UIColor *separatorColor;
/**背景颜色*/
@property (nonatomic, copy) UIColor *backgroundColor;
/**标题字体*/
@property (nonatomic, copy) UIFont *titleFont;
/**标题选择状态下字体*/
@property (nonatomic, copy) UIFont *selectedTitleFont;
/**标题的追加宽度, 间隔为此宽度一半*/
@property (nonatomic) CGFloat titleMargin;
/**选择线纵向对齐方式*/
@property (nonatomic) MNSegmentShadowVerticalAlignment shadowVerticalAlignment;
/**选择线横向对齐方式*/
@property (nonatomic) MNSegmentShadowHorizontalAlignment shadowHorizontalAlignment;
/**选择线偏移量*/
@property (nonatomic) UIOffset shadowOffset;
@end

