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
@property (nonatomic, strong) UIImageView *separatorView;
@property (nonatomic, strong) NSArray <NSString *>*dataArray;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) NSUInteger lastSelectedIndex;
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
    _selectRowEnabled = YES;
    _updateShadowEnabled = YES;
}

- (void)createView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width - .3f, self.frame.size.height) style:UITableViewStylePlain];
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
    
    UIImageView *separatorView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tableView.frame), 0.f, .3f, self.frame.size.height)];
    separatorView.image = [UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .3f)];
    separatorView.contentMode = UIViewContentModeScaleAspectFill;
    separatorView.clipsToBounds = YES;
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:separatorView];
    self.separatorView = separatorView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MNLinkTableViewCellIdentifier];
    if (!cell) {
        cell = [[MNLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MNLinkTableViewCellIdentifier size:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.titleFont = _configuration.titleFont;
        cell.titleColor = _configuration.titleColor;
        cell.titleAlignment = _configuration.titleAlignment;
        cell.backgroundColor = _configuration.backgroundColor;
    }
    BOOL selected = indexPath.row == _selectedIndex;
    cell.titleColor = selected ? _configuration.selectedTitleColor : _configuration.titleColor;
    cell.contentView.backgroundColor = selected ? _configuration.selectedBackgroundColor : _configuration.backgroundColor;
    cell.title = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_selectRowEnabled || !_updateShadowEnabled || indexPath.row == _selectedIndex) return;
    if ([_delegate respondsToSelector:@selector(linkTableView:didSelectRowAtIndex:)]) {
        [_delegate linkTableView:self didSelectRowAtIndex:indexPath.row];
    }
    [self updateSelectIndex:indexPath.row animated:YES];
}

#pragma mark - Setter
- (void)setConfiguration:(MNLinkTableConfiguration *)configuration {
    _configuration = configuration;
    _tableView.rowHeight = configuration.rowHeight;
    _tableView.separatorColor = configuration.separatorColor;
    _tableView.separatorInset = configuration.separatorInset;
    _tableView.backgroundColor = configuration.backgroundColor;
    _separatorView.image = [UIImage imageWithColor:configuration.separatorColor];
    CGRect frame = _shadowView.frame;
    frame.size.height = configuration.rowHeight;
    frame.size.width = configuration.shadowWidth;
    _shadowView.frame = frame;
    _shadowView.backgroundColor = configuration.shadowColor;
}

#pragma mark - Getter
- (NSUInteger)numberOfRows {
    return _dataArray.count;
}

#pragma mark - Update Selected Shadow
- (void)updateShadowOffsetOfRatio:(CGFloat)ratio {
    if (_updateShadowEnabled) {
        [self layoutShadowToPosition:ratio];
    }
    NSUInteger toIndex = round(ratio);
    toIndex = MAX(0, toIndex);
    if (toIndex == _selectedIndex || toIndex >= _dataArray.count) return;
    _lastSelectedIndex = _selectedIndex;
    _selectedIndex = toIndex;
    [self reloadSelectRowIfNeed];
    [self scrollRowToPositionAtSelectIndex:YES];
}

- (void)scrollShadowToIndex:(NSUInteger)index {
    _updateShadowEnabled = NO;
    [UIView animateWithDuration:MNLinkTableAnimationDuration animations:^{
        [self layoutShadowToPosition:index];
    } completion:^(BOOL finished) {
        _updateShadowEnabled = YES;
    }];
}

/// 根据偏移量改变选择条位置
- (void)layoutShadowToPosition:(CGFloat)pos {
    CGRect frame = _shadowView.frame;
    frame.origin.y = pos*_tableView.rowHeight;
    _shadowView.frame = frame;
}

/// 更新选择索引
- (void)updateSelectIndex:(NSUInteger)currentIndex animated:(BOOL)animated {
    _lastSelectedIndex = _selectedIndex;
    _selectedIndex = currentIndex;
    [self reloadSelectRowIfNeed];
    [self scrollRowToPositionAtSelectIndex:animated];
    [UIView animateWithDuration:(animated ? MNLinkTableAnimationDuration : 0.f) animations:^{
        [self layoutShadowToPosition:currentIndex];
    }];
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
- (void)updateTitles:(NSArray <NSString *>*)titles {
    _dataArray = titles.copy;
    [_tableView reloadData];
}

- (void)reloadData {
    _selectRowEnabled = YES;
    _updateShadowEnabled = YES;
    _selectedIndex = 0;
    _lastSelectedIndex = 0;
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointZero animated:NO];
}

@end
