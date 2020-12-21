//
//  WXCallButton.h
//  MNChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//  微信语音通话按钮

#import <UIKit/UIKit.h>

@interface WXCallButton : UIControl

/**背景图*/
@property (nonatomic, copy) UIImage *image;

/**选择图*/
@property (nonatomic, copy) UIImage *selectedImage;

/**标题*/
@property (nonatomic, copy) NSString *title;

@end
