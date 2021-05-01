//
//  MNLinkTableView.m
//  MNKit
//
//  Created by Vincent on 2018/12/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLinkTableView.h"
#import "MNLinkTableViewCell.h"
#import "MNLinkTableConfiguration.h"

@interface MNLinkTableView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) NSArray <id>*dataArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger lastSelectedIndex;
@property (nonatomic, assign) BOOL updateShadowEnabled;
@end

#define MNLinkTableAnimationDuration  .3f
#define MNLinkTableViewCellIdentifier    @"com.mn.link.table.view.cell.identifier"

@implementation MNLinkTableView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    _selectedIndex = 0;
    _lastSelectedIndex = 0;
    _selectEnabled = YES;
    _interactiveEnabled = YES;
    _updateShadowEnabled = YES;
}

- (void)createView {
    
    CGFloat w = UIScreen.mainScreen.scale < 3.f ? 1.f : .5f;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - w, 0.f, w, self.frame.size.height)];
    separator.right_mn = self.width_mn;
    separator.contentMode = UIViewContentModeScaleAspectFill;
    separator.clipsToBounds = YES;
    separator.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:separator];
    self.separator = separator;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, separator.frame.origin.x, self.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)];
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)];
    tableView.estimatedRowHeight = 0.f;
    tableView.estimatedSectionHeaderHeight = 0.f;
    tableView.estimatedSectionFooterHeight = 0.f;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        if ([tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    #endif
    [self addSubview:tableView];
    self.tableView = tableView;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 0.f)];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [tableView addSubview:shadowView];
    self.shadowView = shadowView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MNLinkTableViewCellIdentifier];
    if (!cell) {
        cell = [[MNLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MNLinkTableViewCellIdentifier];
        cell.titleFont = _configuration.titleFont;
        cell.titleAlignment = _configuration.titleAlignment;
        cell.titleNumberOfLines = _configuration.titleNumberOfLines;
        cell.titleInset = _configuration.titleInset;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MNLinkTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL selected = indexPath.row == _selectedIndex;
    cell.titleColor = selected ? _configuration.selectedTitleColor : _configuration.titleColor;
    cell.contentView.backgroundColor = selected ? _configuration.cellHighlightedColor : _configuration.cellNormalColor;
    cell.title = _dataArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_selectEnabled || !_interactiveEnabled || !_updateShadowEnabled || indexPath.row == _selectedIndex) return;
    [self updateSelectIndex:indexPath.row animated:YES];
    if ([_delegate respondsToSelector:@selector(linkTableView:didSelectRowAtIndex:)]) {
        [_delegate linkTableView:self didSelectRowAtIndex:indexPath.row];
    }
}

#pragma mark - Setter
- (void)setConfiguration:(MNLinkTableConfiguration *)configuration {
    _configuration = configuration;
    _tableView.rowHeight = configuration.rowHeight;
    _tableView.separatorColor = configuration.separatorColor;
    _tableView.separatorInset = configuration.separatorInset;
    _tableView.backgroundColor = configuration.backgroundColor;
    _separator.backgroundColor = configuration.separatorColor;
    if (configuration.tableHeaderView) _tableView.tableHeaderView = configuration.tableHeaderView;
    if (configuration.tableFooterView) _tableView.tableFooterView = configuration.tableFooterView;
    CGRect frame = _shadowView.frame;
    frame.size.height = configuration.rowHeight;
    frame.size.width = configuration.shadowWidth;
    _shadowView.frame = frame;
    _shadowView.backgroundColor = configuration.shadowColor;
}

#pragma mark - Getter
- (NSInteger)numberOfRows {
    return _dataArray.count;
}

#pragma mark - Update Selected Shadow
- (void)updateShadowOffsetOfRatio:(CGFloat)ratio {
    if (!_updateShadowEnabled) return;
    [self layoutShadowToPosition:ratio];
    NSInteger toIndex = MIN(MAX(0, round(ratio)), _dataArray.count - 1);
    if (toIndex == _selectedIndex) return;
    _lastSelectedIndex = _selectedIndex;
    _selectedIndex = toIndex;
    [self reloadSelectRowIfNeed];
    [self scrollRowToPositionAtSelectIndex:YES];
}

- (void)scrollShadowToIndex:(NSInteger)toIndex {
    _updateShadowEnabled = NO;
    toIndex = MIN(MAX(0, toIndex), _dataArray.count - 1);
    [UIView animateWithDuration:MNLinkTableAnimationDuration animations:^{
        [self layoutShadowToPosition:toIndex];
    } completion:^(BOOL finished) {
        _updateShadowEnabled = YES;
        if (toIndex == _selectedIndex) return;
        _lastSelectedIndex = _selectedIndex;
        _selectedIndex = toIndex;
        [self reloadSelectRowIfNeed];
        [self scrollRowToPositionAtSelectIndex:YES];
    }];
}

/// 根据偏移量改变选择条位置
- (void)layoutShadowToPosition:(CGFloat)pos {
    CGRect frame = _shadowView.frame;
    frame.origin.y = pos*_tableView.rowHeight;
    _shadowView.frame = frame;
}

/// 更新选择索引
- (void)updateSelectIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    _lastSelectedIndex = _selectedIndex;
    _selectedIndex = currentIndex;
    [self reloadSelectRowIfNeed];
    [self scrollRowToPositionAtSelectIndex:animated];
    if (animated) {
        [UIView animateWithDuration:MNLinkTableAnimationDuration animations:^{
            [self layoutShadowToPosition:currentIndex];
        }];
    } else {
        [self layoutShadowToPosition:currentIndex];
    }
}

/// 刷新选择项
- (void)reloadSelectRowIfNeed {
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray arrayWithCapacity:2];
    if (_dataArray.count > _lastSelectedIndex) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:_lastSelectedIndex inSection:0]];
    }
    if (_selectedIndex != _lastSelectedIndex && _dataArray.count > _selectedIndex) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    }
    if (indexPaths.count > 0) {
        [_tableView reloadRowsAtIndexPaths:indexPaths.copy
                          withRowAnimation:UITableViewRowAnimationNone];
    }
}

/// 滑动选择行到中间位置
- (void)scrollRowToPositionAtSelectIndex:(BOOL)animated {
    if (_dataArray.count > _selectedIndex && _configuration.scrollPosition != MNLinkTableScrollPositionNone) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]
                          atScrollPosition:(UITableViewScrollPosition)(_configuration.scrollPosition)
                                  animated:animated];
    }
}

#pragma mark - 数据源
- (void)updateTitles:(NSArray <id>*)titles {
    _dataArray = titles.copy;
    [_tableView reloadData];
}

- (void)reloadData {
    _selectEnabled = YES;
    _interactiveEnabled = YES;
    _updateShadowEnabled = YES;
    _selectedIndex = 0;
    _lastSelectedIndex = 0;
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointZero animated:NO];
}

@end
