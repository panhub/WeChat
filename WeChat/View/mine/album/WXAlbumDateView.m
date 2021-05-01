//
//  WXAlbumDateView.m
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXAlbumDateView.h"

@interface WXAlbumDateView ()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation WXAlbumDateView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = MN_RGB(247.f);
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:[UIColor.darkGrayColor colorWithAlphaComponent:.75f] font:[UIFont systemFontOfSize:14.f]];
        textLabel.left_mn = 16.f;
        textLabel.numberOfLines = 1;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        self.height_mn = 35.f;
    }
    return self;
}

- (void)layoutSubviews {
    [self.textLabel sizeToFit];
    self.textLabel.centerY_mn = self.height_mn/2.f;
}

- (void)setDate:(NSString *)date {
    _date = date.copy;
    self.textLabel.text = date;
    [self setNeedsLayout];
}

@end
