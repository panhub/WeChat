//
//  MNSegmentConfiguration.m
//  MNKit
//
//  Created by Vincent on 2018/12/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentConfiguration.h"

@implementation MNSegmentConfiguration
- (instancetype)init {
    if (self = [super init]) {
        _contentMode = MNSegmentContentModeFill;
        _shadowMask = MNSegmentShadowMaskFit;
        _scrollPosition = MNSegmentScrollPositionNone;
        _backgroundColor = [UIColor whiteColor];
        _height = 40.f;
        _titleMargin = 40.f;
        _shadowSize = CGSizeMake(15.f, 4.f);
        _titleFont = [UIFont systemFontOfSize:15.f];
        _titleColor = [UIColor darkTextColor];
        _selectedColor = [UIColor colorWithRed:220.f/255.f green:20.f/255.f blue:60.f/255.f alpha:1.f];
        _shadowColor = _selectedColor;
        _separatorColor = [[UIColor darkTextColor] colorWithAlphaComponent:.25f];
    }
    return self;
}

@end
