//
//  MNVideoKeyfram.m
//  MNKit
//
//  Created by Vicent on 2020/8/1.
//

#import "MNVideoKeyfram.h"
#import "UIView+MNLayout.h"

const NSTimeInterval MNVideoKeyframAnimationDuration = .2f;

@interface MNVideoKeyfram ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MNVideoKeyfram
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
    
        UIImageView *imageView = [UIImageView imageViewWithFrame:self.bounds image:nil];
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = UIColor.clearColor;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        self.contentSize = self.bounds.size;
    }
    return self;
}

- (void)setAlignment:(MNVideoKeyframAlignment)alignment {
    _alignment = alignment;
    if (!self.imageView) return;
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.size_mn = CGSizeEqualToSize(self.contentSize, CGSizeZero) ? self.bounds.size : self.contentSize;
    self.imageView.left_mn = 0.f;
    self.imageView.centerY_mn = self.height_mn/2.f;
    if (alignment == MNVideoKeyframAlignmentLeft) {
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
    } else {
        self.imageView.right_mn = self.width_mn;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    }
}

- (void)setImageToWidth:(CGFloat)width {
    self.imageView.width_mn = width;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    if (self.imageView) self.imageView.size_mn = contentSize;
}

- (UIImage *)image {
    return self.imageView.image;
}

@end
