//
//  WXRedpacketHintView.m
//  MNChat
//
//  Created by Vincent on 2019/6/17.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketHintView.h"

@implementation WXRedpacketHintView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MN_R_G_B(235.f, 205.f, 154.f);
        self.textColor = BADGE_COLOR;
        self.font = [UIFont systemFontOfSize:16.f];
        self.textAlignment = NSTextAlignmentCenter;
        self.text = @"单个红包金额不可超过200元";
    }
    return self;
}

- (void)setVisible:(BOOL)visible {
    _visible = visible;
    [self setVisible:visible animated:YES];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated {
    if (self.top_mn < 0.f != visible) return;
    [UIView animateWithDuration:(animated ? .3f : 0.f) animations:^{
        self.top_mn = visible ? 0.f : self.height_mn*-1.f;
    }];
}

@end
