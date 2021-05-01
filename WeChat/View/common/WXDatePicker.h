//
//  WXDatePicker.h
//  WeChat
//
//  Created by Vicent on 2018/7/3.
//  时间选择器

#import <UIKit/UIKit.h>
@class WXDatePicker;

NS_ASSUME_NONNULL_BEGIN

typedef void(^WXDatePickerHandler)(NSDate *);

@protocol WXDatePickerDelegate <NSObject>
@optional
- (void)datePickerEnsureButtonTouchUpInside:(WXDatePicker *)datePicker;
@end

@interface WXDatePicker : UIView<MNAlertProtocol>

/**事件代理*/
@property (nonatomic, weak, nullable) id<WXDatePickerDelegate> delegate;

/**时间*/
@property (nonatomic, strong) NSDate *date;

/**
 实例化日期选择器
 @param clickedHandler 点击回调
 @return 日期选择器
 */
- (instancetype)initWithPickHandler:(WXDatePickerHandler)clickedHandler;

@end

NS_ASSUME_NONNULL_END
