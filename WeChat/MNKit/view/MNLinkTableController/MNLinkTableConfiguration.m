//
//  MNLinkTableConfiguration.m
//  MNKit
//
//  Created by Vincent on 2019/6/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLinkTableConfiguration.h"

@implementation MNLinkTableConfiguration
- (instancetype)init {
    if (self = [super init]) {
        _width = 100.f;
        _shadowWidth = 2.f;
        _rowHeight = 45.f;
        _titleAlignment = NSTextAlignmentCenter;
        _titleFont = [UIFont systemFontOfSize:17.f];
        _titleColor = [UIColor darkTextColor];
        _selectedTitleColor = [UIColor colorWithRed:220.f/255.f green:20.f/255.f blue:60.f/255.f alpha:1.f];
        _shadowColor = _selectedTitleColor;
        _separatorColor = [[UIColor darkTextColor] colorWithAlphaComponent:.18f];
        _backgroundColor = UIColor.clearColor;
        _cellNormalColor = UIColor.whiteColor;
        _cellHighlightedColor = UIColor.whiteColor;
        _titleNumberOfLines = 1;
        _separatorInset = UIEdgeInsetsZero;
        _titleInset = UIEdgeInsetsZero;
        _scrollPosition = MNLinkTableScrollPositionMiddle;
    }
    return self;
}
@end
