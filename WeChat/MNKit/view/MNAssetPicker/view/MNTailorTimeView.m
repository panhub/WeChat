//
//  MNTailorTimeView.m
//  MNKit
//
//  Created by Vicent on 2020/8/2.
//

#import "MNTailorTimeView.h"
#import "NSDate+MNHelper.h"

@interface MNTailorTimeView ()
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation MNTailorTimeView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *timeLabel = [UILabel labelWithFrame:CGRectZero text:@"00:00" alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:11.f]];
        timeLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.83f];
        [timeLabel sizeToFit];
        timeLabel.size_mn = UIEdgeInsetsInsetRect(timeLabel.bounds, UIEdgeInsetsMake(-4.f, -8.f, -3.f, -8.f)).size;
        timeLabel.origin_mn = CGPointZero;
        timeLabel.layer.cornerRadius = 2.f;
        timeLabel.clipsToBounds = YES;
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        self.width_mn = timeLabel.width_mn;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 1.f, 11.f)];
        separator.top_mn = timeLabel.bottom_mn + 5.f;
        separator.centerX_mn = self.width_mn/2.f;
        separator.backgroundColor = UIColor.whiteColor;
        [self addSubview:separator];
        
        self.height_mn = separator.bottom_mn + 5.f;
    }
    return self;
}

- (void)setDuration:(NSTimeInterval)duration {
    self.timeLabel.text = [NSDate timeStringWithInterval:@(duration)];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor.copy;
    self.separator.backgroundColor = separatorColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor.copy;
    self.timeLabel.textColor = textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.timeLabel.backgroundColor = backgroundColor;
}

@end
