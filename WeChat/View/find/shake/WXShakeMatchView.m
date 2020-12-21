//
//  WXShakeMatchView.m
//  MNChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeMatchView.h"

@interface WXShakeMatchView ()

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation WXShakeMatchView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.hidesWhenStopped = YES;
        [self addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:17.f]];
        textLabel.numberOfLines = 0;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        [self stopAnimating];
    }
    return self;
}

- (void)setType:(WXShakeMatchType)type {
    _type = type;
    NSArray <NSString *>*texts = @[@"正在搜索同一时\n刻摇晃手机的人", @"正在识别听到的声音...", @"正在识别听到的电视节目..."];
    NSString *text = texts[self.type];
    CGSize textSize = CGSizeZero;
    CGSize size = [NSString stringSize:@"正在搜索同一时" font:self.textLabel.font];
    if (self.type == WXShakeMatchPerson) {
        textSize = [NSString boundingSizeWithString:text size:CGSizeMake(size.width, CGFLOAT_MAX) attributes:@{NSFontAttributeName:self.textLabel.font}];
    } else {
        textSize = [NSString stringSize:text font:self.textLabel.font];
    }
    self.width_mn = textSize.width + self.indicatorView.width_mn + 5.f;
    self.height_mn = textSize.height;
    self.indicatorView.centerY_mn = size.height/2.f;
    self.textLabel.size_mn = textSize;
    self.textLabel.left_mn = self.indicatorView.right_mn + 5.f;
    self.textLabel.text = text;
    if (self.superview) self.centerX_mn = self.superview.width_mn/2.f;
}

- (void)startAnimating {
    [self.indicatorView startAnimating];
    self.hidden = NO;
}

- (void)stopAnimating {
    [self.indicatorView stopAnimating];
    self.hidden = YES;
}

@end
