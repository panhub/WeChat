//
//  MNLinkViewController.m
//  MNKit
//
//  Created by Vincent on 2018/12/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLinkViewController.h"
#import "MNLinkPageViewController.h"
#import "MNLinkTableView.h"

@interface MNLinkViewController ()<MNLinkTableViewDelegate,  MNLinkPageControllerDelegate, MNLinkPageControllerDataSource>
@property (nonatomic, weak) MNLinkTableView *linkTableView;
@property (nonatomic, weak) MNLinkPageViewController *pageController;
@property (nonatomic, strong) MNLinkTableConfiguration *configuration;
@end

@implementation MNLinkViewController
#pragma mark - initialized
- (void)initialized {
    [super initialized];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
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

#pragma mark - TableView
- (void)createTableView {
    MNLinkTableView *linkTableView = [[MNLinkTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.configuration.width, self.view.frame.size.height)];
    linkTableView.delegate = self;
    linkTableView.configuration = self.configuration;
    [linkTableView updateTitles:[self tableTitles]];
    [linkTableView updateSelectIndex:[self pageIndexOfInitialized] animated:NO];
    [self.view addSubview:linkTableView];
    self.linkTableView = linkTableView;
}

#pragma mark - PageView
- (void)createPageView {
    MNLinkPageViewController *pageController = [[MNLinkPageViewController alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.linkTableView.frame), 0.f, self.view.frame.size.width - CGRectGetMaxX(self.linkTableView.frame), self.view.frame.size.height)];
    pageController.delegate = self;
    pageController.dataSource = self;
    [pageController willMoveToParentViewController:self];
    [self addChildViewController:pageController];
    [self.view addSubview:pageController.view];
    [pageController didMoveToParentViewController:self];
    [pageController updateContentIfNeed];
    [pageController updateCurrentPageIndex:[self pageIndexOfInitialized]];
    [pageController reloadLastPageIndex];
    [pageController displayCurrentPageIfNeed];
    self.pageController = pageController;
}

#pragma mark - MNLinkTableViewDelegate
- (void)linkTableView:(MNLinkTableView *)tableView didSelectRowAtIndex:(NSInteger)index {
    [_pageController scrollPageToIndex:index animated:YES];
}

#pragma mark - MNLinkPageControllerDataSource & MNLinkPageControllerDelegate
- (NSUInteger)numberOfPages {
    return _linkTableView.numberOfRows;
}

- (UIViewController *)pageOfIndex:(NSUInteger)pageIndex {
    if ([self numberOfPages] <= 0) return nil;
    if ([_dataSource respondsToSelector:@selector(linkViewControllerPageOfIndex:frame:)]) {
        return [_dataSource linkViewControllerPageOfIndex:pageIndex
                                               frame:_pageController.view.bounds];
    }
    return nil;
}

- (void)linkPageController:(MNLinkPageViewController *)pageController
             willLeavePage:(UIViewController *)fromPage
                    toPage:(UIViewController *)toPage
{
    _linkTableView.selectRowEnabled = NO;
    if ([_delegate respondsToSelector:@selector(linkViewController:willLeavePageOfIndex:toPageOfIndex:)]) {
        [_delegate linkViewController:self
                 willLeavePageOfIndex:fromPage.pageIndex
                        toPageOfIndex:toPage.pageIndex];
    }
}

- (void)linkPageController:(MNLinkPageViewController *)pageController
              didLeavePage:(UIViewController *)fromPage
                    toPage:(UIViewController *)toPage
{
    _linkTableView.selectRowEnabled = YES;
    if ([_delegate respondsToSelector:@selector(linkViewController:didLeavePageOfIndex:toPageOfIndex:)]) {
        [_delegate linkViewController:self
                  didLeavePageOfIndex:fromPage.pageIndex
                        toPageOfIndex:toPage.pageIndex];
    }
}

- (void)linkPageDidScrollWithOffsetRatio:(CGFloat)ratio dragging:(BOOL)dragging {
    if (dragging) {
        [_linkTableView updateShadowOffsetOfRatio:ratio];
    } else {
        [_linkTableView scrollShadowToIndex:ratio];
    }
}

#pragma mark - Setter
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _pageController.scrollEnabled = scrollEnabled;
}

#pragma mark - Getter
- (NSUInteger)selectedIndex {
    return _linkTableView.selectedIndex;
}

- (NSUInteger)lastSelectedIndex {
    return _linkTableView.lastSelectedIndex;
}

- (BOOL)scrollEnabled {
    return _pageController.scrollEnabled;
}

- (NSUInteger)pageIndexOfInitialized {
    NSUInteger pageIndex = 0;
    NSUInteger numberOfPages = [self numberOfPages];
    if (numberOfPages > 0 && [_dataSource respondsToSelector:@selector(linkViewControllerPageIndexOfInitialized)]) {
        pageIndex = [_dataSource linkViewControllerPageIndexOfInitialized];
    }
    pageIndex = MIN(MAX(pageIndex, 0), MAX(0, (numberOfPages - 1)));
    return pageIndex;
}

- (MNLinkTableConfiguration *)configuration {
    if (!_configuration) {
        MNLinkTableConfiguration *configuration = [MNLinkTableConfiguration new];
        if ([_dataSource respondsToSelector:@selector(linkViewControllerInitializedConfiguration:)]) {
            [_dataSource linkViewControllerInitializedConfiguration:configuration];
        }
        _configuration = configuration;
    }
    return _configuration;
}

- (NSArray <NSString *>*)tableTitles {
    if ([_dataSource respondsToSelector:@selector(linkViewControllerTableTitles)]) {
        return [_dataSource linkViewControllerTableTitles];
    }
    return nil;
}

#pragma mark - reloadData
- (void)reloadData {
    if ([_delegate respondsToSelector:@selector(linkViewControllerWillReloadData:)]) {
        [_delegate linkViewControllerWillReloadData:self];
    }
    [_linkTableView reloadData];
    [_linkTableView updateTitles:[self tableTitles]];
    [_linkTableView updateSelectIndex:[self pageIndexOfInitialized] animated:NO];
    [_pageController reloadData];
    [_pageController updateCurrentPageIndex:[self pageIndexOfInitialized]];
    [_pageController reloadLastPageIndex];
    [_pageController updateContentIfNeed];
    [_pageController scrollPageToIndex:[self pageIndexOfInitialized] animated:NO];
    if ([_delegate respondsToSelector:@selector(linkViewControllerDidReloadData:)]) {
        [_delegate linkViewControllerDidReloadData:self];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [_pageController cleanCache];
}

@end
