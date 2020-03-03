//
//  MNEmojiInputView.m
//  MNKit
//
//  Created by Vincent on 2019/2/3.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiInputView.h"
#import "MNEmojiManager.h"
#import "MNEmojiPreview.h"

@interface MNEmojiInputView ()<UIScrollViewDelegate, MNEmojiViewDelegate>
{
    CGFloat _startOffsetX;
}
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic, strong) MNScrollView *scrollView;
@property (nonatomic, strong) MNEmojiPreview *emojiPreview;
@property (nonatomic, strong) NSMapTable<NSNumber *, MNEmojiView *> *pageCache;
@end

@implementation MNEmojiInputView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        MNScrollView *scrollView = [[MNScrollView alloc] initWithFrame:self.bounds];
        scrollView.delegate = self;
        scrollView.scrollDirection = MNScrollViewDirectionHorizontal;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return self;
}

- (void)reloadData {
    self.currentPageIndex = 0;
    [self.pageCache removeAllObjects];
    [self.scrollView removeAllSubviews];
    [self.scrollView updateContentWithNumberOfPages:self.emojiPackets.count];
    [self updateCurrentPage];
}

#pragma mark - 展示指定页
- (void)displayPageOfIndex:(NSUInteger)pageIndex {
    if (pageIndex >= self.emojiPackets.count) return;
    self.currentPageIndex = pageIndex;
    [self updateCurrentPage];
}

#pragma mark - 展示当前页指定索引
- (void)displayCurrentPageOfIndex:(NSUInteger)pageIndex {
    MNEmojiView *emojiView = [self emojiViewOfIndex:self.currentPageIndex];
    [emojiView updateOffsetWithPageIndex:pageIndex animated:NO];
}

 #pragma mark - 更新当前页
- (void)updateCurrentPage {
    MNEmojiView *emojiView = [self emojiViewOfIndex:self.currentPageIndex];
    [self.scrollView updateOffsetWithPageIndex:self.currentPageIndex animated:NO];
    if (self.configuration.style == MNEmojiKeyboardStyleRegular && [self.delegate respondsToSelector:@selector(emojiInputViewDidDisplayEmojiView:)]) {
        [self.delegate emojiInputViewDidDisplayEmojiView:emojiView];
    }
}

#pragma mark - 重载当前页表情
- (void)reloadEmojis {
    NSArray <MNEmojiPacket *>*emojiPackets = self.emojiPackets;
    if (self.currentPageIndex >= emojiPackets.count) return;
    MNEmojiView *emojiView = [self emojiViewOfIndex:self.currentPageIndex];
    emojiView.packet = emojiPackets[self.currentPageIndex];
    if (self.configuration.style == MNEmojiKeyboardStyleRegular && [self.delegate respondsToSelector:@selector(emojiInputViewDidDisplayEmojiView:)]) {
        [self.delegate emojiInputViewDidDisplayEmojiView:emojiView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!scrollView.isDragging) return;
    _startOffsetX = [[scrollView valueForKeyPath:@"_startOffsetX"] floatValue];
}

- (void)scrollViewDidScroll:(MNScrollView *)scrollView {
    if (!scrollView.isDragging) return;
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat ratio = currentOffsetX/scrollView.frame.size.width;
    NSUInteger pageIndex = currentOffsetX > _startOffsetX ? ceil(ratio) : floor(ratio);
    if (pageIndex != self.currentPageIndex) [self emojiViewOfIndex:pageIndex];
    pageIndex = round(ratio);
    if (pageIndex == self.currentPageIndex) return;
    self.currentPageIndex = pageIndex;
    MNEmojiView *emojiView = [self emojiViewOfIndex:pageIndex];
    if ([self.delegate respondsToSelector:@selector(emojiInputViewDidDisplayEmojiView:)]) {
        [self.delegate emojiInputViewDidDisplayEmojiView:emojiView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(MNScrollView *)scrollView {
    [self displayPageOfIndex:scrollView.currentPageIndex];
}

#pragma mark - MNEmojiViewDelegate
- (void)emojiViewDeleteButtonTouchUpInside:(MNEmojiView *)emojiView {
    if ([self.delegate respondsToSelector:@selector(emojiDeleteButtonTouchUpInside)]) {
        [self.delegate emojiDeleteButtonTouchUpInside];
    }
}

- (void)emojiViewEmojiButtonTouchUpInside:(MNEmoji *)emoji {
    if ([self.delegate respondsToSelector:@selector(emojiInputViewEmojiButtonTouchUpInside:)]) {
        [self.delegate emojiInputViewEmojiButtonTouchUpInside:emoji];
    }
}

- (void)emojiViewDidScrollToPageOfIndex:(NSUInteger)pageIndex {
    if ([self.delegate respondsToSelector:@selector(emojiInputViewDidScrollToPageOfIndex:)]) {
        [self.delegate emojiInputViewDidScrollToPageOfIndex:pageIndex];
    }
}

- (void)emojiViewReturnButtonTouchUpInside:(MNEmojiView *)emojiView {
    if ([self.delegate respondsToSelector:@selector(emojiReturnButtonTouchUpInside)]) {
        [self.delegate emojiReturnButtonTouchUpInside];
    }
}

- (void)emojiViewShouldPreviewEmoji:(MNEmoji *)emoji atRect:(CGRect)frame {
    if (emoji && !CGRectIsEmpty(frame)) {
        self.emojiPreview.bottom_mn = CGRectGetMaxY(frame);
        self.emojiPreview.centerX_mn = CGRectGetMidX(frame);
        self.emojiPreview.emoji = emoji;
        self.emojiPreview.hidden = NO;
    } else {
        _emojiPreview.hidden = YES;
    }
}

#pragma mark - Getter
- (NSArray <MNEmojiPacket *>*)emojiPackets {
    if ([self.dataSource respondsToSelector:@selector(emojiPacketsOfInputView)]) {
        return [self.dataSource emojiPacketsOfInputView];
    }
    return @[];
}

- (NSMapTable<NSNumber *, MNEmojiView *> *)pageCache {
    if (!_pageCache) {
        _pageCache = [NSMapTable weakToWeakObjectsMapTable];
    }
    return _pageCache;
}

- (MNEmojiPreview *)emojiPreview {
    if (!_emojiPreview) {
        MNEmojiPreview *emojiPreview = [[MNEmojiPreview alloc] init];
        emojiPreview.hidden = YES;
        [self addSubview:_emojiPreview = emojiPreview];
    }
    return _emojiPreview;
}

#pragma mark - Page Of Index
- (MNEmojiView *)emojiViewOfIndex:(NSUInteger)index {
    MNEmojiView *emojiView = [self.pageCache objectForKey:@(index)];
    if (!emojiView) {
        emojiView = [[MNEmojiView alloc] initWithFrame:self.scrollView.bounds];
        emojiView.index = index;
        emojiView.emojiDelegate = self;
        emojiView.configuration = self.configuration;
        NSArray <MNEmojiPacket *>*emojiPackets = self.emojiPackets;
        if (self.currentPageIndex < emojiPackets.count) {
            emojiView.packet = emojiPackets[index];
        }
        [self addEmojiView:emojiView];
    }
    return emojiView;
}

- (void)addEmojiView:(MNEmojiView *)emojiView {
    CGFloat x = [self.scrollView contentOffsetOfPageIndex:emojiView.index].x;
    emojiView.frame = (CGRect){x, 0.f, emojiView.frame.size};
    [self.scrollView addSubview:emojiView];
    [self.pageCache setObject:emojiView forKey:@(emojiView.index)];
}

@end
