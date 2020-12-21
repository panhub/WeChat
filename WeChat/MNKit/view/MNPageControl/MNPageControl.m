//
//  MNPageControl.m
//  MNKit
//
//  Created by Vincent on 2019/2/10.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNPageControl.h"

@interface MNPageControl ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, copy) MNPageControlValueChangedHandler selectedHandler;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIView *>*pageCache;
@end

@implementation MNPageControl
+ (instancetype)pageControlWithFrame:(CGRect)frame handler:(MNPageControlValueChangedHandler)handler {
    MNPageControl *pageControl = [[MNPageControl alloc] initWithFrame:frame];
    pageControl.selectedHandler = handler;
    return pageControl;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    _pageInterval = 9.f;
    _numberOfPages = 1;
    _currentPageIndex = 0;
    _pageSize = CGSizeMake(7.f, 7.f);
    _pageTouchInset = UIEdgeInsetsZero;
    _direction = MNPageControlDirectionHorizontal;
    _pageCache = [NSMutableDictionary dictionaryWithCapacity:1];
    _pageIndicatorTintColor = [[UIColor grayColor] colorWithAlphaComponent:.37f];
    _currentPageIndicatorTintColor = [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f];
}

- (void)createView {
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.clipsToBounds = YES;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (void)layoutSubviews {
    /// 先计算位置
    if (CGSizeEqualToSize(self.contentView.frame.size, CGSizeZero)) return;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    NSUInteger numberOfPages = [self numberOfPagesInColumn];
    _numberOfPages = numberOfPages;
    if (self.direction == MNPageControlDirectionHorizontal) {
        x = (self.contentView.frame.size.width - numberOfPages*self.pageSize.width - (numberOfPages - 1)*self.pageInterval)/2.f;
        y = (self.contentView.frame.size.height - self.pageSize.height)/2.f;
    } else {
        x = (self.contentView.frame.size.width - self.pageSize.width)/2.f;
        y = (self.contentView.frame.size.height - numberOfPages*self.pageSize.height - (numberOfPages - 1)*self.pageInterval)/2.f;
    }
    x += self.pageOffset.horizontal;
    x = MAX(0.f, x);
    y += self.pageOffset.vertical;
    y = MAX(0.f, y);
    /// 删除多余子视图
    NSArray <UIView *> *subviews = self.contentView.subviews.copy;
    [subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.tag >= numberOfPages) {
            [view removeFromSuperview];
        }
    }];
    /// 添加新视图
    for (NSUInteger idx = 0; idx < numberOfPages; idx++) {
        UIView *page = [self cellForPageOfIndex:idx];
        page.tag = idx;
        if (self.direction == MNPageControlDirectionHorizontal) {
            page.frame = CGRectMake(x + (self.pageInterval + self.pageSize.width)*idx, y, self.pageSize.width, self.pageSize.height);
        } else {
            page.frame = CGRectMake(x, y + (self.pageInterval + self.pageSize.height)*idx, self.pageSize.width, self.pageSize.height);
        }
        page.layer.cornerRadius = self.pageSize.width/2.f;
        page.clipsToBounds = YES;
        if (idx == self.currentPageIndex) {
            page.backgroundColor = self.currentPageIndicatorTintColor;
        } else {
            page.backgroundColor = self.pageIndicatorTintColor;
        }
        if (!page.superview) [self.contentView addSubview:page];
        if ([_delegate respondsToSelector:@selector(pageControl:didEndLayoutCell:forPageOfIndex:)]) {
            [_delegate pageControl:self didEndLayoutCell:page forPageOfIndex:idx];
        }
    }
}

#pragma mark - Setter
- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    numberOfPages = MAX(numberOfPages, 1);
    if (numberOfPages == _numberOfPages) return;
    _numberOfPages = numberOfPages;
    if (_currentPageIndex >= numberOfPages) _currentPageIndex = 0;
    [self setNeedsLayout];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex {
    if (currentPageIndex == _currentPageIndex || currentPageIndex >= _numberOfPages) return;
    _currentPageIndex = currentPageIndex;
    [self updateCurrentPageIfNeeded];
}

- (void)setPageOffset:(UIOffset)pageOffset {
    if (UIOffsetEqualToOffset(pageOffset, _pageOffset)) return;
    _pageOffset = pageOffset;
    [self setNeedsLayout];
}

- (void)setPageSize:(CGSize)pageSize {
    if (CGSizeEqualToSize(pageSize, _pageSize) && pageSize.width >= 0.f && pageSize.height >= 0.f) return;
    _pageSize = pageSize;
    [self setNeedsLayout];
}

- (void)setPageInterval:(CGFloat)pageInterval {
    pageInterval = MAX(0.f, pageInterval);
    if (pageInterval == _pageInterval) return;
    _pageInterval = pageInterval;
    [self setNeedsLayout];
}

- (void)setDirection:(MNPageControlDirection)direction {
    if (direction == _direction) return;
    _direction = direction;
    [self setNeedsLayout];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    if (!pageIndicatorTintColor) return;
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self updateCurrentPageIfNeeded];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    if (!currentPageIndicatorTintColor) return;
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self updateCurrentPageIfNeeded];
}

- (void)setTintColor:(UIColor *)tintColor {
    [self setPageIndicatorTintColor:tintColor];
}

#pragma mark - Getter
- (UIView *)cellForPageOfIndex:(NSUInteger)index {
    UIView *page = self.pageCache[@(index)];
    if (!page) {
        if ([_dataSource respondsToSelector:@selector(pageControl:cellForPageOfIndex:)]) {
            page = [_dataSource pageControl:self cellForPageOfIndex:index];
        }
        if (!page) page = [[UIView alloc] init];
        page.userInteractionEnabled = NO;
        [self.pageCache setObject:page forKey:@(index)];
    }
    return page;
}

- (CGRect)cellRectForPageOfIndex:(NSUInteger)pageIndex {
    NSArray <UIView *>* pages = [self.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag == %ld", pageIndex]];
    if (pages.count <= 0) return CGRectZero;
    return pages.firstObject.frame;
}

- (NSUInteger)numberOfPagesInColumn {
    if ([_dataSource respondsToSelector:@selector(numberOfPagesInPageControl:)]) {
        return [_dataSource numberOfPagesInPageControl:self];
    }
    return self.numberOfPages;
}

#pragma mark - 立即更新控件
- (void)updateCurrentPageIfNeeded {
    if (self.contentView.subviews.count <= 0) return;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = obj.tag == self.currentPageIndex ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
    }];
}

#pragma mark - 立即更新控件
- (void)reloadData {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - 交互处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (event.type != UIEventTypeTouches || touches.anyObject.tapCount != 1) return;
    self.selected = YES;
    [self updateCurrentPageWithTouches:touches event:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isSelected) return;
    [self updateCurrentPageWithTouches:touches event:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selected = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.selected = NO;
}

- (void)updateCurrentPageWithTouches:(NSSet<UITouch *> *)touches event:(UIEvent *)event {
    if (event.type != UIEventTypeTouches) return;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.contentView];
    __block UIView *page;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(UIEdgeInsetsInsetRect(obj.frame, self.pageTouchInset), point)) {
            page = obj;
            *stop = YES;
        }
    }];
    if (!page) return;
    if (page.tag == self.currentPageIndex) return;
    self.currentPageIndex = page.tag;
    if (self.selectedHandler) {
        self.selectedHandler(self, self.currentPageIndex);
    }
    if (_delegate && [_delegate respondsToSelector:@selector(pageControl:didSelectPageOfIndex:)]) {
        [_delegate pageControl:self didSelectPageOfIndex:self.currentPageIndex];
    }
}

@end
