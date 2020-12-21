//
//  WXMusicPlayerButton.h
//  MNChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//  音乐播放器定制按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMusicPlayerButton : UIControl

/**背景图片*/
@property (nonatomic, copy) UIImage *image;

/**高亮图片*/
@property (nonatomic, copy) UIImage *selectedImage;

/**背景类型*/
@property (nonatomic) WXPlayStyle style;

@end

NS_ASSUME_NONNULL_END
