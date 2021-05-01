//
//  WXUserPermissionHeaderView.m
//  WeChat
//
//  Created by Vicent on 2021/4/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXUserPermissionHeaderView.h"

@implementation WXUserPermissionHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.titleLabel.left_mn = 15.f;
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        self.titleLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.85f];
        self.titleLabel.numberOfLines = 1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.bottom_mn = self.contentView.height_mn - 4.f;
}

@end
