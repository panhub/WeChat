//
//  MNTableViewCellEditAction.h
//  MNKit
//
//  Created by Vincent on 2019/4/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  编辑按钮模型

#import <Foundation/Foundation.h>
@class MNTableViewCellEditAction;

typedef NS_ENUM(NSInteger, MNTableViewCellEditingStyle) {
    MNTableViewCellEditingStyleNormal = 0,
    MNTableViewCellEditingStyleDelete
};

@interface MNTableViewCellEditAction : NSObject
/**索引*/
@property (nonatomic, readonly) NSInteger index;
/**样式*/
@property (nonatomic) MNTableViewCellEditingStyle style;
/**内容左右间距. 默认15*/
@property (nonatomic) UIEdgeInsets inset;
/**
 文字有值时, 宽度由文字和inset决定;
 图片不为nil时, 宽度可自定
*/
@property (nonatomic) CGFloat width;
/**文字内容*/
@property (nonatomic, copy) NSString *title;
/**按钮图片, 默认无图*/
@property (nonatomic, strong) UIImage *image;
/**字体大小, 默认17*/
@property (nonatomic, strong) UIFont *titleFont;
/**文字颜色, 默认白色*/
@property (nonatomic, strong) UIColor *titleColor;
/**背景颜色, 默认透明*/
@property (nonatomic, strong) UIColor *backgroundColor;

+ (instancetype)actionWithStyle:(MNTableViewCellEditingStyle)style;

@end
