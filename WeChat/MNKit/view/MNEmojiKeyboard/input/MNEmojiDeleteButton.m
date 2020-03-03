//
//  MNEmojiDeleteButton.m
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiDeleteButton.h"

@interface MNEmojiDeleteButton ()
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation MNEmojiDeleteButton

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    self.offset = UIOffsetMake(9.f, 0.f);
}

- (void)createView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    titleLabel.text = @"✕";
    titleLabel.textColor = [UIColor darkTextColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16.f];
    titleLabel.userInteractionEnabled = NO;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)createMaskLayer {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0.f, self.height_mn/2.f)];
    [bezierPath addLineToPoint:CGPointMake(self.offset.horizontal, 0.f)];
    [bezierPath addLineToPoint:CGPointMake(self.width_mn, 0.f)];
    [bezierPath addLineToPoint:CGPointMake(self.width_mn, self.height_mn)];
    [bezierPath addLineToPoint:CGPointMake(self.offset.horizontal, self.height_mn)];
    [bezierPath closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    maskLayer.fillColor = [[UIColor clearColor] CGColor];
    maskLayer.strokeColor = [[[UIColor darkTextColor] colorWithAlphaComponent:.3f] CGColor];
    maskLayer.lineWidth = .8f;
    maskLayer.lineCap = kCALineCapRound;
    maskLayer.lineJoin = kCALineJoinRound;
    
    [self.layer insertSublayer:maskLayer atIndex:0];
}

- (void)layoutSubviews {
    if (CGRectEqualToRect(self.bounds, CGRectZero) || self.titleLabel.left_mn != 0.f) return;
    
    self.titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0.f, self.offset.horizontal, 0.f, 0.f));
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self createMaskLayer];
}

#pragma mark - Setter
- (void)setOffset:(UIOffset)offset {
    _offset = offset;
    [self setNeedsLayout];
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (!titleFont) return;
    self.titleLabel.font = titleFont;
}

#pragma mark - Getter
- (UIFont *)titleFont {
    return self.titleLabel.font;
}

@end
