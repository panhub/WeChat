//
//  MNTableViewCellEditView.h
//  MNKit
//
//  Created by Vincent on 2019/4/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  编辑按钮视图

#import <UIKit/UIKit.h>
@class MNTableViewCellEditAction;
@class MNTableViewCellEditView;

@protocol MNTableViewCellEditViewDelegate <NSObject>
@optional
- (void)tableViewCellEditView:(MNTableViewCellEditView *)editView didClickAction:(MNTableViewCellEditAction *)action;
@end

@interface MNTableViewCellEditView : UIView

@property (nonatomic, readonly) CGFloat totalWidth;
@property (nonatomic, strong, readonly) NSArray<UIView *> *contentViews;
@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *>*contentWidths;
@property (nonatomic, weak) id<MNTableViewCellEditViewDelegate> delegate;

/**
 更新按钮
 @param actions 动作按钮
 */
- (void)updateContentViews:(NSArray<MNTableViewCellEditAction *> *)actions;

/**
 删除所有内容
 */
- (void)removeContentViews;

/**
 根据缓存信息, 复原内容视图
 */
- (void)resetting;

/**
 当外部修改自身大小时, 约束内容视图位置
 */
- (void)layoutContentIfNeeded;

/**
 以拉伸的方式形变到某个长度<自身不变, 仅修改内容视图>
 @param width 实时长度
 */
- (void)autoresizing:(CGFloat)width;

@end
