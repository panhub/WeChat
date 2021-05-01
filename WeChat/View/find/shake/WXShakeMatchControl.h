//
//  WXShakeMatchControl.h
//  WeChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//  摇一摇底部控制

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXShakeMatchControl : UIControl

/**背景图*/
@property (nonatomic, copy) UIImage *image;

/**选择图*/
@property (nonatomic, copy) UIImage *selectedImage;

/**标题*/
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
