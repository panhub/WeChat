//
//  UIScreen+MNHelper.m
//  MNKit
//
//  Created by Vicent on 2020/8/27.
//

#import "UIScreen+MNHelper.h"

@implementation UIScreen (MNHelper)

+ (CGFloat)width {
    return UIScreen.mainScreen.bounds.size.width;
}

+ (CGFloat)height {
    return UIScreen.mainScreen.bounds.size.height;
}

+ (CGRect)bounds {
    return UIScreen.mainScreen.bounds;
}

+ (CGSize)size {
    return UIScreen.mainScreen.bounds.size;
}

+ (CGFloat)width_portrait {
    static CGFloat main_screen_size_width;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        main_screen_size_width = UIScreen.min;
    });
    return main_screen_size_width;
}

+ (CGFloat)height_portrait {
    static CGFloat main_screen_size_height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        main_screen_size_height = UIScreen.max;
    });
    return main_screen_size_height;
}

+ (CGRect)bounds_portrait {
    return CGRectMake(0.f, 0.f, UIScreen.min, UIScreen.max);
}

+ (CGSize)size_portrait {
    return CGSizeMake(UIScreen.min, UIScreen.max);
}

+ (CGFloat)max {
    static CGFloat main_screen_size_max;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        main_screen_size_max = MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    });
    return main_screen_size_max;
}

+ (CGFloat)min {
    static CGFloat main_screen_size_min;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        main_screen_size_min = MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    });
    return main_screen_size_min;
}

@end
