//
//  WXMoneyInputView.h
//  WeChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账输入视图

#import <UIKit/UIKit.h>
@class WXMoneyInputView;

@protocol WXMoneyInputDelegate <NSObject>

- (void)inputViewTextDidChange:(WXMoneyInputView *)inputView;

@end

@interface WXMoneyInputView : UIView
/**
 金钱
 */
@property (nonatomic, copy) NSString *money;
/**
 控件间隔
 */
@property (nonatomic) CGFloat interval;
/**
 输入事件代理
 */
@property (nonatomic, weak) id<WXMoneyInputDelegate> delegate;

@end

