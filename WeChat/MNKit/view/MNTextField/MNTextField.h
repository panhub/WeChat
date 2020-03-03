//
//  MNTextField.h
//  MNKit
//
//  Created by Vincent on 2019/3/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNTextField;

/**
 输入框类型
 - MNTextFieldTypeCustom: 占位符在中间的输入框
 - MNTextFieldTypeNormal: 正常状态<UITextField>
 */
typedef NS_ENUM(NSInteger, MNTextFieldType) {
    MNTextFieldTypeCustom = 0,
    MNTextFieldTypeNormal
};

@protocol MNTextFieldHandler <NSObject>
@optional
- (void)textFieldTextDidChange:(MNTextField *)textField;
- (void)textFieldWillTransformBeginEditing:(BOOL)animated;
- (void)textFieldDidTransformBeginEditing:(BOOL)animated;
- (void)textFieldWillTransformEndEditing:(BOOL)animated;
- (void)textFieldDidTransformEndEditing:(BOOL)animated;
@end

UIKIT_EXTERN const CGFloat MNTextFieldAnimationDuration;
UIKIT_EXTERN const UIViewAnimationOptions MNTextFieldAnimationOption;

@interface MNTextField : UITextField

/**
 输入框类型
 */
@property (nonatomic) MNTextFieldType type;
/**
 左视图与占位符的间距
 */
@property (nonatomic) UIEdgeInsets leftInset;
/**
 富文本样式
 */
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *attributes;
/**
 代理
 */
@property (nonatomic, weak) id<MNTextFieldHandler> handler;

@end
