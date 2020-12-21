//
//  MNNumberKeyboard.h
//  MNKit
//
//  Created by Vincent on 2019/4/13.
//  Copyright © 2019 Vincent. All rights reserved.
//  数字键盘

#import <UIKit/UIKit.h>
@class MNNumberKeyboard;

@protocol MNNumberKeyboardDelegate <NSObject>
@optional
/**选择数字*/
- (void)numberKeyboardDidSelectNumber:(NSString *)number;
/**文字改变*/
- (void)numberKeyboardTextDidChange:(MNNumberKeyboard *)keyboard;
/**删除按钮响应事件*/
- (void)numberKeyboardDidClickDeleteButton:(MNNumberKeyboard *)keyboard;
@end

@interface MNNumberKeyboard : UIView
/**
 数字
 */
@property (nonatomic, copy, readonly) NSString *text;
/**
 是否允许输入小数
 */
@property (nonatomic) BOOL inputDecimalEnabled;
/**
 精度<允许输入小数的前提下, 小数点后可输入多少位>
 */
@property (nonatomic) NSUInteger precision;
/**
 交互代理
 */
@property (nonatomic, weak) id<MNNumberKeyboardDelegate> delegate;

/**
 重置键盘状态
 */
- (void)updateIfNeeded;

@end
