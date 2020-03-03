//
//  MNDatePicker.h
//  MCT_Note
//
//  Created by Vincent on 2018/7/3.
//  Copyright © 2018年 Apple.lnc. All rights reserved.
//  时间选择(>=30)弹出视图

#import <UIKit/UIKit.h>
@class MNDatePicker;

typedef NS_ENUM(NSInteger, MNDatePickerType) {
    MNDatePickerTypeCancel = 0,
    MNDatePickerTypeNow = 1,
    MNDatePickerTypeSelected
};

typedef void(^MNDatePickerHandler)(MNDatePicker *datePicker);

@protocol MNDatePickerDelegate <NSObject>
@optional
- (void)datePickerEnsureButtonClicked:(MNDatePicker *)dateSheet;
@end

@interface MNDatePicker : UIView

@property (nonatomic, assign) MNDatePickerType type;

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSString *timestamp;

@property (nonatomic, weak) id<MNDatePickerDelegate> delegate;

@property (nonatomic, strong) id userInfo;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 日期操作表单实例化
 @return 时间选择表单
 */
+ (instancetype)datePicker;

/**
 日期操作表单实例化
 @param handler 事件回调
 */
+ (instancetype)datePickerWithHandler:(MNDatePickerHandler)handler;

/**
 弹出
 */
- (void)show;

/**
 在指定视图里弹出日期操作表单
 @param view 指定视图
 */
- (void)showInView:(UIView *)view;

/**
 消失
 */
- (void)dismiss;

@end
