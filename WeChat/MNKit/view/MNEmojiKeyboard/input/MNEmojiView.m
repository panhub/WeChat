//
//  MNEmojiView.m
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiView.h"
#import "MNEmojiCell.h"
#import "MNEmojiPacket.h"
#import "MNEmojiButton.h"
#import "MNEmojiDeleteButton.h"
#import "MNEmojiElementView.h"
#import "MNEmojiKeyboardConfiguration.h"

@interface MNEmojiView ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    CGRect MNEmojiViewVisibleBounds;
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MNEmojiElementView *elementView;
@property (nonatomic, strong) MNCollectionVerticalLayout *collectionViewLayout;
@end

@implementation MNEmojiView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        // 表情展示旧版样式
        self.scrollDirection = MNScrollViewDirectionHorizontal;
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = UIColor.clearColor;
        [self addSubview:contentView];
        self.contentView = contentView;
        // 表情展示新版样式
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            if ([collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        [collectionView registerClass:MNEmojiCell.class forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
        [self addSubview:_collectionView = collectionView];
        // 删除/Return键
        MNEmojiElementView *elementView = [[MNEmojiElementView alloc] init];
        [elementView addTarget:self action:@selector(elementButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_elementView = elementView];
        // 长按事件
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handLongPress:)];
        recognizer.minimumPressDuration = .5f;
        [self addGestureRecognizer:recognizer];
        // 隐藏子视图
        [self.subviews setValue:@YES forKey:@"hidden"];
    }
    return self;
}

/// 更新Return键
- (void)updateElementView {
    if (!self.packet || self.packet.type == MNEmojiPacketTypeImage) {
        self.elementView.hidden = YES;
    } else {
        CGFloat inset = self.insetOfEmojisInPage;
        NSUInteger columns = self.numberOfColumnsInPage;
        CGFloat wh = (self.width_mn - (columns + 1)*inset)/columns;
        self.elementView.size_mn = CGSizeMake(wh*2.5f + inset*2.5f, wh + inset/2.f);
        self.elementView.right_mn = self.width_mn - inset/2.f;
        self.elementView.bottom_mn = self.height_mn - MAX(UITabSafeHeight(), inset/2.f);
        self.elementView.hidden = NO;
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.packet.emojis.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull MNEmojiCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MNEmoji *emoji = self.packet.emojis[indexPath.row];
    cell.emoji = emoji;
    if (emoji.type == MNEmojiTypeImage) {
        cell.alpha = 1.f;
    } else {
        CGRect frame = [cell.superview convertRect:cell.frame toView:self];
        cell.alpha = CGRectIntersectsRect(frame, self.elementView.frame) ? 0.f : 1.f;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.packet.emojis.count) return;
    if ([self.emojiDelegate respondsToSelector:@selector(emojiViewEmojiButtonTouchUpInside:)]) {
        [self.emojiDelegate emojiViewEmojiButtonTouchUpInside:self.packet.emojis[indexPath.item]];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:UICollectionView.class] || self.packet.type == MNEmojiPacketTypeImage) return;
    NSArray <UICollectionViewCell *>*visibleCells = self.collectionView.visibleCells;
    [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = [obj.superview convertRect:obj.frame toView:self];
        if (CGRectIntersectsRect(frame, self.elementView.frame)) {
            if (obj.alpha != 0.f) {
                [UIView animateWithDuration:.15f animations:^{
                    obj.alpha = 0.f;
                }];
            }
        } else {
            if (obj.alpha != 1.f) {
                [UIView animateWithDuration:.15f animations:^{
                    obj.alpha = 1.f;
                }];
            }
        }
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:MNScrollView.class] && [self.emojiDelegate respondsToSelector:@selector(emojiViewDidScrollToPageOfIndex:)]) {
        [self.emojiDelegate emojiViewDidScrollToPageOfIndex:((MNScrollView *)scrollView).currentPageIndex];
    }
}

#pragma mark - Setter
- (void)setPacket:(MNEmojiPacket *)packet {
    _packet = packet;
    if (self.configuration.style == MNEmojiKeyboardStyleLight) {
        self.contentView.hidden = YES;
        self.collectionView.hidden = NO;
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self updateElementView];
        CGFloat inset = self.insetOfEmojisInPage;
        MNCollectionVerticalLayout *layout = self.collectionViewLayout;
        layout.numberOfFormation = self.numberOfColumnsInPage;
        layout.minimumLineSpacing = inset;
        layout.minimumInteritemSpacing = inset;
        if (packet.type == MNEmojiPacketTypeImage) {
            layout.sectionInset = UIEdgeInsetsMake(inset, inset, MAX(UITabSafeHeight(), inset), inset);
        } else {
            layout.sectionInset = UIEdgeInsetsMake(inset, inset, (self.height_mn - self.elementView.top_mn + inset/2.f), inset);
        }
        [self.collectionView reloadData];
    } else {
        self.collectionView.hidden = self.elementView.hidden = YES;
        self.contentView.hidden = NO;
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if (packet.type == MNEmojiPacketTypeText) {
            NSInteger currentPageIndex = self.currentPageIndex;
            self.pagingEnabled = YES;
            self.scrollDirection = MNScrollViewDirectionHorizontal;
            NSUInteger rows = self.numberOfRowsInPage;
            NSUInteger columns = self.numberOfColumnsInPage;
            NSUInteger count = self.numberOfEmojisInPage;
            CGSize itemSize = CGSizeMake(30.f, 30.f);
            CGFloat xm = (self.width_mn - itemSize.width*columns)/(columns + 1);
            CGFloat ym = (self.height_mn - itemSize.height*rows - self.configuration.pageIndicatorHeight)/(rows + 1);
            CGFloat x = xm;
            CGFloat y = ym;
            MNEmojiViewVisibleBounds = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(y, x, y, x));
            NSArray <NSArray <MNEmoji *>*>*array = [packet.emojis componentArrayByCapacity:count];
            [array enumerateObjectsUsingBlock:^(NSArray <MNEmoji *>*emojis, NSUInteger idx, BOOL * _Nonnull stop) {
                [UIView gridLayoutWithInitial:CGRectMake(x + self.width_mn*idx, y, itemSize.width, itemSize.height) offset:UIOffsetMake(xm, ym) count:(count + 1) rows:columns handler:^(CGRect rect, NSUInteger i, BOOL *st) {
                    UIEdgeInsets touchInset = UIEdgeInsetsMake(-ym/2.f, -xm/2.f, -ym/2.f, -xm/2.f);
                    if (i < emojis.count) {
                        /// 表情按钮
                        MNEmojiButton *button = [[MNEmojiButton alloc] initWithFrame:rect];
                        button.emoji = emojis[i];
                        button.exclusiveTouch = YES;
                        button.touchInset = touchInset;
                        button.contentMode = UIViewContentModeScaleAspectFit;
                        [button addTarget:self action:@selector(emojiButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                        [self.contentView addSubview:button];
                    } else if (i == count) {
                        // 删除按钮
                        MNEmojiButton *button = [[MNEmojiButton alloc] initWithFrame:rect];
                        button.exclusiveTouch = YES;
                        button.touchInset = touchInset;
                        button.image = [MNBundle imageForResource:@"emoticon_delete"];
                        button.contentMode = UIViewContentModeScaleAspectFit;
                        [button addTarget:self action:@selector(deleteButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                        [self.contentView addSubview:button];
                    }
                }];
            }];
            [self updateContentWithNumberOfPages:array.count];
            [self updateOffsetWithPageIndex:(currentPageIndex >= array.count ? 0 : currentPageIndex) animated:NO];
        } else {
            CGPoint contentOffset = self.contentOffset;
            self.pagingEnabled = NO;
            self.scrollDirection = MNScrollViewDirectionVertical;
            CGFloat inset = self.insetOfEmojisInPage;
            NSUInteger columns = self.numberOfColumnsInPage;
            CGFloat itemWidth = (self.width_mn - (columns + 1)*inset)/columns;
            __block CGSize contentSize = self.bounds.size;
            [UIView gridLayoutWithInitial:CGRectMake(inset, inset, itemWidth, itemWidth) offset:UIOffsetMake(inset, inset) count:packet.emojis.count rows:columns handler:^(CGRect rect, NSUInteger idx, BOOL *stop) {
                MNEmojiButton *button = [[MNEmojiButton alloc] initWithFrame:rect];
                button.emoji = packet.emojis[idx];
                button.exclusiveTouch = YES;
                [button addTarget:self action:@selector(emojiButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:button];
                contentSize.height = MAX(button.bottom_mn + inset, contentSize.height);
            }];
            [self updateContentWithNumberOfPages:0];
            self.contentSize = contentSize;
            if (contentOffset.y <= (contentSize.height - self.height_mn)) {
                [self setContentOffset:CGPointMake(0.f, contentOffset.y) animated:NO];
            } else {
                [self setContentOffset:CGPointZero animated:NO];
            }
        }
        self.contentView.size_mn = self.contentSize;
    }
}

- (void)setConfiguration:(MNEmojiKeyboardConfiguration *)configuration {
    _configuration = configuration;
    self.elementView.configuration = configuration;
}

#pragma mark - Button Event
- (void)emojiButtonTouchUpInside:(MNEmojiButton *)button {
    if ([self.emojiDelegate respondsToSelector:@selector(emojiViewEmojiButtonTouchUpInside:)]) {
        [self.emojiDelegate emojiViewEmojiButtonTouchUpInside:button.emoji];
    }
}

- (void)deleteButtonTouchUpInside:(UIButton *)button {
    if ([self.emojiDelegate respondsToSelector:@selector(emojiViewDeleteButtonTouchUpInside:)]) {
        [self.emojiDelegate emojiViewDeleteButtonTouchUpInside:self];
    }
}

- (void)elementButtonTouchUpInside:(UIButton *)button {
    if (button.tag == 0) {
        if ([self.emojiDelegate respondsToSelector:@selector(emojiViewDeleteButtonTouchUpInside:)]) {
            [self.emojiDelegate emojiViewDeleteButtonTouchUpInside:self];
        }
    } else {
        if ([self.emojiDelegate respondsToSelector:@selector(emojiViewReturnButtonTouchUpInside:)]) {
            [self.emojiDelegate emojiViewReturnButtonTouchUpInside:self];
        }
    }
}

- (void)handLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (self.packet.type == MNEmojiPacketTypeImage) return;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self updateEmojiPressLocation:[recognizer locationInView:self]];
        } break;
        case UIGestureRecognizerStateChanged:
        {
            [self updateEmojiPressLocation:[recognizer locationInView:self]];
        } break;
        default:
        {
            [self updateEmojiPressLocation:CGPointZero];
        } break;
    }
}

- (void)updateEmojiPressLocation:(CGPoint)point {
    MNEmoji *emoji;
    CGRect emojiFrame = CGRectZero;
    CGFloat offsetX = self.width_mn*self.currentPageIndex;
    if (self.configuration.style == MNEmojiKeyboardStyleRegular) {
        CGRect frame = MNEmojiViewVisibleBounds;
        frame.origin.x += offsetX;
        if (CGRectContainsPoint(frame, point)) {
            for (MNEmojiButton *button in self.contentView.subviews) {
                if (!CGRectIntersectsRect(frame, button.frame)) continue;
                if (CGRectContainsPoint(UIEdgeInsetsInsetRect(button.frame, button.touchInset), point)) {
                    emoji = button.emoji;
                    emojiFrame = button.frame;
                    emojiFrame.origin.x -= offsetX;
                    break;
                }
            }
        }
    } else {
        for (MNEmojiCell *cell in self.collectionView.visibleCells) {
            if (cell.alpha == 0.f) continue;
            CGRect frame = [cell.superview convertRect:cell.frame toView:self];
            if (CGRectContainsPoint(frame, point)) {
                emoji = cell.emoji;
                emojiFrame = frame;
            }
        }
    }
    if ([self.emojiDelegate respondsToSelector:@selector(emojiViewShouldPreviewEmoji:atRect:)]) {
        [self.emojiDelegate emojiViewShouldPreviewEmoji:emoji atRect:emojiFrame];
    }
}

#pragma mark - Getter
- (NSUInteger)numberOfColumnsInPage {
    if (self.packet.type == MNEmojiPacketTypeImage) return 5;
    return self.width_mn >= 414.f ? 8 : 7;
}

- (NSUInteger)numberOfRowsInPage {
    return 3;
}

- (NSUInteger)numberOfEmojisInPage {
    return self.numberOfRowsInPage*self.numberOfColumnsInPage - 1;
}

- (CGFloat)insetOfEmojisInPage {
    if (!self.packet) return 0.f;
    return self.packet.type == MNEmojiPacketTypeImage ? 13.f : (self.width_mn >= 414.f ? 18.f : 16.5f);
}

- (MNCollectionVerticalLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
        layout.numberOfFormation = 5;
        layout.minimumLineSpacing = 10.f;
        layout.minimumInteritemSpacing = 10.f;
        layout.itemSize = CGSizeMake(1.f, 1.f);
        _collectionViewLayout = layout;
    }
    return _collectionViewLayout;
}

@end
