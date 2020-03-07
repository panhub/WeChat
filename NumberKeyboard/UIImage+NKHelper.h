//
//  UIImage+NKHelper.h
//  NumberKeyboard
//
//  Created by Vicent on 2020/3/7.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NKHelper)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
