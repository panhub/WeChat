//
//  UITableView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/11/17.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UITableView+MNHelper.h"
#import "UIScrollView+MNHelper.h"
#import "MNConfiguration.h"

@implementation UITableView (MNHelper)
+ (UITableView *)tableWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    UITableView *tableView = [[self alloc] initWithFrame:frame style:style];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)];
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)];
    [tableView relieveEstimatedHeight];
    [tableView relieveSeparatorView];
    [tableView adjustContentInset];
    return tableView;
}

#pragma mark - 分割线 充满表格
- (void)relieveSeparatorView {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - 表格大小
- (CGSize)rowSize {
    return CGSizeMake(self.frame.size.width, self.rowHeight);
}

#pragma mark - 清除预算高度
- (void)relieveEstimatedHeight NS_AVAILABLE_IOS(7_0) {
    self.estimatedRowHeight = 0.f;
    self.estimatedSectionHeaderHeight = 0.f;
    self.estimatedSectionFooterHeight = 0.f;
}

#pragma mark - 更新
- (void)reloadDataWithBlock:(void (^)(UITableView *))block {
    [self beginUpdates];
    if (block) block(self);
    [self endUpdates];
}

#pragma mark - 刷新表格
- (void)reloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self reloadRowAtIndexPath:indexPath withRowAnimation:animation];
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (!indexPath) return;
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

#pragma mark - 滚动到指定行
- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

#pragma mark - 插入表格
- (void)insertRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (!indexPath) return;
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)insertRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self insertRowAtIndexPath:indexPath withRowAnimation:animation];
}

#pragma mark - 删除表格
- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    if (!indexPath) return;
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)deleteRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self deleteRowAtIndexPath:indexPath withRowAnimation:animation];
}

#pragma mark - 插入区
- (void)insertSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self insertSections:sections withRowAnimation:animation];
}

#pragma mark - 删除区
- (void)deleteSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:section];
    [self deleteSections:sections withRowAnimation:animation];
}

#pragma mark - 刷新区
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:indexSet withRowAnimation:animation];
}

#pragma mark - 取消反选
- (void)deselectRowsWithAnimated:(BOOL)animated {
    NSArray *indexs = [self indexPathsForSelectedRows];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath* path, NSUInteger idx, BOOL *stop) {
        [self deselectRowAtIndexPath:path animated:animated];
    }];
}

@end
