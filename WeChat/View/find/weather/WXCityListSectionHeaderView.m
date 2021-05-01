//
//  WXCityListSectionHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/5/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCityListSectionHeaderView.h"

@interface WXCityListSectionHeaderView ()

@end

@implementation WXCityListSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithSingleRGB(51.f);
        self.titleLabel.frame = self.bounds;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSizes:17.f weights:.25f];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = [title copy];
}

- (NSString *)title {
    return self.titleLabel.text;
}


@end
