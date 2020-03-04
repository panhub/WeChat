//
//  MNSegmentPageController.m
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentPageController.h"
#import "MNSegmentPageView.h"
#import "UIScrollView+MNSegmentPage.h"
#import "UIScrollView+MNHelper.h"
#import "UIView+MNLayout.h"

@interface MNSegmentPageController ()<UIScrollViewDelegate>
@property (nonatomic, weak) MNSegmentPageView *scrollView;
@property (nonatomic, strong) NSMapTable<NSNumber*, UIViewController<MNSegmentSubpageDataSource>*> *pageCache; /**page缓存*/
@property (nonatomic, assign) NSUInteger currentPageIndex;/**当前page索引*/
@property (nonatomic, assign) NSUInteger lastPageIndex; /**上一次页面索引*/
@property (nonatomic, assign) NSInteger guessToIndex; /**交互滑动时猜想page索引*/
@property (nonatomic, assign) CGFloat originOffsetX; /**交互滑动初始偏移*/
@property (nonatomic, assign) BOOL needDisplayCurrentPage; /**是否需要展示page(首次出现YES)*/
@end

static NSString *MNPageContentSizeObserveKey = @"contentSize";
static NSString *MNPageContentOffsetObserveKey = @"contentOffset";
static NSString *MNPageObserveContextKey = @"mn.page.observe.context.key";

@implementation MNSegmentPageController
#pragma mark - 数据初始化
- (void)initialized {
    [super initialized];
    self.lastPageIndex = 0;
    self.currentPageIndex = 0;
    self.needDisplayCurrentPage = YES;
    self.pageCache = [NSMapTable weakToWeakObjectsMapTable];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    MNSegmentPageView *scrollView = [[MNSegmentPageView alloc]initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_needDisplayCurrentPage) {
        [_delegate pageController:self
                    willLeavePage:[self pageOfIndex:_lastPageIndex]
                           toPage:[self pageOfIndex:_currentPageIndex]];
    }
    [[self pageOfIndex:_currentPageIndex] beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_needDisplayCurrentPage) {
        _needDisplayCurrentPage = NO;
        [_delegate pageController:self
                     didLeavePage:[self pageOfIndex:_lastPageIndex]
                           toPage:[self pageOfIndex:_currentPageIndex]];
    }
    [[self pageOfIndex:_currentPageIndex] endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self pageOfIndex:_currentPageIndex] beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self pageOfIndex:_currentPageIndex] endAppearanceTransition];
}

#pragma mark - 清除缓存
- (void)cleanCache {
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self cleanPageCache];
}

- (void)cleanPageCache {
    [self removeObserving];
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull page, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeChildPage:page];
    }];
    [_pageCache removeAllObjects];
}

- (void)removeObserving {
    if (_pageCache.count <= 0) return;
    NSEnumerator <UIViewController<MNSegmentSubpageDataSource>*>*enumerator = [_pageCache objectEnumerator];
    UIViewController<MNSegmentSubpageDataSource>*page;
    while (page = [enumerator nextObject]) {
        if ([page conformsToProtocol:@protocol(MNSegmentSubpageDataSource)]) {
            UIScrollView *scrollView = [page segmentSubpageScrollView];
            if (scrollView && scrollView.observed) {
                scrollView.observed = NO;
                [scrollView removeObserver:self
                                forKeyPath:MNPageContentSizeObserveKey
                                   context:&MNPageObserveContextKey];
                [scrollView removeObserver:self
                                forKeyPath:MNPageContentOffsetObserveKey
                                   context:&MNPageObserveContextKey];
            }
        }
    }
}

- (void)removeChildPage:(UIViewController *)page {
    [page willMoveToParentViewController:nil];
    [page.view removeFromSuperview];
    [page removeFromParentViewController];
    [page didMoveToParentViewController:nil];
}

#pragma mark - reloadData
- (void)reloadData {
    self.needDisplayCurrentPage = YES;
    self.scrollEnabled = YES;
    [self reloadLastPageIndex];
    [self updateContentIfNeed];
    [self scrollPageToIndex:_currentPageIndex animated:NO];
}

#pragma mark - Update ScrollView Content
- (void)updateContentIfNeed {
    [_scrollView updateContentSizeWithNumberOfPages:[self numberOfPages]];
}

#pragma mark - Display CurrentPage
- (void)displayCurrentPageIfNeed {
    if ([self numberOfPages] > 0) {
        [_scrollView updateOffsetWithIndex:_currentPageIndex];
    }
}

#pragma mark - update page index
- (void)updateCurrentPageIndex:(NSInteger)pageIndex {
    _currentPageIndex = pageIndex;
}

- (void)reloadLastPageIndex {
    _lastPageIndex = _currentPageIndex;
}

#pragma mark - Page Of Index
- (UIViewController <MNSegmentSubpageDataSource>*)pageOfIndex:(NSInteger)pageIndex {
    UIViewController<MNSegmentSubpageDataSource> *page = [_pageCache objectForKey:@(pageIndex)];
    if (!page && [_dataSource respondsToSelector:@selector(pageOfIndex:)]) {
        page = [_dataSource pageOfIndex:pageIndex];
        if (page) {
            [self bindPage:page ofIndex:pageIndex];
            [self addChildPage:page ofIndex:pageIndex];
            [_pageCache setObject:page forKey:@(pageIndex)];
        }
    }
    return page;
}

- (void)bindPage:(UIViewController <MNSegmentSubpageDataSource>*)page ofIndex:(NSInteger)pageIndex {
    /// 保证视图加载
    page.view.backgroundColor = page.view.backgroundColor;
    UIScrollView *scrollView = [page segmentSubpageScrollView];
    if (!scrollView) return;
    scrollView.scrollsToTop = NO;
    scrollView.pageIndex = pageIndex;
    CGFloat topInsets = [_dataSource pageInsetOfInitialized];
    UIEdgeInsets insets = scrollView.contentInset;
    insets.top += topInsets;
    [scrollView setContentInset:insets];
    if ([page respondsToSelector:@selector(segmentSubpageScrollViewDidInsertInset:ofIndex:)]) {
        [page segmentSubpageScrollViewDidInsertInset:topInsets ofIndex:pageIndex];
    }
    scrollView.observed = YES;
    [scrollView addObserver:self
                 forKeyPath:MNPageContentSizeObserveKey
                    options:NSKeyValueObservingOptionNew
                    context:&MNPageObserveContextKey];
    [scrollView addObserver:self
                 forKeyPath:MNPageContentOffsetObserveKey
                    options:NSKeyValueObservingOptionNew
                    context:&MNPageObserveContextKey];
}

- (void)addChildPage:(UIViewController <MNSegmentSubpageDataSource>*)page ofIndex:(NSInteger)pageIndex
{
    CGFloat offsetX = [_scrollView offsetXOfIndex:pageIndex];
    page.view.top_mn = 0.f;
    page.view.left_mn = offsetX;
    [self addChildPage:page];
}

- (void)addChildPage:(UIViewController <MNSegmentSubpageDataSource>*)page {
    if ([self.childViewControllers containsObject:page]) return;
    [page willMoveToParentViewController:self];
    [self addChildViewController:page];
    [_scrollView addSubview:page.view];
    [page didMoveToParentViewController:self];
}

#pragma mark - Observe Of KeyPath
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:MNPageContentOffsetObserveKey]) {
        UIScrollView *scrollView = object;
        NSInteger pageIndex = scrollView.pageIndex;
        if (!scrollView || _pageCache.count <= 0 || pageIndex != _currentPageIndex || !scrollView.changeOffsetEnabled || !scrollView.contentSizeReached) return;
        
        [_delegate pageDidScrollWithOffsetY:scrollView.contentOffset.y ofIndex:pageIndex];
       
    } else if ([keyPath isEqualToString:MNPageContentSizeObserveKey]) {
        UIScrollView *scrollView = object;
        if (!scrollView || scrollView.contentSizeReached) return;
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat totalHeight = scrollView.height_mn;
        totalHeight += [_dataSource pageInsetOfInitialized];
        if (contentHeight >= totalHeight) {
            scrollView.contentSizeReached = YES;
            [scrollView setContentOffset:CGPointMake(0.f, [_dataSource pageOffsetYAtCurrent])];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.isDecelerating) return;
    _originOffsetX = [[scrollView valueForKeyPath:@"_startOffsetX"] floatValue];
    _guessToIndex = _currentPageIndex;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.isDragging || scrollView.isDecelerating) return;
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    NSInteger lastGuestIndex = (_guessToIndex < 0 ? _currentPageIndex:_guessToIndex);
    CGFloat ratio = offsetX/width;
    if (_originOffsetX < offsetX) {
        _guessToIndex = ceil(ratio); /**左滑 最小的整数但不小于本身*/
    } else {
        _guessToIndex = floor(ratio); /**右滑 最大的整数但不大于本身*/
    }
    NSInteger numberOfPages = [self numberOfPages];
    if (((_guessToIndex != _currentPageIndex && !_scrollView.isDecelerating) || _scrollView.isDecelerating) && lastGuestIndex != _guessToIndex && _guessToIndex >= 0 && _guessToIndex < numberOfPages) {
        
        UIViewController <MNSegmentSubpageDataSource>*fromePage = [self pageOfIndex:_currentPageIndex];
        UIViewController <MNSegmentSubpageDataSource>*toPage = [self pageOfIndex:_guessToIndex];
        
        if ([_delegate respondsToSelector:@selector(pageController:willLeavePage:toPage:)]) {
            [_delegate pageController:self willLeavePage:fromePage toPage:toPage];
        }
        
        if (lastGuestIndex == _currentPageIndex) {
            [fromePage beginAppearanceTransition:NO animated:YES];
        }
        [toPage beginAppearanceTransition:YES animated:YES];
        
        if (lastGuestIndex != _currentPageIndex && lastGuestIndex >= 0 && lastGuestIndex < numberOfPages) {
            UIViewController <MNSegmentSubpageDataSource>*lastGuestPage = [self pageOfIndex:lastGuestIndex];
            [lastGuestPage beginAppearanceTransition:NO animated:YES];
            [lastGuestPage endAppearanceTransition];
        }
    }
    
    [_delegate pageDidScrollWithOffsetRatio:ratio dragging:YES];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([_delegate respondsToSelector:@selector(pageDidScrollWithOffsetRatio:dragging:)]) {
        [_delegate pageDidScrollWithOffsetRatio:(targetContentOffset->x/scrollView.frame.size.width) dragging:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastPageIndex = _currentPageIndex;
    _currentPageIndex = [_scrollView currentPageIndex];
    if (_currentPageIndex == _lastPageIndex) {
        if (_guessToIndex >= 0 && _guessToIndex < [self numberOfPages]) {
            [[self pageOfIndex:_guessToIndex] beginAppearanceTransition:NO animated:YES];
            [[self pageOfIndex:_currentPageIndex] beginAppearanceTransition:YES animated:YES];
            [[self pageOfIndex:_guessToIndex] endAppearanceTransition];
            [[self pageOfIndex:_currentPageIndex] endAppearanceTransition];
        }
    } else {
        [[self pageOfIndex:_lastPageIndex] endAppearanceTransition];
        [[self pageOfIndex:_currentPageIndex] endAppearanceTransition];
    }
    _originOffsetX = scrollView.contentOffset.x;
    _guessToIndex = _currentPageIndex;
    
    if ([_delegate respondsToSelector:@selector(pageController:didLeavePage:toPage:)]) {
        [_delegate pageController:self didLeavePage:[self pageOfIndex:_lastPageIndex] toPage:[self pageOfIndex:_currentPageIndex]];
    }
}

#pragma mark - 非交互切换page动画
- (void)scrollPageToIndex:(NSInteger)index animated:(BOOL)animated {
    _lastPageIndex = _currentPageIndex;
    _currentPageIndex = index;
    UIViewController <MNSegmentSubpageDataSource>*fromPage = [self pageOfIndex:_lastPageIndex];
    UIViewController <MNSegmentSubpageDataSource>*toPage = [self pageOfIndex:_currentPageIndex];
    [_delegate pageController:self willLeavePage:fromPage toPage:toPage];
    [self __beginAppearanceTransition];
    if (animated) {
        UIView *lastView = fromPage.view;
        UIView *currentView = toPage.view;
        [_scrollView bringSubviewToFront:lastView];
        [_scrollView bringSubviewToFront:currentView];
        CGFloat lastViewStartOriginX = lastView.frame.origin.x;
        CGFloat currentViewStartOriginX = lastViewStartOriginX;
        CGFloat offset = (_lastPageIndex < _currentPageIndex) ? _scrollView.frame.size.width : -_scrollView.frame.size.width;
        currentViewStartOriginX += offset;
        CGFloat currentViewToOriginX = lastViewStartOriginX;
        CGFloat lastViewToOriginX = lastViewStartOriginX - offset;
        
        currentView.left_mn = currentViewStartOriginX;

        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            lastView.left_mn = lastViewToOriginX;
            currentView.left_mn = currentViewToOriginX;
        } completion:^(BOOL finished) {
            [self displayCurrentPageIfNeed];
            [self layoutPageView:lastView ofIndex:_lastPageIndex];
            [self layoutPageView:currentView ofIndex:_currentPageIndex];
            [self __endAppearanceTransition];
        }];
    } else {
        [self displayCurrentPageIfNeed];
        [self __endAppearanceTransition];
    }
}

/**动画开始*/
- (void)__beginAppearanceTransition {
    if (_lastPageIndex != _currentPageIndex) {
        [[self pageOfIndex:_lastPageIndex] beginAppearanceTransition:NO animated:YES];
    }
    [[self pageOfIndex:_currentPageIndex] beginAppearanceTransition:YES animated:YES];
}

/**动画结束*/
- (void)__endAppearanceTransition {
    if (_lastPageIndex != _currentPageIndex) {
        [[self pageOfIndex:_lastPageIndex] endAppearanceTransition];
    }
    [[self pageOfIndex:_currentPageIndex] endAppearanceTransition];
    [_delegate pageController:self
                 didLeavePage:[self pageOfIndex:_lastPageIndex]
                       toPage:[self pageOfIndex:_currentPageIndex]];
}

/**复原*/
- (void)layoutPageView:(UIView *)pageView ofIndex:(NSInteger)index {
    if (!pageView || index < 0 || index >= [self numberOfPages]) return;
    CGFloat offsetX = [_scrollView offsetXOfIndex:index];
    if (pageView.frame.origin.x != offsetX) pageView.left_mn = offsetX;
}

#pragma mark - Setter
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollView.scrollEnabled = scrollEnabled;
}

- (void)setFailToGestureRecognizer:(UIGestureRecognizer *)failToGestureRecognizer {
    if (!failToGestureRecognizer) return;
    [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:failToGestureRecognizer];
}

#pragma mark - Getter
- (BOOL)scrollEnabled {
    return _scrollView.scrollEnabled;
}

- (UIGestureRecognizer *)failToGestureRecognizer {
    return nil;
}

- (NSInteger)numberOfPages {
    return [_dataSource numberOfPages];
}

#pragma mark - 外界获取子界面
- (UIViewController <MNSegmentSubpageDataSource>*)pageCacheOfIndex:(NSUInteger)index {
    if (index >= _pageCache.count) return nil;
    return [_pageCache objectForKey:@(index)];
}

#pragma mark - controller config
- (BOOL)isChildViewController {
    return YES;
}

#pragma mark - dealloc
- (void)dealloc {
    [self removeObserving];
}

@end
