//
//  SESessionHeader.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SESessionHeader.h"
#import "UIView+MNLayout.h"

@implementation SESessionHeader
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        self.size_mn = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 30.f);
        self.contentView.frame = self.bounds;
        self.contentView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:243.f/255.f alpha:1.f];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UILabel *titleLabel = UILabel.new;
        titleLabel.frame = CGRectMake(13.f, 0.f, self.contentView.width_mn - 26.f, 14.f);
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.75f];
        titleLabel.centerY_mn = self.contentView.height_mn/2.f;
        titleLabel.text = @"最近聊天";
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:titleLabel];
    }
    return self;
}

@end
