//
//  CustomActionSheet.h
//  MNKit
//
//  Created by Vincent on 2017/4/28.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//  自定义操作表单

#import <UIKit/UIKit.h>

@class MNActionSheet;
@protocol MNActionSheetDelegate <NSObject>
@optional
- (void)actionSheet:(MNActionSheet *)actionSheet buttonClickedAtIndex:(NSInteger)buttonIndex;
- (void)actionSheetCancelButtonClicked:(MNActionSheet *)actionSheet;
@end

typedef void(^MNActionSheetHandler)(MNActionSheet *actionSheet, NSInteger buttonIndex);

@interface MNActionSheet : UIView

/**
 利用不定参数实力化, 代理回调
 @param title 标题
 @param delegate 代理
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 操作表单
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                            delegate:(id<MNActionSheetDelegate>)delegate
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitles:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;


/**
 利用不定参数实力化, block回调<函数式>
 @param title 标题
 @param cancelButtonTitle 取消按钮标题
 @param handler 事件回调
 @param otherButtonTitle 其他按钮标题
 @return 操作表单
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                             handler:(MNActionSheetHandler)handler
                   otherButtonTitles:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;


/**
 利用数组实力化, 代理回调
 @param title 标题
 @param delegate 代理
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitles 其他按钮标题
 @return 操作表单
 */
- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<MNActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles;

/**
 利用数组实力化, block回调
 @param title 标题
 @param cancelButtonTitle 取消按钮标题
 @param handler 事件回调
 @param otherButtonTitles 其他按钮回调
 @return 操作表单
 */
- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
                      handler:(MNActionSheetHandler)handler
            otherButtonTitles:(NSArray *)otherButtonTitles;

/**
 预留数据传输
 */
@property (nonatomic, strong) id userInfo;
/**
 标题
 */
@property (nonatomic, copy, readonly) NSString *title;
/**
 取消按钮标题
 */
@property (nonatomic, readonly) NSInteger cancelButtonIndex;
/**
 按钮标题颜色
 */
@property (nonatomic, strong) UIColor *buttonTitleColor;
/**
 返回按钮标题颜色
 */
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;

/**
 获取指定按钮
 @param buttonIndex 按钮索引
 @return 按钮
 */
- (UIButton *)buttonOfIndex:(NSUInteger)buttonIndex;

/**
 获取按钮标题
 @param index 按钮索引
 @return 按钮标题
 */
- (NSString *)buttonTitleOfIndex:(NSInteger)index;

/**
 设置按钮标题颜色
 @param buttonTitleColor 标题颜色
 @param index 索引
 */
- (void)setButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index;

/**
 *弹出操作表单
 */
- (void)show;

/**
 在指定视图里弹出操作表单
 @param view 指定视图
 */
- (void)showInView:(UIView *)view;

/**
 *弹下操作表单
 */
- (void)dismiss;

/**
 强制关闭所有表单
 */
+ (void)closeActionSheet;

//====================废弃方法, 不支持此实例化方法====================//

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

//====================废弃方法, 不支持此实例化方法====================//

@end
