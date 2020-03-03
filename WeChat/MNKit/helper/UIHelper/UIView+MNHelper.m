//
//  UIView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/11/30.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIView+MNHelper.h"
#import "UIView+MNFrame.h"
#import "CALayer+MNHelper.h"
#import "UIImage+MNHelper.h"
#import "NSObject+MNSwizzle.h"
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>

static NSString * MNViewTouchInsetKey = @"mn.view.touch.inset.key";

@implementation UIView (MNHelper)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(pointInside:withEvent:) withSelector:@selector(mn_pointInside:withEvent:)];
    });
}

#pragma mark 修改按钮的触发区域
- (void)setTouchInset:(UIEdgeInsets)touchInset {
    NSValue *value = [NSValue value:&touchInset withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &MNViewTouchInsetKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)touchInset {
    NSValue *value = objc_getAssociatedObject(self, &MNViewTouchInsetKey);
    if (value) {
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    }
    return UIEdgeInsetsZero;
}

- (BOOL)mn_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled || self.hidden || self.alpha <= .01f) return NO;
    return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, self.touchInset), point);
}

#pragma mark - 设置背景图片
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (!backgroundImage || ![backgroundImage isKindOfClass:[UIImage class]]) return;
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        [imageView setImage:backgroundImage];
    } else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    } else {
        self.layer.backgroundImage = backgroundImage;
    }
}

#pragma mark - 获取背景图片
- (UIImage *)backgroundImage {
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        return imageView.image;
    } else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        return [button imageForState:UIControlStateNormal];
    } else {
        return self.layer.backgroundImage;
    }
    return nil;
}

#pragma mark - 设置锚点<不改变相对位置>
- (void)setAnchorsite:(CGPoint)anchorsite {
    anchorsite.x = MIN(MAX(0.f, anchorsite.x), 1.f);
    anchorsite.y = MIN(MAX(0.f, anchorsite.y), 1.f);
    CGRect frame = self.frame;
    CGPoint point = self.layer.anchorPoint;
    CGFloat xMargin = anchorsite.x - point.x;
    CGFloat yMargin = anchorsite.y - point.y;
    self.layer.anchorPoint = anchorsite;
    CGPoint position = self.layer.position;
    position.x += xMargin*frame.size.width;
    position.y += yMargin*frame.size.height;
    self.layer.position = position;
}

#pragma mark - 获取锚点
- (CGPoint)anchorsite {
    return self.layer.anchorPoint;
}

#pragma mark - 设置相反遮罩图
- (void)setSubtractMaskView:(UIView *)subtractMaskView {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(),
                          subtractMaskView.frame.origin.x,
                          subtractMaskView.frame.origin.y);
    [subtractMaskView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //-------------------------获取相反的遮罩图-------------------------//
    CGImageRef originalMaskImage = [image CGImage];
    float width = CGImageGetWidth(originalMaskImage);
    float height = CGImageGetHeight(originalMaskImage);
    
    int strideLength = ((width*1 + 4 - 1)/4)*4;
    unsigned char * alphaData = calloc(strideLength * height, sizeof(unsigned char));
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          kCGImageAlphaOnly);
    
    CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned char val = alphaData[y*strideLength + x];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    image = [UIImage imageWithCGImage:alphaMaskImage];
    
    CGImageRelease(alphaMaskImage);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    //-------------------------获取相反的遮罩图-------------------------//
    
    // 将取反的遮罩图设置为寄宿图
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = self.bounds;
    maskView.layer.contents = (__bridge id)(image.CGImage);
    
    self.maskView = maskView;
}

- (UIView *)subtractMaskView {
    return self.maskView;
}

#pragma mark - 快照处理
- (UIView *)snapshotView {
    UIView *snapshot = [self snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = self.frame;
    return snapshot;
}

- (UIImageView *)snapshotImageView {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.frame];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    imageView.image = self.snapshotImage;
    return imageView;
}

- (UIView *)snapshotViewWithRect:(CGRect)rect {
    UIView *snapshot = [self resizableSnapshotViewFromRect:rect
                                        afterScreenUpdates:NO
                                             withCapInsets:UIEdgeInsetsZero];
    snapshot.frame = rect;
    return snapshot;
}

- (UIImageView *)snapshotImageViewWithRect:(CGRect)rect {
    if (CGRectEqualToRect(rect, CGRectZero)) return nil;
    UIImage *image = [UIImage imageWithLayer:self.layer rect:rect];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    imageView.image = image;
    return imageView;
}

- (UIImage *)snapshotImage {
    return [UIImage imageWithLayer:self.layer];
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    return [UIImage imageWithView:self afterScreenUpdates:afterUpdates];
}

#pragma mark - 判断视图是否在父视图上
- (BOOL)containsView:(UIView *)subview {
    if (!subview) return NO;
    return [self.subviews containsObject:subview];
}

#pragma mark - 删除所有子视图
- (void)removeAllSubviews {
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

#pragma mark - 设置圆角
void UIViewSetCornerRadius (UIView *view, CGFloat radius) {
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}

#pragma mark - 设置圆角, 边框
void UIViewSetBorderRadius (UIView *view, CGFloat radius, CGFloat width, UIColor *color) {
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
    UIViewSetCornerRadius(view, radius);
}

#pragma mark - 宫格布局计算
+ (void)gridLayoutWithInitial:(CGRect)frame
                      offset:(UIOffset)offset
                       count:(NSUInteger)count
                        rows:(NSUInteger)rows
                     handler:(void(^)(CGRect, NSUInteger, BOOL *))handler
{
    if (rows == 0 || count == 0 || !handler) return;
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    CGFloat xm = offset.horizontal;
    CGFloat ym = offset.vertical;
    BOOL stop = YES;
    for (NSUInteger i = 0; i < count; i++) {
        CGFloat _x = x + (w + xm)*(i%rows);
        CGFloat _y = y + (h + ym)*(i/rows);
        CGRect rect = CGRectMake(_x, _y, w, h);
        if (handler) {
            stop = NO;
            handler(rect, i, &stop);
        }
        if (stop) break;
    }
}

- (void)gridLayoutWithInitial:(CGRect)frame
                             offset:(UIOffset)offset
                              count:(NSUInteger)count
                            handler:(void(^)(CGRect rect, NSUInteger idx, BOOL *stop))handler {
    if (count == 0 || !handler) return;
    CGFloat width = self.frame.size.width - CGRectGetMinX(frame);
    if (width < frame.size.width) return;
    NSUInteger rows = width/(frame.size.width + offset.horizontal);
    if (width - (frame.size.width + offset.horizontal)*rows >= frame.size.width) rows ++;
    [UIView gridLayoutWithInitial:frame offset:offset count:count rows:rows handler:handler];
}

#pragma mark - Copy
- (id)viewCopy {
    UIView *view = [[self.class alloc] initWithFrame:self.frame];
    view.frame = self.frame;
    view.alpha = self.alpha;
    view.hidden = self.hidden;
    view.tintColor = self.tintColor;
    view.contentMode = self.contentMode;
    view.autoresizingMask = self.autoresizingMask;
    view.userInteractionEnabled = self.userInteractionEnabled;
    view.clipsToBounds = self.clipsToBounds;
    view.layer.cornerRadius = self.layer.cornerRadius;
    view.layer.borderWidth = self.layer.borderWidth;
    view.layer.borderColor = self.layer.borderColor;
    view.layer.masksToBounds = self.layer.masksToBounds;
    view.backgroundColor = self.backgroundColor;
    view.touchInset = self.touchInset;
    if ([view respondsToSelector:NSSelectorFromString(@"setImage:")]) {
        [view setValue:[self valueForKey:@"image"] forKey:@"image"];
    }
    if ([view respondsToSelector:NSSelectorFromString(@"setFont:")]) {
        [view setValue:[self valueForKey:@"font"] forKey:@"font"];
    }
    if ([view respondsToSelector:NSSelectorFromString(@"setText:")]) {
        [view setValue:[self valueForKey:@"text"] forKey:@"text"];
    }
    if ([view respondsToSelector:NSSelectorFromString(@"setTextColor:")]) {
        [view setValue:[self valueForKey:@"textColor"] forKey:@"textColor"];
    }
    if ([view respondsToSelector:NSSelectorFromString(@"setTextAlignment:")]) {
        [view setValue:[self valueForKey:@"textAlignment"] forKey:@"textAlignment"];
    }
    if ([view respondsToSelector:NSSelectorFromString(@"setContentSize:")]) {
        [view setValue:[self valueForKey:@"contentSize"] forKey:@"contentSize"];
    }
    if ([view respondsToSelector:NSSelectorFromString(@"setContentOffset:")]) {
        [view setValue:[self valueForKey:@"contentOffset"] forKey:@"contentOffset"];
    }
    return view;
}

@end


@implementation UIView (MNEffect)
#pragma mark - 获取毛玻璃效果
UIVisualEffectView *UIBlurEffectCreate (CGRect rect, UIBlurEffectStyle style) {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [effectView setFrame:rect];
    effectView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return effectView;
}

#pragma mark - 获取自身大小的毛玻璃
- (UIVisualEffectView *)blurEffectWithStyle:(UIBlurEffectStyle)style {
    return UIBlurEffectCreate(self.bounds, style);
}

#pragma mark - 添加毛玻璃效果
void UIViewAddBlurEffect (UIView *view, UIBlurEffectStyle style) {
    if (!view) return;
    [view addSubview:UIBlurEffectCreate(view.bounds, style)];
}

#pragma mark - 重力视觉差效果
UIMotionEffect * UIMotionEffectCreate (CGFloat horizontal, CGFloat vertical) {
    horizontal = fabs(horizontal);
    vertical = fabs(vertical);
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectX.maximumRelativeValue = @(horizontal);
    effectX.minimumRelativeValue = @(-horizontal);
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    effectY.maximumRelativeValue = @(vertical);
    effectY.minimumRelativeValue = @(-vertical);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[effectX, effectY];
    
    return group;
}

#pragma mark - 添加重力视觉差效果
void UIViewAddMotionEffect (UIView *view, CGFloat horizontal, CGFloat vertical) {
    if (!view) return;
    [view addMotionEffect:UIMotionEffectCreate(horizontal, vertical)];
}

@end
