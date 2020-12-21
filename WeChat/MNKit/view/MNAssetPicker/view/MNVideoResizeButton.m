//
//  MNVideoResizeButton.m
//  MNKit
//
//  Created by Vicent on 2020/8/1.
//

#import "MNVideoResizeButton.h"

@implementation MNVideoResizeButton

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2.f;
        self.layer.borderWidth = 1.f;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setTitleColor:[self titleColorForState:self.state] forState:UIControlStateHighlighted];
    self.layer.borderColor = selected ? self.selectedColor.CGColor : self.normalColor.CGColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor.copy;
    [self setTitleColor:selectedColor forState:UIControlStateSelected];
    [self setTitleColor:[self titleColorForState:self.state] forState:UIControlStateHighlighted];
    if (self.isSelected) self.layer.borderColor = selectedColor.CGColor;
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor.copy;
    [self setTitleColor:normalColor forState:UIControlStateNormal];
    [self setTitleColor:[self titleColorForState:self.state] forState:UIControlStateHighlighted];
    if (!self.isSelected) self.layer.borderColor = normalColor.CGColor;
}

@end
