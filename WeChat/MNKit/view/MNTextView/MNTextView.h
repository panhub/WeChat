//
//  MNTextView.h
//  MNKit
//
//  Created by Vincent on 2018/12/3.
//  Copyright © 2018年 小斯. All rights reserved.
//  带placeholder的TextView

#import <UIKit/UIKit.h>
@class MNTextView;

@protocol MNTextViewHandler <NSObject>
@optional
- (void)textViewTextDidChange:(MNTextView *)textView;
- (void)textView:(MNTextView *)textView fixedHeightSubscribeNext:(CGFloat)height;
@end

@interface MNTextView : UITextView
/**
 占位文字
 */
@property (nonatomic, copy) NSString *placeholder;
/**
 占位文字颜色
 */
@property (nonatomic, strong) UIColor *placeholderColor;
/**
 富文本样式
 */
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *attributes;
/**
 contentSize变化
 */
@property (nonatomic, assign) CGFloat expandHeight;
/**
 代理
 */
@property (nonatomic, weak) id<MNTextViewHandler> handler;

/**
 修改偏移以适应文字改变
 */
- (void)changeContentOffsetIfNeeded;

@end
