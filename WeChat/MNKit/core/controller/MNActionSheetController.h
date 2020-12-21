//
//  MNActionSheetController.h
//  MNFoundation
//
//  Created by Vicent on 2020/10/2.
//  操作表单控制器

#import "MNBaseViewController.h"

@class MNActionSheetController;
@protocol MNActionSheetControllerDelegate <NSObject>
@optional
- (void)actionSheetController:(MNActionSheetController *_Nonnull)actionSheetController buttonClickedAtIndex:(NSInteger)buttonIndex;
- (void)actionSheetControllerCancelButtonClicked:(MNActionSheetController *_Nonnull)actionSheetController;
- (void)willPresentActionSheetController:(MNActionSheetController *_Nonnull)actionSheetController;
- (void)didPresentActionSheetController:(MNActionSheetController *_Nonnull)actionSheetController;
- (void)willDismissActionSheetController:(MNActionSheetController *_Nonnull)actionSheetController;
- (void)didDismissActionSheetController:(MNActionSheetController *_Nonnull)actionSheetController;
@end

typedef void(^_Nullable MNActionSheetControllerHandler)(MNActionSheetController *_Nonnull sheetController, NSInteger buttonIndex);

NS_ASSUME_NONNULL_BEGIN

@interface MNActionSheetController : MNBaseViewController<UIActionSheetDelegate>
/**
 利用不定参数实力化, 代理回调
 @param title 标题
 @param delegate 代理
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 操作表单
 */
+ (instancetype)actionSheetWithTitle:(id _Nullable)title
                delegate:(id<MNActionSheetControllerDelegate>_Nullable)delegate
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
                             handler:(MNActionSheetControllerHandler _Nullable)handler
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
                     delegate:(id<MNActionSheetControllerDelegate> _Nullable)delegate
            cancelButtonTitle:(id _Nullable)cancelButtonTitle
            otherButtonTitles:(NSArray <id>*)otherButtonTitles;

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
            otherButtonTitles:(NSArray <id>*)otherButtonTitles
            handler:(MNActionSheetControllerHandler _Nullable)handler;

/**
 预留数据传输
 */
@property (nonatomic, strong, nullable) id userInfo;
/**
 标题颜色
 */
@property (nonatomic, strong, nullable) UIColor *titleColor;
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
 弹出操作表单
 */
- (void)show;

/**
 弹出操作表单
 @param parentViewController 指定父控制器
 */
- (void)showInController:(UIViewController *_Nullable)parentViewController;

/**
 取消操作表单
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
