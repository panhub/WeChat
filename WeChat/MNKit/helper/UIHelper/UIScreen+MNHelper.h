//
//  UIScreen+MNHelper.h
//  MNKit
//
//  Created by Vicent on 2020/8/27.
//  屏幕尺寸

#import <UIKit/UIKit.h>

#define MN_SCREEN_MIN           UIScreen.min
#define MN_SCREEN_MAX          UIScreen.max
#define MN_SCREEN_WIDTH       UIScreen.width_portrait
#define MN_SCREEN_HEIGHT      UIScreen.height_portrait
#define MN_SCREEN_BOUNDS    UIScreen.bounds_portrait

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (MNHelper)
/**屏幕宽*/
@property (nonatomic, readonly, class) CGFloat width;
/**屏幕高*/
@property (nonatomic, readonly, class) CGFloat height;
/**屏幕区域*/
@property (nonatomic, readonly, class) CGRect bounds;
/**屏幕尺寸大小*/
@property (nonatomic, readonly, class) CGSize size;
/**竖屏尺寸*/
@property (nonatomic, readonly, class) CGSize size_portrait;
/**竖屏宽*/
@property (nonatomic, readonly, class) CGFloat width_portrait;
/**竖屏高*/
@property (nonatomic, readonly, class) CGFloat height_portrait;
/**竖屏区域大小*/
@property (nonatomic, readonly, class) CGRect bounds_portrait;
/**屏幕尺寸最大值*/
@property (nonatomic, readonly, class) CGFloat max;
/**屏幕尺寸最小值*/
@property (nonatomic, readonly, class) CGFloat min;
@end

NS_ASSUME_NONNULL_END
