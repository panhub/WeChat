//
//  MNAlbumView.m
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAlbumView.h"
#import "MNAlbumCell.h"

@interface MNAlbumView ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MNAlbumView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.hidden = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, 0.f)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UITableView *tableView = [UITableView tableWithFrame:contentView.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 63.f;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        tableView.separatorColor = UIColorWithSingleRGB(240.f);
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorInset = UIEdgeInsetsMake(0.f, tableView.width_mn/6.f, 0.f, tableView.width_mn/6.f);
        [contentView addSubview:tableView];
        self.tableView = tableView;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.width_mn, 10.f)];
        tableView.tableFooterView = footerView;
        
        [self addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap), self)];
    }
    return self;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.mn.image.album.cell"];
    if (!cell) {
        cell = [[MNAlbumCell alloc] initWithReuseIdentifier:@"com.mn.image.album.cell" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataArray.count && [self.delegate respondsToSelector:@selector(albumView:didSelectAlbum:)]) {
        [self.delegate albumView:self didSelectAlbum:self.dataArray[indexPath.row]];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self;
}

#pragma mark - Setter
- (void)setDataArray:(NSArray<MNAssetCollection *> *)dataArray {
    _dataArray = dataArray;
    /// 计算高度
    CGFloat h = self.tableView.rowHeight;
    CGFloat h2 = self.tableView.tableFooterView.height_mn;
    NSInteger count = MIN(MAX(1, dataArray.count), 7);
    CGFloat height = h*count + h2;
    if (height > self.height_mn/4.f*3.f) {
        count = (self.height_mn/4.f*3.f - h2)/h;
        height = h*count + h2;
    }
    self.contentView.height_mn = height;
    self.contentView.bottom_mn = 0.f;
    [self.tableView reloadData];
}

#pragma mark - Show & Dismiss
- (void)show {
    if (!self.hidden) return;
    self.hidden = NO;
    [self.tableView reloadData];
    [UIView animateWithDuration:.3f animations:^{
        self.contentView.top_mn = 0.f;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    }];
}

- (void)dismiss {
    if (self.hidden) return;
    [UIView animateWithDuration:.3f animations:^{
        self.contentView.bottom_mn = 0.f;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - ReloadData
- (void)reloadData {
    [self.tableView reloadData];
}

- (void)handTap {
    if ([self.delegate respondsToSelector:@selector(albumView:didSelectAlbum:)]) {
        [self.delegate albumView:self didSelectAlbum:nil];
    }
}

@end
