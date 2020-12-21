//
//  UIImageView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/11/30.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIImageView+MNHelper.h"
#import "UIImage+MNHelper.h"
#import "NSString+MNHelper.h"
#import "UIView+MNHelper.h"
#import "UIView+MNLayout.h"
#import "MNUtilities.h"

@implementation UIImageView (MNHelper)

+ (UIImageView *)imageViewWithFrame:(CGRect)frame image:(id)image {
    UIImageView *imageView = [[self alloc] initWithFrame:frame];
    imageView.image = [UIImage imageWithObject:image];
    [imageView layoutImage];
    return imageView;
}

- (void)setImage:(id)image placeholderImage:(UIImage *)placeholderImage {
    if (placeholderImage) self.image = placeholderImage;
    if (!image) return;
    if ([image isKindOfClass:UIImage.class]) {
        self.image = image;
    } else {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [UIImage imageWithObject:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (img) weakself.image = img;
            });
        });
    }
}

- (void)layoutImage {
    [self setUserInteractionEnabled:YES];
    [self setContentMode:UIViewContentModeScaleAspectFit];
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
}

- (void)sizeFitToWidth {
    UIImage *image = self.image;
    if (CGSizeIsEmpty(image.size)) return;
    self.size_mn = CGSizeMultiplyToWidth(image.size, self.width_mn);
}

- (void)sizeFitToHeight {
    UIImage *image = self.image;
    if (CGSizeIsEmpty(image.size)) return;
    self.size_mn = CGSizeMultiplyToHeight(image.size, self.height_mn);
}

- (void)startAnimationWithImages:(NSArray <UIImage *>*)images
                           duration:(NSTimeInterval)duration
                             repeat:(NSInteger)repeat {
    [self startAnimationWithImages:images duration:duration repeat:repeat completion:nil];
}

- (void)startAnimationWithImages:(NSArray <UIImage *>*)images duration:(NSTimeInterval)duration repeat:(NSUInteger)repeat completion:(void(^)(void))completion {
    if (images.count <= 0 || duration <= 0.f) {
        if (completion) completion();
        return;
    }
    self.animationImages = images;
    self.animationDuration = duration;
    self.animationRepeatCount = repeat;
    [self startAnimating];
    if (repeat > 0 && completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration*repeat * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    }
}

#pragma mark - Setter
- (void)setTint_color:(UIColor *)tint_color {
    self.tintColor = tint_color;
    UIImage *image = self.image;
    if (!image) return;
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.image = image;
    self.tintColor = tint_color;
}

#pragma mark - Getter
- (UIColor *)tint_color {
    return self.tintColor;
}

@end
