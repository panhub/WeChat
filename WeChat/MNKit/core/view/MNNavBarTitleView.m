//
//  MCTCustomTitleView.m
//  MNKit
//
//  Created by Vincent on 2017/6/19.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNNavBarTitleView.h"
#import "MNConfiguration.h"
#import "MNExtern.h"

@interface MNNavBarTitleView ()
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation MNNavBarTitleView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.font = UIFontWithNameSize(MNFontNameMedium, MNFontSizeTitle);
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if (title.length <= 0) title = @"";
    _titleLabel.text = title;
}

- (NSString *)title {
    NSString *title = _titleLabel.text;
    if (title.length <= 0) title = @"";
    return title;
}

@end
