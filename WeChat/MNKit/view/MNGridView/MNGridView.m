//
//  MNGridView.m
//  MNKit
//
//  Created by Vincent on 2018/11/9.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNGridView.h"

@interface UIView ()

@property (nonatomic) NSInteger mn_item;

@end

@interface MNGridView ()
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSMutableArray <UIView *>*cache;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIView *>*footerViews;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIView *>*headerViews;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSArray <UIView *>*>*cellCache;
@end

@implementation MNGridView
@dynamic delegate;

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self initialized];
    return self;
}

- (void)initialized {
    _sectionInset = UIEdgeInsetsZero;
    _minimumLineSpacing = 10.f;
    _minimumInterItemSpacing = 10.f;
    _contentAlignment = MNGridAlignmentLeft;
}

- (void)reloadData {
    [self removeAllViews];
    UIEdgeInsets contentInset = self.contentInset;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat width = self.width_mn - contentInset.left - contentInset.right;
    if (width <= 0.f) return;
    self.loading = YES;
    NSInteger number = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInGridView:)]) {
        number = [self.dataSource numberOfSectionsInGridView:self];
    }
    CGFloat minimumLineSpacing = self.minimumLineSpacing;
    CGFloat minimumInterItemSpacing = self.minimumInterItemSpacing;
    NSMutableArray <UIView *>*items = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger section = 0; section < number; section ++) {
        /// 区inset
        UIEdgeInsets inset = [self contentInsetForSection:section];
        x = inset.left;
        y += inset.top;
        width = self.width_mn - contentInset.left - contentInset.right - inset.left - inset.right;
        /// 头视图
        UIView *header;
        if ([self.dataSource respondsToSelector:@selector(gridView:viewForHeaderInSection:)]) {
            header = [self.dataSource gridView:self viewForHeaderInSection:section];
        }
        if (header) {
            header.left_mn = x;
            header.top_mn = y;
            [self addSubview:header];
            y = header.bottom_mn;
            [self.headerViews setObject:header forKey:@(section)];
        }
        /// cell
        CGFloat left = 0.f;
        CGFloat bottom = y;
        NSInteger count = 0;
        if ([self.dataSource respondsToSelector:@selector(gridView:numberOfItemsInSection:)]) {
            count = [self.dataSource gridView:self numberOfItemsInSection:section];
        }
        NSMutableArray <UIView *>*cells = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger item = 0; item < count; item ++) {
            UIView *cell;
            if ([self.dataSource respondsToSelector:@selector(gridView:cellForItemAtIndexPath:)]) {
                cell = [self.dataSource gridView:self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            }
            if (!cell) continue;
            if (cell.width_mn > width) cell.width_mn = width;
            if (left + cell.width_mn > width) {
                /// 处理该行cell
                [self layoutItems:items offset:UIOffsetMake(width - left + minimumInterItemSpacing, bottom - y - minimumLineSpacing)];
                left = 0.f;
                y = bottom;
            }
            //cell.mn_item = item;
            cell.left_mn = x + left;
            cell.top_mn = y;
            left += (cell.width_mn + minimumInterItemSpacing);
            bottom = MAX(bottom, (cell.bottom_mn + minimumLineSpacing));
            [cells addObject:cell];
            [items addObject:cell];
            [self addSubview:cell];
        }
        [self.cellCache setObject:cells.copy forKey:@(section)];
        [self layoutItems:items offset:UIOffsetMake(width - left + minimumInterItemSpacing, bottom - y - minimumLineSpacing)];
        CGFloat interval = count > 0 ? minimumLineSpacing : 0.f;
        y = bottom - interval;
        /// 尾视图
        UIView *footer;
        if ([self.dataSource respondsToSelector:@selector(gridView:viewForFooterInSection:)]) {
            footer = [self.dataSource gridView:self viewForFooterInSection:section];
        }
        if (footer) {
            footer.left_mn = x;
            footer.top_mn = y;
            [self addSubview:footer];
            y = footer.bottom_mn;
            [self.footerViews setObject:footer forKey:@(section)];
        }
        /// 区inset
        y += inset.bottom;
    }
    width = self.width_mn - contentInset.left - contentInset.right;
    self.contentSize = CGSizeMake(width, y);
    self.loading = NO;
}

- (UIView *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray <UIView *>*cells = [self.cellCache objectForKey:@(indexPath.section)];
    __block UIView *cell;
    [cells enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mn_item == indexPath.item) {
            cell = obj;
            *stop = YES;
        }
    }];
    return cell;
}

- (UIView *)headerViewForSection:(NSInteger)section {
    return [self.headerViews objectForKey:@(section)];
}

- (UIView *)footerViewForSection:(NSInteger)section {
    return [self.footerViews objectForKey:@(section)];
}

#pragma mark - 删除视图
- (void)removeAllViews {
    [self.headerViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.footerViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.cellCache.allValues enumerateObjectsUsingBlock:^(NSArray<UIView *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
    [self.cellCache removeAllObjects];
    [self.footerViews removeAllObjects];
    [self.headerViews removeAllObjects];
}

#pragma mark - 检查自适应
- (void)layoutItems:(NSMutableArray <UIView *>*)items offset:(UIOffset)offset {
    if (items.count <= 0) return;
    MNGridAlignment alignment = self.contentAlignment;
    if (alignment == MNGridAlignmentCenter) {
        [items enumerateObjectsUsingBlock:^(UIView * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = item.frame;
            frame.origin.x += offset.horizontal/2.f;
            if (frame.size.height != offset.vertical) {
                frame.origin.y += (offset.vertical - frame.size.height)/2.f;
            }
            item.frame = frame;
        }];
    } else if (alignment == MNGridAlignmentRight) {
        [items enumerateObjectsUsingBlock:^(UIView * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = item.frame;
            frame.origin.x += offset.horizontal;
            item.frame = frame;
        }];
    }
    [items removeAllObjects];
}

#pragma mark - Super
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isLoading || self.width_mn <= 0.f || (self.headerViews.count + self.footerViews.count + self.cellCache.count) > 0) return;
    [self reloadData];
}

- (void)sizeToFit {
    UIEdgeInsets contentInset = self.contentInset;
    CGSize contentSize = self.contentSize;
    contentSize.width += (contentInset.left + contentInset.right);
    contentSize.height += (contentInset.top + contentInset.bottom);
    self.size_mn = contentSize;
}

#pragma mark - Getter
- (NSMutableDictionary <NSNumber *, UIView *>*)headerViews {
    if (!_headerViews) {
        _headerViews = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _headerViews;
}

- (NSMutableDictionary <NSNumber *, UIView *>*)footerViews {
    if (!_footerViews) {
        _footerViews = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _footerViews;
}

- (NSMutableDictionary <NSNumber *, NSArray <UIView *>*>*)cellCache {
    if (!_cellCache) {
        _cellCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _cellCache;
}

- (UIEdgeInsets)contentInsetForSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(gridView:contentInsetForSection:)]) {
        return [self.dataSource gridView:self contentInsetForSection:section];
    }
    return _sectionInset;
}

@end
