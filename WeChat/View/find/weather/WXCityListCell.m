//
//  WXCityListCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCityListCell.h"

@implementation WXCityListCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
        self.titleLabel.frame = self.contentView.bounds;
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIViewSetBorderRadius(self.titleLabel, self.contentView.height_mn/2.f, 1.f, UIColorWithSingleRGB(71.f));
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.8f];
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
