//
//  MNLinkTableConfiguration.h
//  MNKit
//
//  Created by Vincent on 2019/6/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  Table配置文件

#import <Foundation/Foundation.h>

/**
 标题栏选择后滚动位置
 - MNSegmentScrollPositionNone: 不允许滚动
 - MNLinkTableScrollPositionTop: 顶部
 - MNLinkTableScrollPositionMiddle: 中间
 - MNLinkTableScrollPositionBottom: 底部
 */
typedef NS_ENUM(NSUInteger, MNLinkTableScrollPosition) {
    MNLinkTableScrollPositionNone = 0,
    MNLinkTableScrollPositionTop,
    MNLinkTableScrollPositionMiddle,
    MNLinkTableScrollPositionBottom
};

@interface MNLinkTableConfiguration : NSObject

/**列表宽度*/
@property (nonatomic, assign) CGFloat width;
/**选择项高度*/
@property (nonatomic, assign) CGFloat rowHeight;
/**选择线宽度*/
@property (nonatomic, assign) CGFloat shadowWidth;
/**分割线间隔*/
@property (nonatomic, assign) UIEdgeInsets separatorInset;
/**选择线颜色*/
@property (nonatomic, strong) UIColor *shadowColor;
/**标题正常颜色*/
@property (nonatomic, strong) UIColor *titleColor;
/**标题选择颜色*/
@property (nonatomic, strong) UIColor *selectedTitleColor;
/**Table背景颜色*/
@property (nonatomic, strong) UIColor *backgroundColor;
/**Cell背景颜色*/
@property (nonatomic, strong) UIColor *cellNormalColor;
/**Cell选择后背景颜色*/
@property (nonatomic, strong) UIColor *cellHighlightedColor;
/**分割线颜色*/
@property (nonatomic, strong) UIColor *separatorColor;
/**标题字体*/
@property (nonatomic, strong) UIFont *titleFont;
/**标题位置*/
@property (nonatomic, assign) UIEdgeInsets titleInset;
/**标题行数*/
@property (nonatomic, assign) NSInteger titleNumberOfLines;
/**表头视图*/
@property (nonatomic, strong) UIView *tableHeaderView;
/**表尾视图*/
@property (nonatomic, strong) UIView *tableFooterView;
/**标题排列方式*/
@property (nonatomic, assign) NSTextAlignment titleAlignment;
/**标题栏选择后滚动位置处理方案*/
@property (nonatomic, assign) MNLinkTableScrollPosition scrollPosition;

@end

