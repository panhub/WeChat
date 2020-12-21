//
//  MNSearchViewController.h
//  MNKit
//
//  Created by Vincent on 2019/4/26.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNListViewController.h"
#import "MNSearchBar.h"
@class MNSearchViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol MNSearchControllerDelegate <NSObject>
@optional
- (void)searchControllerWillBeginSearching:(MNSearchViewController *)searchController;
- (void)searchControllerDidBeginSearching:(MNSearchViewController *)searchController;
- (void)searchControllerWillEndSearching:(MNSearchViewController *)searchController;
- (void)searchControllerDidEndSearching:(MNSearchViewController *)searchController;
@end

@protocol MNSearchResultUpdating <NSObject>
@optional
- (void)reset;
@required
- (void)updateSearchResultText:(NSString *_Nullable)text forSearchController:(MNSearchViewController *)searchController;
@end


@interface MNSearchViewController : MNListViewController
/**
 搜索栏
 */
@property (nonatomic, strong, readonly) MNSearchBar *searchBar;
/**
 检索内容展示控制器
 */
@property (nonatomic, strong, nullable) __kindof UIViewController <MNSearchResultUpdating>*searchResultController;
/**
 检索代理
 */
@property (nonatomic, weak, nullable) id <MNSearchResultUpdating> updater;
/**
 事件代理
 */
@property (nonatomic, weak, nullable) id <MNSearchControllerDelegate> delegate;
/**
 搜索控制器正常位置
 */
@property (nonatomic, readonly) CGRect resultNormalFrame;


/**
 不支持子控制器加载
 */
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

/**
 建议实例化方式
 @param searchResultController 检索内容展示控制器
 @return 搜索控制器实例
 */
- (instancetype)initWithSearchResultController:(__kindof UIViewController <MNSearchResultUpdating>*_Nullable)searchResultController;

@end
NS_ASSUME_NONNULL_END
