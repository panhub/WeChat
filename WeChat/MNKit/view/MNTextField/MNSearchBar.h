//
//  MNSearchBar.h
//  MNKit
//
//  Created by Vincent on 2019/3/27.
//  Copyright © 2019 Vincent. All rights reserved.
//  搜索栏

#import <UIKit/UIKit.h>
@class MNSearchBar, MNTextField;

@protocol MNSearchBarHandler <NSObject>
@optional
- (void)searchBarWillBeginSearching:(MNSearchBar *)searchBar;
- (void)searchBarDidBeginSearching:(MNSearchBar *)searchBar;
- (void)searchBarWillEndSearching:(MNSearchBar *)searchBar;
- (void)searchBarDidEndSearching:(MNSearchBar *)searchBar;
- (void)searchBarTextDidChange:(NSString *)text;
- (BOOL)searchBarShouldCancelSearching:(MNSearchBar *)searchBar;
@end

@interface MNSearchBar : UIView
/**
 事件代理
 */
@property (nonatomic, weak) id<MNSearchBarHandler> handler;
/**
 TextField代理
 */
@property (nonatomic, weak) id<UITextFieldDelegate> delegate;
/**
 按钮字体
 */
@property (nonatomic, strong) UIFont *titleFont;
/**
 内容
 */
@property (nonatomic, copy) NSString *text;
/**
 富文本
 */
@property (nonatomic, copy) NSAttributedString *attributedText;
/**
 编辑框与按钮间隔
 */
@property (nonatomic) CGFloat offset;
/**
 编辑框配置
 */
@property (nonatomic, copy) void (^textFieldConfigurationHandler) (MNSearchBar *searchBar, MNTextField *textField);

/**
 设置按钮标题
 @param title 标题
 @param state 按钮状态
 */
- (void)setTitle:(NSString *)title forState:(UIControlState)state;

/**
 设置按钮标题颜色
 @param color 颜色
 @param state 按钮状态
 */
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;

/**
 取消搜索
 */
- (void)cancel;

@end
