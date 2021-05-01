//
//  WXContactsSectionHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXContactsSectionHeaderView.h"

@implementation WXContactsSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES;
        self.contentView.backgroundColor = VIEW_COLOR;
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .6f);
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
    titleLabel.frame = CGRectMake(15.f, (frame.size.height - 15.f)/2.f, frame.size.width - 30.f, 15.f);
}

@end
