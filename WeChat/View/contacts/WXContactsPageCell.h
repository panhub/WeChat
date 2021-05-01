//
//  WXContactsPageCell.h
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  PageControlCell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXContactsPageCell : UIView

@property (nonatomic, strong, readonly) UILabel *textLabel;

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end

NS_ASSUME_NONNULL_END
