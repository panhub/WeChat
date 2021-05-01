//
//  WXLabelHeader.h
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  标签头视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXLabelHeader : UIControl

/**显示的文字*/
@property (nonatomic, copy) NSString *title;

/**文字字体*/
@property (nonatomic, strong) UIFont *titleFont;

/**偏移*/
@property (nonatomic) UIEdgeInsets contentInset;

/**分割线约束*/
@property (nonatomic) UIEdgeInsets separatorInset;

@end

NS_ASSUME_NONNULL_END
