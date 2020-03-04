//
//  MNSegmentController.m
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentController.h"
#import "MNSegmentPageController.h"
#import "MNSegmentView.h"
#import "UIView+MNLayout.h"
#import "UIScrollView+MNSegmentPage.h"

@interface MNSegmentController ()<MNSegmentPageDelegate,MNSegmentPageDataSource,MNSegmentViewDelegate, MNSegmentViewDataSource>
/**加载分段列表与表头视图*/
@property (nonatomic, strong) UIView *profileView;
/**头视图*/
@property (nonatomic, strong) UIView *headerView;
/**分段列表*/
@property (nonatomic, strong) MNSegmentView *segmentView;
/**分段视图配置*/
@property (nonatomic, strong) MNSegmentConfiguration *configuration;
/**界面区域*/
@property (nonatomic, strong) MNSegmentPageController *pageController;
@end

@implementation MNSegmentController
#pragma mark - initialized
- (void)initialized {
    [super initialized];
    self.fixedHeight = 0.f;
    self.contentOffset = CGPointZero;
    self.reloadHeaderIfNeed = NO;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createProfileView];
    [self createPageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_pageController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_pageController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_pageController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_pageController endAppearanceTransition];
}

#pragma mark - Header View
- (void)createProfileView {
    self.segmentView.top_mn = self.headerView.bottom_mn;
    UIView *profileView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width_mn, self.segmentView.bottom_mn)];
    [profileView addSubview:self.headerView];
    [profileView addSubview:self.segmentView];
    [self.view addSubview:profileView];
    self.profileView = profileView;
}

#pragma mark - Setup Page
- (void)createPageView {
    MNSegmentPageController *pageController = [[MNSegmentPageController alloc] initWithFrame:self.view.bounds];
    pageController.delegate = self;
    pageController.dataSource = self;
    [pageController willMoveToParentViewController:self];
    [self addChildViewController:pageController];
    [self.view insertSubview:pageController.view atIndex:0];
    [pageController didMoveToParentViewController:self];
    [pageController updateContentIfNeed];
    [pageController updateCurrentPageIndex:[self pageIndexOfInitialized]];
    [pageController displayCurrentPageIfNeed];
    self.pageController = pageController;
}

#pragma mark - cleanCache
- (void)cleanCache {
    [_segmentView cleanCache];
    [_pageController cleanCache];
    if (self.reloadHeaderIfNeed) {
        [_headerView willMoveToSuperview:nil];
        [_headerView removeFromSuperview];
        _headerView = nil;
    }
}

#pragma mark - 重载
- (void)reloadData {
    if ([_delegate respondsToSelector:@selector(segmentControllerWillReload:)]) {
        [_delegate segmentControllerWillReload:self];
    }
    [self cleanCache];
    [self createProfileView];
    [_segmentView reloadRightView];
    [_segmentView reloadTitles];
    [_segmentView updateSelectIndex:[self pageIndexOfInitialized]];
    [_segmentView reloadData];
    [_pageController updateCurrentPageIndex:[self pageIndexOfInitialized]];
    [_pageController reloadData];
    if ([_delegate respondsToSelector:@selector(segmentControllerDidReload:)]) {
        [_delegate segmentControllerDidReload:self];
    }
}

#pragma mark - MNSegmentPageDataSource
- (NSUInteger)numberOfPages {
    return [_segmentView numberOfItems];
}

- (UIViewController <MNSegmentSubpageDataSource>*)pageOfIndex:(NSUInteger)pageIndex {
    if ([self numberOfPages] <= 0) return nil;
    UIViewController <MNSegmentSubpageDataSource>* page;
    if ([_dataSource respondsToSelector:@selector(segmentController:childControllerOfPageIndex:)]) {
        UIViewController *pageController = [_dataSource segmentController:self childControllerOfPageIndex:pageIndex];
        if ([pageController conformsToProtocol:@protocol(MNSegmentSubpageDataSource)]) {
            page = (UIViewController <MNSegmentSubpageDataSource>*)pageController;
        }
    }
    return page;
}

- (CGFloat)pageInsetOfInitialized {
    return _profileView.frame.size.height;
}

- (CGFloat)pageOffsetYAtCurrent {
    /**
     @explain
     -_profileView.frame.size.height 为正常状态下的偏移量;
     _profileView.origin.y > 0, 说明下滑, 由于限制, 只会<= 0;
     _profileView.origin.y < 0, 说明在上滑, 偏移量应根据位置增加;
     所以, 应为 (-_profileView.frame.size.height - _profileView.origin.y);
     */
    return -(_profileView.frame.size.height + _profileView.frame.origin.y);
}

#pragma mark - MNSegmentPageDelegate
- (void)pageController:(MNSegmentPageController*)pageController willLeavePage:(UIViewController <MNSegmentSubpageDataSource>*)fromPage toPage:(UIViewController <MNSegmentSubpageDataSource>*)toPage {
    _segmentView.updateSelectedIndexEnabled = NO;
    if (_profileView.frame.size.height != _segmentView.frame.size.height) {
        fromPage.segmentSubpageScrollView.changeOffsetEnabled = NO;
        [self layoutPageOffsetY:toPage];
    }
    if ([_delegate respondsToSelector:@selector(segmentController:willLeavePageOfIndex:toPageOfIndex:)]) {
        [_delegate segmentController:self
                willLeavePageOfIndex:fromPage.segmentSubpageScrollView.pageIndex
                       toPageOfIndex:toPage.segmentSubpageScrollView.pageIndex];
    }
}

- (void)pageController:(MNSegmentPageController*)pageController didLeavePage:(UIViewController <MNSegmentSubpageDataSource>*)fromPage toPage:(UIViewController <MNSegmentSubpageDataSource>*)toPage {
    _segmentView.updateSelectedIndexEnabled = YES;
    if (_profileView.frame.size.height != _segmentView.frame.size.height) {
        /**要先from后to, 因为第一次加载时这两个是同一page*/
        fromPage.segmentSubpageScrollView.scrollsToTop = NO;
        fromPage.segmentSubpageScrollView.changeOffsetEnabled = NO;
        toPage.segmentSubpageScrollView.scrollsToTop = YES;
        toPage.segmentSubpageScrollView.changeOffsetEnabled = YES;
    }
    if ([_delegate respondsToSelector:@selector(segmentController:didLeavePageOfIndex:toPageOfIndex:)]) {
        [_delegate segmentController:self
                 didLeavePageOfIndex:fromPage.segmentSubpageScrollView.pageIndex
                       toPageOfIndex:toPage.segmentSubpageScrollView.pageIndex];
    }
}

- (void)pageDidScrollWithOffsetY:(CGFloat)offsetY ofIndex:(NSUInteger)pageIndex {
    /**
     @explain
     正常状态下偏移量已经为负<插入了Inset>
     +[self pageInsetOfInitialized] 后可计算出列表滑动了多少, 上为+, 下为-
     */
    offsetY += [self pageInsetOfInitialized];
    offsetY = [self headerOriginYWithOffsetY:offsetY];
    if (_profileView.top_mn == offsetY) return;
    _profileView.top_mn = offsetY;
    _contentOffset.y = -_profileView.top_mn;
    if ([_delegate respondsToSelector:@selector(segmentControllerProfileViewDidScroll:)]) {
        [_delegate segmentControllerProfileViewDidScroll:self];
    }
}

- (void)pageDidScrollWithOffsetRatio:(CGFloat)ratio dragging:(BOOL)dragging {
    if (dragging) {
        [_segmentView updateShadowOffsetOfRatio:ratio];
    } else {
        [_segmentView scrollShadowToIndex:ratio];
    }
    _contentOffset.x = self.view.width_mn*ratio;
    if ([_delegate respondsToSelector:@selector(segmentControllerProfileViewDidScroll:)]) {
        [_delegate segmentControllerProfileViewDidScroll:self];
    }
}

#pragma mark - MNSegmentViewDelegate
- (void)segmentView:(MNSegmentView *)segment didSelectItemAtIndex:(NSUInteger)index {
    if (index < 0 || index >= [self numberOfPages]) return;
    [_pageController scrollPageToIndex:index animated:YES];
    _contentOffset.x = self.view.width_mn*index;
    if ([_delegate respondsToSelector:@selector(segmentControllerProfileViewDidScroll:)]) {
        [_delegate segmentControllerProfileViewDidScroll:self];
    }
}

#pragma mark - MNSegmentViewDataSource
- (UIView *)segmentViewShouldLoadRightView {
    if ([_dataSource respondsToSelector:@selector(segmentControllerShouldLoadRightView:)]) {
        return [_dataSource segmentControllerShouldLoadRightView:self];
    }
    return nil;
}

- (NSArray <NSString *>*)segmentViewShouldLoadTitles {
    if ([_dataSource respondsToSelector:@selector(segmentControllerShouldLoadPageTitles:)]) {
        return [_dataSource segmentControllerShouldLoadPageTitles:self];
    }
    return nil;
}

#pragma mark - Layout Subpage Offset (修改界面的偏移量以符合Segment)
- (void)layoutPageOffsetY:(UIViewController <MNSegmentSubpageDataSource>*)page {
    if (!page || [self numberOfPages] <= 1) return;
    UIScrollView *scrollView = [page segmentSubpageScrollView];
    if (!scrollView.contentSizeReached) return; /**说明此时contenSize不符合滑动机制*/
    CGFloat y = [self headerOriginYWithOffsetY:(scrollView.contentOffset.y + [self pageInsetOfInitialized])];
    /**比较两者位置有偏差,则修改page的scrollView偏移*/
    if (fabs(_profileView.frame.origin.y - y) >= .1f) {
        [scrollView setContentOffset:CGPointMake(0.f, [self pageOffsetYAtCurrent])];
    }
}

#pragma mark - Segment Top Limit
- (CGFloat)headerOriginYWithOffsetY:(CGFloat)offsetY {
    //上滑为正, 下滑为负
    //下滑时, _header只能处于0.f位置, 上滑时保证选择视图暴露出来
    return offsetY <= 0.f ? 0.f : MAX(-offsetY, _fixedHeight - _headerView.bottom_mn);
}

#pragma mark - 滚动到指定界面
- (void)scrollPageToIndex:(NSUInteger)pageIndex {
    if (!_segmentView) return;
    [_segmentView selectItemAtIndex:pageIndex];
}

#pragma mark - 外界获取指定界面
- (UIViewController <MNSegmentSubpageDataSource>*)pageCacheOfIndex:(NSUInteger)index {
    return [_pageController pageCacheOfIndex:index];
}

#pragma mark - Setter
- (void)setFixedHeight:(CGFloat)fixedHeight {
    fixedHeight = MAX(0.f, fixedHeight);
    _fixedHeight = fixedHeight;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _pageController.scrollEnabled = scrollEnabled;
}

- (void)setSelectEnabled:(BOOL)selectEnabled {
    _segmentView.selectEnabled = selectEnabled;
}

- (void)setFailToGestureRecognizer:(UIGestureRecognizer *)failToGestureRecognizer {
    _pageController.failToGestureRecognizer = failToGestureRecognizer;
}

#pragma mark - Getter
- (BOOL)scrollEnabled {
    return _pageController.scrollEnabled;
}

- (BOOL)selectEnabled {
    return _segmentView.selectEnabled;
}

- (UIGestureRecognizer *)failToGestureRecognizer {
    return _pageController.failToGestureRecognizer;
}

- (UIView *)headerView {
    if (!_headerView) {
        UIView *headerView;
        if ([_dataSource respondsToSelector:@selector(segmentControllerShouldLoadHeaderView:)]) {
            headerView = [_dataSource segmentControllerShouldLoadHeaderView:self];
        }
        if (headerView) {
            _headerView = headerView;
        } else {
            _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    return _headerView;
}

- (NSUInteger)pageIndexOfInitialized {
    NSUInteger pageIndex = 0;
    NSUInteger numberOfPages = [self numberOfPages];
    if (numberOfPages > 0 && [_dataSource respondsToSelector:@selector(segmentControllerPageIndexOfInitialized)]) {
        pageIndex = [_dataSource segmentControllerPageIndexOfInitialized];
    }
    pageIndex = MIN(MAX(pageIndex, 0), MAX(0, (numberOfPages - 1)));
    return pageIndex;
}


#pragma mark - Lazy Load
- (MNSegmentView *)segmentView {
    if (!_segmentView) {
        CGRect frame = CGRectMake(0.f, 0.f, self.view.width_mn, self.configuration.height);
        MNSegmentView *segmentView = [[MNSegmentView alloc]initWithFrame:frame];
        segmentView.delegate = self;
        segmentView.dataSource = self;
        segmentView.configuration = self.configuration;
        [segmentView reloadRightView];
        [segmentView reloadTitles];
        [segmentView updateSelectIndex:[self pageIndexOfInitialized]];
        _segmentView = segmentView;
    }
    return _segmentView;
}

- (MNSegmentConfiguration *)configuration {
    if (!_configuration) {
        MNSegmentConfiguration *configuration = [MNSegmentConfiguration new];
        if ([_dataSource respondsToSelector:@selector(segmentControllerInitializedConfiguration:)]) {
            [_dataSource segmentControllerInitializedConfiguration:configuration];
        }
        _configuration = configuration;
    }
    return _configuration;
}

@end

