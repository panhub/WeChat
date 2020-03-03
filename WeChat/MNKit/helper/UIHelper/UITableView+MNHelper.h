//
//  UITableView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/17.
//  Copyright © 2017年 小斯. All rights reserved.
//  UITableView

#import <UIKit/UIKit.h>

@interface UITableView (MNHelper)

/**
 表格大小
 */
@property (nonatomic, readonly) CGSize rowSize;

/**
 快速实例化
 @param frame 位置
 @param style 表类型
 @return 表实例
 */
+ (instancetype)tableWithFrame:(CGRect)frame style:(UITableViewStyle)style;

/**
 分割线 充满表格
 */
- (void)relieveSeparatorView;

/**
 清除预算高度
 */
- (void)relieveEstimatedHeight NS_AVAILABLE_IOS(7_0);

/**
 更新表
 @param block 回调
 */
- (void)reloadDataWithBlock:(void (^)(UITableView *tableView))block;

/**
 刷新行
 @param row 行索引
 @param section 区索引
 @param animation 动画类型
 */
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 刷新行
 @param indexPath 行索引
 @param animation 动画类型
 */
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 滚动到指定行
 @param row 行索引
 @param section 区索引
 @param scrollPosition 位置状态
 @param animated 动画类型
 */
- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

/**
 插入表格
 @param indexPath 索引
 @param animation 动画类型
 */
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 插入表格
 @param row 行索引
 @param section 区索引
 @param animation 动画类型
 */
- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除单元格
 @param indexPath 索引
 @param animation 动画类型
 */
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除单元格
 @param row 行索引
 @param section 区索引
 @param animation 动画类型
 */
- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 插入区
 @param section 区索引
 @param animation 动画类型
 */
- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 删除区
 @param section 区索引
 @param animation 动画类型
 */
- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 刷新区
 @param section 区索引
 @param animation 动画类型
 */
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

/**
 取消所有反选
 @param animated 是否动画
 */
- (void)deselectRowsWithAnimated:(BOOL)animated;

@end
