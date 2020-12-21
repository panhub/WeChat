//
//  WXLyricViewController.m
//  MNChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXLyricViewController.h"
#import "WXSong.h"
#import "WXMusicLyricCell.h"
#import "WXLyricViewModel.h"

@interface WXLyricViewController ()<MNSegmentSubpageDataSource, UIScrollViewDelegate>
/**是否在加载歌词*/
@property (nonatomic, getter=isLoading) BOOL loading;
/**标记是否可居中显示歌词*/
@property (nonatomic, getter=isDragging) BOOL dragging;
/**当前歌词索引*/
@property (nonatomic) NSInteger highlightedIndex;
/**无歌词时提示*/
@property (nonatomic, strong) UILabel *backgroundLabel;
/**歌词视图模型*/
@property (nonatomic, strong) NSMutableArray <WXLyricViewModel *>*dataArray;
/**歌词视图模型缓存*/
@property (nonatomic, strong) NSMutableArray <WXLyricViewModel *>*cacheArray;
@end

@implementation WXLyricViewController
- (void)initialized {
    [super initialized];
    self.highlightedIndex = NSIntegerMin;
    self.dataArray = @[].mutableCopy;
    self.cacheArray = @[].mutableCopy;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = self.view.backgroundColor = UIColor.clearColor;
    
    self.tableView.autoresizingMask = UIViewAutoresizingNone;
    self.tableView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(self.contentMinY, 0.f, (self.contentView.height_mn - self.contentMaxY), 0.f));
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.height_mn/2.f, 0.f, self.tableView.height_mn/2.f, 0.f);
    
    UILabel *backgroundLabel = [UILabel labelWithFrame:self.tableView.bounds text:nil alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:UIFontRegular(16.f)];
    self.backgroundLabel = backgroundLabel;
    self.tableView.backgroundView = backgroundLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.playTimeInterval = self.playTimeInterval;
}

- (void)loadData {
    self.loading = YES;
    self.highlightedIndex = NSIntegerMin;
    self.backgroundLabel.hidden = NO;
    self.backgroundLabel.text = @"歌词加载中";
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    dispatch_async_default(^{
        [self.song.lyrics enumerateObjectsUsingBlock:^(WXLyric * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.dataArray addObject:[self viewModelForLyric:obj]];
        }];
        [self.cacheArray addObjectsFromArray:self.dataArray.copy];
        dispatch_async_main(^{
            self.backgroundLabel.text = @"暂无歌词信息";
            self.backgroundLabel.hidden = self.dataArray.count > 0;
            [self.tableView reloadData];
            self.loading = NO;
        });
    });
}

#pragma mark - Setter
- (void)setSong:(WXSong *)song {
    if (song == _song) return;
    _song = song;
    if (self.backgroundLabel) [self reloadData];
}

- (void)setPlayTimeInterval:(NSTimeInterval)playTimeInterval {
    _playTimeInterval = playTimeInterval;
    if (!self.isAppear || self.isLoading || self.dataArray.count <= 0) return;
    __block NSInteger index = NSIntegerMin;
    [self.dataArray enumerateObjectsUsingBlock:^(WXLyricViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.lyric.begin <= playTimeInterval && obj.lyric.end >= playTimeInterval) {
            //[obj updateContent];
            //[obj updateProgressWithPlayTimeInterval:playTimeInterval];
            index = idx;
            *stop = YES;
        }
    }];
    //if (index == self.highlightedIndex) return;
    NSInteger highlightedIndex = self.highlightedIndex;
    self.highlightedIndex = index;
    NSMutableArray <NSIndexPath *>*indexPaths = @[].mutableCopy;
    if (highlightedIndex != NSIntegerMin && highlightedIndex < self.dataArray.count) {
        WXLyricViewModel *viewModel = [self.dataArray objectAtIndex:highlightedIndex];
        //[viewModel updateContent];
        [viewModel updateProgressWithPlayTimeInterval:(highlightedIndex == index ? playTimeInterval : 0.f)];
        [indexPaths addObject:[NSIndexPath indexPathForRow:highlightedIndex inSection:0]];
    }
    if (index != NSIntegerMin && index != highlightedIndex && index < self.dataArray.count) {
        WXLyricViewModel *viewModel = [self.dataArray objectAtIndex:index];
        [viewModel updateProgressWithPlayTimeInterval:playTimeInterval];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    if (indexPaths.count) {
        [self.tableView reloadRowsAtIndexPaths:indexPaths.copy withRowAnimation:UITableViewRowAnimationNone];
        if (index != NSIntegerMin && !self.isDragging) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataArray objectAtIndex:indexPath.row].rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMusicLyricCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.music.lyric.cell"];
    if (!cell) {
        cell = [[WXMusicLyricCell alloc] initWithReuseIdentifier:@"com.wx.music.lyric.cell" size:tableView.rowSize];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXMusicLyricCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) return;
    cell.viewModel = [self.dataArray objectAtIndex:indexPath.row];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDraggingState) object:nil];
    self.dragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performSelector:@selector(updateDraggingState) afterDelay:1.f];
}

- (void)updateDraggingState {
    self.dragging = (self.tableView.isDragging || self.tableView.isDecelerating);
}

#pragma mark - Cache
- (WXLyricViewModel *)viewModelForLyric:(WXLyric *)lyric {
    WXLyricViewModel *viewModel;
    if (self.cacheArray.count) {
        viewModel = self.cacheArray.firstObject;
        [self.cacheArray removeObject:viewModel];
    } else {
        viewModel = WXLyricViewModel.new;
    }
    viewModel.lyric = lyric;
    [viewModel updateContent];
    [viewModel updateProgressWithPlayTimeInterval:0.f];
    return viewModel;
}

#pragma mark - MNSegmentSubpageDataSource
- (UIScrollView *)segmentSubpageScrollView {
    return self.tableView;
}

- (void)segmentSubpageScrollViewDidInsertInset:(CGFloat)inset ofIndex:(NSInteger)pageIndex {
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.height_mn/2.f, 0.f, self.tableView.height_mn/2.f, 0.f);
}

@end
