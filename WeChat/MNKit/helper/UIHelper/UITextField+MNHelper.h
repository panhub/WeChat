//
//  UITextField+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/12/11.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MNTextFieldActions) {
    MNTextFieldActionNone = 0,
    MNTextFieldActionAll = 1 << 0,
    MNTextFieldActionPaste = 1 << 1,
    MNTextFieldActionSelect = 1 << 2,
    MNTextFieldActionSelectAll = 1 << 3,
    MNTextFieldActionCut = 1 << 4,
    MNTextFieldActionCopy = 1 << 5,
    MNTextFieldActionDelete = 1 << 6
};

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (MNHelper)

/**
 占位符颜色
 */
@property (nonatomic, nullable) UIColor *placeholderColor;
/**
 占位符字体
 */
@property (nonatomic, nullable) UIFont *placeholderFont;
/**
 光标位置
 */
@property (nonatomic) NSRange selectedRange;
/**
 文字字体 <支持 NSNumber, UIFont>
 */
@property (nonatomic, nullable) id textFont;
/**
 支持的方法
 */
@property (nonatomic) MNTextFieldActions performActions;


/**
 UITextField快速实例化
 @param frame {坐标, 大小}
 @param font 文字字体 <支持 NSNumber, UIFont>
 @param placeholder 占位符
 @param delegate 代理
 @return UITextField实例
 */
+ (__kindof UITextField *)textFieldWithFrame:(CGRect)frame
                               font:(id _Nullable)font
                        placeholder:(NSString *_Nullable)placeholder
                           delegate:(id<UITextFieldDelegate> _Nullable)delegate;
@end
NS_ASSUME_NONNULL_END
