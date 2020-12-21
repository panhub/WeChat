//
//  SETextView.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SETextView : UITextView
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

@end

NS_ASSUME_NONNULL_END
