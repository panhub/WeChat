//
//  MNSearchViewController.m
//  MNKit
//
//  Created by Vincent on 2019/4/26.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNSearchViewController.h"

@interface MNSearchViewController ()<MNSearchBarHandler>
{
    CGRect bar_origin_frame;
    CGRect result_origin_frame;
    UIView * __unsafe_unretained bar_superview;
}
@property (nonatomic, strong) MNSearchBar *searchBar;
@end

@implementation MNSearchViewController
- (instancetype)init {
    return [self initWithSearchResultController:nil];
}

- (instancetype)initWithSearchResultController:(__kindof UIViewController <MNSearchResultUpdating>*)searchResultController {
    if (self = [super init]) {
        _searchResultController = searchResultController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)beginSearching {
    [_searchBar becomeFirstResponder];
}

- (void)endSearching {
    [_searchBar cancel];
}

#pragma mark - Setter
- (void)setSearchResultController:(__kindof UIViewController *)searchResultController {
    _searchResultController = searchResultController;
    result_origin_frame = searchResultController.view.frame;
    searchResultController.view.alpha = 0.f;
    if (!searchResultController.parentViewController) [self addChildViewController:searchResultController inView:nil];
}

#pragma mark - Getter
- (MNSearchBar *)searchBar {
    if (!_searchBar) {
        MNSearchBar *searchBar = [[MNSearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, self.navigationBarHeight)];
        searchBar.handler = self;
        _searchBar = searchBar;
    }
    return _searchBar;
}

- (CGRect)optimizeRectForSearchController {
    if (self.listViewType == MNListViewTypeTable) {
        return CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn);
    }
    return CGRectZero;
}

#pragma mark - MNSearchBarHandler
- (BOOL)searchBarShouldCancelSearching:(MNSearchBar *)searchBar {
    if ([self.delegate respondsToSelector:@selector(searchControllerShouldCancelSearching:)]) {
        [self.delegate searchControllerShouldCancelSearching:self];
    }
    return YES;
}

- (void)searchBarWillBeginSearching:(MNSearchBar *)searchField {
    if (!_searchBar.superview) return;
    if ([self.delegate respondsToSelector:@selector(searchControllerWillBeginSearching:)]) {
        [self.delegate searchControllerWillBeginSearching:self];
    }
    MNExtendViewController *vc = self;
    if ([self.delegate respondsToSelector:@selector(searchControllerAnimationSource:)]) {
        vc = (MNExtendViewController *)[self.delegate searchControllerAnimationSource:self];
    }
    bar_superview = self.searchBar.superview;
    bar_origin_frame = self.searchBar.frame;
    self.searchBar.top_mn = [self.searchBar.superview convertRect:self.searchBar.frame toView:vc.view].origin.y;
    [vc.view addSubview:self.searchBar];
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:MNTextFieldAnimationDuration delay:0.f options:MNTextFieldAnimationOption animations:^{
        weakself.searchBar.transform = CGAffineTransformMakeTranslation(0.f, MN_STATUS_BAR_HEIGHT - weakself.searchBar.top_mn);
        weakself.contentView.transform = weakself.searchBar.transform;
        weakself.searchResultController.view.alpha = 1.f;
        weakself.searchResultController.view.top_mn = weakself.searchBar.bottom_mn;
        if ([vc respondsToSelector:@selector(navigationBar)]) vc.navigationBar.bottom_mn = 0.f;
        if ([vc respondsToSelector:@selector(isRootViewController)] && vc.isRootViewController && [vc.tabBarController respondsToSelector:@selector(tabView)]) {
            vc.tabBarController.tabView.alpha = 0.f;
        }
    } completion:nil];
}

- (void)searchBarDidBeginSearching:(MNSearchBar *)searchField {
    if ([self.delegate respondsToSelector:@selector(searchControllerDidBeginSearching:)]) {
        [self.delegate searchControllerDidBeginSearching:self];
    }
}

- (void)searchBarWillEndSearching:(MNSearchBar *)searchField {
    if (!_searchBar.superview || !bar_superview) return;
    if ([self.delegate respondsToSelector:@selector(searchControllerWillEndSearching:)]) {
        [self.delegate searchControllerWillEndSearching:self];
    }
    MNExtendViewController *vc = self;
    if ([self.delegate respondsToSelector:@selector(searchControllerAnimationSource:)]) {
        vc = (MNExtendViewController *)[self.delegate searchControllerAnimationSource:self];
    }
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:MNTextFieldAnimationDuration delay:0.f options:MNTextFieldAnimationOption animations:^{
        weakself.searchBar.transform = CGAffineTransformIdentity;
        weakself.contentView.transform = CGAffineTransformIdentity;
        weakself.searchResultController.view.alpha = 0.f;
        weakself.searchResultController.view.top_mn = result_origin_frame.origin.y;
        if ([vc respondsToSelector:@selector(navigationBar)]) vc.navigationBar.top_mn = 0.f;
        if ([vc respondsToSelector:@selector(isRootViewController)] && vc.isRootViewController && [vc.tabBarController respondsToSelector:@selector(tabView)]) {
            vc.tabBarController.tabView.alpha = 1.f;
        }
    } completion:^(BOOL finished) {
        weakself.searchBar.top_mn = bar_origin_frame.origin.y;
        [bar_superview addSubview:weakself.searchBar];
        if ([weakself.searchResultController respondsToSelector:@selector(resetSearchResults)]) {
            [weakself.searchResultController resetSearchResults];
        }
    }];
}

- (void)searchBarDidEndSearching:(MNSearchBar *)searchField {
    if ([self.delegate respondsToSelector:@selector(searchControllerDidEndSearching:)]) {
        [self.delegate searchControllerDidEndSearching:self];
    }
}

- (void)searchBarTextDidChange:(NSString *)text {
    if ([self.updater respondsToSelector:@selector(updateSearchResultText:forSearchController:)]) {
        [self.updater updateSearchResultText:text forSearchController:self];
    }
}

#pragma mark - super
- (UIView *)emptyViewSuperview {
    return self.tableView;
}

- (CGRect)emptyViewFrame {
    return UIEdgeInsetsInsetRect(self.tableView.bounds, UIEdgeInsetsMake(self.tableView.tableHeaderView.height_mn, 0.f, 0.f, 0.f));
}

@end
