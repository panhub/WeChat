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

- (instancetype)initWithSearchResultController:(__kindof UIViewController *)searchResultController {
    if (self = [super init]) {
        _searchResultController = searchResultController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Setter
- (void)setSearchResultController:(__kindof UIViewController *)searchResultController {
    _searchResultController = searchResultController;
    result_origin_frame = searchResultController.view.frame;
    searchResultController.view.alpha = 0.f;
    [self addChildViewController:searchResultController inView:nil];
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

#pragma mark - MNSearchBarHandler
- (void)searchBarWillBeginSearching:(MNSearchBar *)searchField {
    if (!_searchBar.superview) return;
    if ([_delegate respondsToSelector:@selector(willPresentSearchController:)]) {
        [_delegate willPresentSearchController:self];
    }
    bar_superview = _searchBar.superview;
    bar_origin_frame = _searchBar.frame;
    _searchBar.top_mn = [_searchBar.superview convertRect:_searchBar.frame toView:self.view].origin.y;
    [self.view addSubview:_searchBar];
    [UIView animateWithDuration:MNTextFieldAnimationDuration delay:0.f options:MNTextFieldAnimationOption animations:^{
        _searchBar.transform = CGAffineTransformMakeTranslation(0.f, UIStatusBarHeight() - _searchBar.top_mn);
        self.contentView.transform = _searchBar.transform;
        self.navigationBar.bottom_mn = 0.f;
        self.searchResultController.view.alpha = 1.f;
        self.searchResultController.view.top_mn = _searchBar.bottom_mn;
        if (self.isRootViewController) self.tabBarController.tabView.alpha = 0.f;
    } completion:nil];
}

- (void)searchBarDidBeginSearching:(MNSearchBar *)searchField {
    if ([_delegate respondsToSelector:@selector(didPresentSearchController:)]) {
        [_delegate didPresentSearchController:self];
    }
}

- (void)searchBarWillEndSearching:(MNSearchBar *)searchField {
    if (!_searchBar.superview) return;
    if ([_delegate respondsToSelector:@selector(willDismissSearchController:)]) {
        [_delegate willDismissSearchController:self];
    }
    [UIView animateWithDuration:MNTextFieldAnimationDuration delay:0.f options:MNTextFieldAnimationOption animations:^{
        _searchBar.transform = CGAffineTransformIdentity;
        self.contentView.transform = CGAffineTransformIdentity;
        self.navigationBar.top_mn = 0.f;
        self.searchResultController.view.alpha = 0.f;
        self.searchResultController.view.top_mn = result_origin_frame.origin.y;
        if (self.isRootViewController) self.tabBarController.tabView.alpha = 1.f;
    } completion:^(BOOL finished) {
        _searchBar.top_mn = bar_origin_frame.origin.y;
        [bar_superview addSubview:_searchBar];
        if ([self.searchResultController respondsToSelector:@selector(reset)]) {
            [self.searchResultController reset];
        }
    }];
}

- (void)searchBarDidEndSearching:(MNSearchBar *)searchField {
    if ([_delegate respondsToSelector:@selector(didDismissSearchController:)]) {
        [_delegate didDismissSearchController:self];
    }
}

- (void)searchBarTextDidChange:(NSString *)text {
    if ([_updater respondsToSelector:@selector(updateSearchResultText:forSearchController:)]) {
        [_updater updateSearchResultText:text forSearchController:self];
    }
}

#pragma mark - super
- (void)setChildController:(BOOL)childController {}

- (UIView *)emptyViewSuperview {
    return self.tableView;
}

- (CGRect)emptyViewFrame {
    return UIEdgeInsetsInsetRect(self.tableView.bounds, UIEdgeInsetsMake(self.tableView.tableHeaderView.height_mn, 0.f, 0.f, 0.f));
}

@end
