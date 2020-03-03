//
//  MCTBaseTableViewCell.h
//  MNKit
//
//  Created by Vincent on 2017/6/16.
//  Copyright © 2017年 小斯. All rights reserved.
//  支持仿微信左滑编辑功能表格
//  开启方法 : allowsEditing

#import <UIKit/UIKit.h>
#import "MNTableViewCellEditAction.h"
@class MNTableViewCell;

@protocol MNTableViewCellDelegate <NSObject>
/**
 是否允许编辑
 @param cell 表格
 @param indexPath 索引
 @return 是否允许编辑
 */
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 编辑动作
 @param cell 表格
 @param indexPath 索引
 @return 编辑动作
 */
- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 编辑按钮点击处理
 @param cell 表格
 @param action 动作
 @param indexPath 索引
 @return 二次处理视图
 */
- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MNTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

/**
 预留标题信息控件
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/**
 预留描述信息控件
 */
@property (nonatomic, strong, readonly) UILabel *detailLabel;
/**
 预留图片控件
 */
@property (nonatomic, strong, readonly) UIImageView *imgView;
/**
 交互代理
 */
@property (nonatomic, weak) id<MNTableViewCellDelegate> delegate;
/**
 是否编辑开启入口
 */
@property (nonatomic) BOOL allowsEditing;
/**
 编辑视图
 */
@property (nonatomic, readonly, weak) UIView *editingView;
/**
 是否处于编辑状态
 */
@property (nonatomic, readonly, getter=isEdit) BOOL edit;
/**
 滑动手势冲突
 */
@property (nonatomic, weak) UIGestureRecognizer *failToGestureRecognizer;


/**
 推荐初始化入口
 @param reuseIdentifier 唯一标识
 @param size 尺寸
 @return cell实例
 */
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;

/**
 用于添加到某视图时初始化
 @param reuseIdentifier 唯一标识
 @param frame {坐标, 尺寸}
 @return cell实例
 */
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame;

/**
 补充入口
 @param style cell 类型
 @param reuseIdentifier 唯一标识
 @param size 尺寸
 @return cell 实例
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;

/**
 设置编辑状态
 @param editing 是否开启编辑
 @param animated 是否动态显示
 */
- (void)setEdit:(BOOL)editing animated:(BOOL)animated;

/**
 动态结束编辑状态
 */
- (void)endEditingUsingAnimation;

/**
 通知即将进入编辑状态
 @param animated 是否动态进行
 */
- (void)willBeginEditingWithAnimated:(BOOL)animated;

/**
 通知已经进入编辑状态
 @param animated 是否动态进行
 */
- (void)didBeginEditingWithAnimated:(BOOL)animated;

/**
 通知即将结束编辑状态
 @param animated 是否动态进行
 */
- (void)willEndEditingWithAnimated:(BOOL)animated;

/**
 通知已经结束编辑状态
 @param animated 是否动态进行
 */
- (void)didEndEditingWithAnimated:(BOOL)animated;

@end


@interface UITableView (MNEditing)

/**
 是否有表格处于编辑状态
 */
@property (nonatomic, readonly, getter=isEdit) BOOL edit;

/**
 隐藏所有正在编辑的视图
 @param animated 是否动态展示
 */
- (void)endEditingWithAnimated:(BOOL)animated;

/**
 解除指定cell外的编辑状态
 @param cell 指定cell
 @param animated 是否动态
 */
- (void)endEditingExceptCell:(UITableViewCell *)cell animated:(BOOL)animated;

@end
