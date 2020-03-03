//
//  MNEmojiPreview.m
//  MNKit
//
//  Created by Vincent on 2019/2/9.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiPreview.h"
#import "MNEmoji.h"

@interface MNEmojiPreview ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *imageView;
@end

#define MNEmojiPreviewSize    33.f
#define MNEmojiPreviewViewMargin    12.f

@implementation MNEmojiPreview

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, MNEmojiPreviewViewMargin*2.f + MNEmojiPreviewSize, 135.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
        [self createMaskLayer];
    }
    return self;
}

- (void)createView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(MNEmojiPreviewViewMargin, 7.f, MNEmojiPreviewSize, MNEmojiPreviewSize)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UIFont *titleFont = [UIFont systemFontOfSize:13.f];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.f, imageView.bottom_mn + 2.f, self.width_mn - 4.f, titleFont.lineHeight)];
    titleLabel.font = titleFont;
    titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.3f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)createMaskLayer {
    
    CGFloat radius = 5.f;
    CGFloat radius_2 = MNEmojiPreviewViewMargin;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0.f, radius)];
    [bezierPath addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:(M_PI + M_PI_2) clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(self.width_mn - radius, 0.f)];
    [bezierPath addArcWithCenter:CGPointMake(self.width_mn - radius, radius) radius:radius startAngle:(M_PI + M_PI_2) endAngle:(M_PI + M_PI) clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(self.width_mn, self.titleLabel.bottom_mn + 3.f)];
    [bezierPath addQuadCurveToPoint:CGPointMake(self.width_mn - radius_2, self.titleLabel.bottom_mn + 5.f + radius_2*2.f) controlPoint:CGPointMake(self.width_mn - radius_2, self.titleLabel.bottom_mn + 5.f + radius_2*2.f - 10.f)];
    [bezierPath addLineToPoint:CGPointMake(self.width_mn - radius_2, self.height_mn - radius)];
    [bezierPath addArcWithCenter:CGPointMake(self.width_mn - radius_2 - radius, self.height_mn - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(radius_2 + radius, self.height_mn)];
    [bezierPath addArcWithCenter:CGPointMake(radius_2 + radius, self.height_mn - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(radius_2, self.titleLabel.bottom_mn + 5.f + radius_2*2.f)];
    [bezierPath addQuadCurveToPoint:CGPointMake(0.f, self.titleLabel.bottom_mn + 3.f) controlPoint:CGPointMake(radius_2, self.titleLabel.bottom_mn + 5.f + radius_2*2.f - 10.f)];
    [bezierPath closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    maskLayer.fillColor = [[UIColor clearColor] CGColor];
    maskLayer.strokeColor = [[[UIColor darkTextColor] colorWithAlphaComponent:.15f] CGColor];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.lineWidth = .8f;
    maskLayer.lineCap = kCALineCapRound;
    maskLayer.lineJoin = kCALineJoinRound;
    
    [self.layer insertSublayer:maskLayer atIndex:0];
}

- (void)setEmoji:(MNEmoji *)emoji {
    self.imageView.image = emoji.image;
    if (emoji.desc.length <= 2) {
        self.titleLabel.text = @"";
    } else {
        NSString *desc = [emoji.desc stringByReplacingOccurrencesOfString:@"[" withString:@""];
        desc = [desc stringByReplacingOccurrencesOfString:@"]" withString:@""];
        self.titleLabel.text = desc;
    }
}

@end
