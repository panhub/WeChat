//
//  UITextView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/5/21.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, MNTextViewActions) {
    MNTextViewActionNone = 0,
    MNTextViewActionAll = 1 << 0,
    MNTextViewActionPaste = 1 << 1,
    MNTextViewActionSelect = 1 << 2,
    MNTextViewActionSelectAll = 1 << 3,
    MNTextViewActionCut = 1 << 4,
    MNTextViewActionCopy = 1 << 5,
    MNTextViewActionDelete = 1 << 6
};

@interface UITextView (MNHelper)
/**
 文字字体 <支持 NSNumber, UIFont>
 */
@property (nonatomic) id textFont;
/**
 支持的方法
 */
@property (nonatomic) MNTextViewActions performActions;

/**
 UITextView 实例化入口
 @param frame 位置
 @param font 字体
 @param delegate 代理
 @return UITextView 实例
 */
+ (UITextView *)textFieldWithFrame:(CGRect)frame
                              font:(id)font
                          delegate:(id<UITextViewDelegate>)delegate;

@end
