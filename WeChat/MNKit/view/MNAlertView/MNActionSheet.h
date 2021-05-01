//
//  CustomActionSheet.h
//  MNKit
//
//  Created by Vincent on 2017/4/28.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//  自定义操作表单

#import <UIKit/UIKit.h>
#import "MNAlertProtocol.h"

@class MNActionSheet;
@protocol MNActionSheetDelegate <NSObject>
@optional
- (void)actionSheet:(MNActionSheet *_Nonnull)actionSheet buttonClickedAtIndex:(NSInteger)buttonIndex;
- (void)actionSheetCancelButtonClicked:(MNActionSheet *_Nonnull)actionSheet;
@end

UIKIT_EXTERN const NSInteger MNActionSheetTag;

typedef void(^_Nullable MNActionSheetHandler)(MNActionSheet *_Nonnull actionSheet, NSInteger buttonIndex);

NS_ASSUME_NONNULL_BEGIN

@interface MNActionSheet : UIView<MNAlertProtocol>

/**
 利用不定参数实力化, 代理回调
 @param title 标题
 @param delegate 代理
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 操作表单
 */
+ (instancetype)actionSheetWithTitle:(id _Nullable)title
                            delegate:(id<MNActionSheetDelegate>_Nullable)delegate
                   cancelButtonTitle:(id _Nullable)cancelButtonTitle
                   otherButtonTitles:(id)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;


/**
 利用不定参数实力化, block回调<函数式>
 @param title 标题
 @param cancelButtonTitle 取消按钮标题
 @param handler 事件回调
 @param otherButtonTitle 其他按钮标题
 @return 操作表单
 */
+ (instancetype)actionSheetWithTitle:(id _Nullable)title
                   cancelButtonTitle:(id _Nullable)cancelButtonTitle
                             handler:(MNActionSheetHandler _Nullable)handler
                   otherButtonTitles:(id)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;


/**
 利用数组实力化, 代理回调
 @param title 标题
 @param delegate 代理
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitles 其他按钮标题
 @return 操作表单
 */
- (instancetype)initWithTitle:(id _Nullable)title
                     delegate:(id<MNActionSheetDelegate> _Nullable)delegate
            cancelButtonTitle:(id _Nullable)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles;

/**
 利用数组实力化, block回调
 @param title 标题
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitles 其他按钮回调
 @param handler 事件回调
 @return 操作表单
 */
- (instancetype)initWithTitle:(id _Nullable)title
            cancelButtonTitle:(id _Nullable)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
            handler:(MNActionSheetHandler _Nullable)handler;

/**
 预留数据传输
 */
@property (nonatomic, strong, nullable) id userInfo;
/**
 标题
 */
@property (nonatomic, copy, readonly) id title;
/**
 取消按钮标题
 */
@property (nonatomic, readonly) NSInteger cancelButtonIndex;
/**
 按钮标题颜色
 */
@property (nonatomic, copy, nullable) UIColor *buttonTitleColor;
/**
 返回按钮标题颜色
 */
@property (nonatomic, copy, nullable) UIColor *cancelButtonTitleColor;

/**
 获取指定按钮
 @param buttonIndex 按钮索引
 @return 按钮
 */
- (UIButton *_Nullable)buttonOfIndex:(NSUInteger)buttonIndex;

/**
 获取按钮标题
 @param index 按钮索引
 @return 按钮标题
 */
- (NSString *_Nullable)buttonTitleOfIndex:(NSInteger)index;

/**
 设置按钮标题颜色
 @param buttonTitleColor 标题颜色
 @param index 索引
 */
- (void)setButtonTitleColor:(UIColor *_Nullable)buttonTitleColor ofIndex:(NSInteger)index;

//====================废弃方法, 不支持此实例化方法====================//

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

//====================废弃方法, 不支持此实例化方法====================//

@end

NS_ASSUME_NONNULL_END
