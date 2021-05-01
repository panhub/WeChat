//
//  WXPhotoTipButton.h
//  WeChat
//
//  Created by Vicent on 2021/4/23.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册-底部按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXPhotoTipButton : UIControl

/**标题*/
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/**图片*/
@property (nonatomic, strong, readonly) UIImageView *imageView;

/**图片与文字间隔*/
@property (nonatomic) CGFloat margin;

@end

NS_ASSUME_NONNULL_END
