//
//  MNSegmentCell.m
//  MIS_MIShop
//
//  Created by Vincent on 2018/4/8.
//  Copyright © 2018年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "MNSegmentCell.h"

@interface MNSegmentCell ()

@property(nonatomic, weak) UILabel *titleLabel;

@end

@implementation MNSegmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.frame = self.bounds;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        titleLabel.textColor = [UIColor darkTextColor];
        titleLabel.numberOfLines = 1;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    [_titleLabel setText:title];
}

- (void)setTitleFont:(UIFont *)titleFont {
    [_titleLabel setFont:titleFont];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [_titleLabel setTextColor:titleColor];
}

@end
