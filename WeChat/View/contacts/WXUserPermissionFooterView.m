//
//  WXUserPermissionFooterView.m
//  WeChat
//
//  Created by Vicent on 2021/4/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXUserPermissionFooterView.h"

@implementation WXUserPermissionFooterView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.titleLabel.top_mn = 4.f;
        self.titleLabel.left_mn = 15.f;
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        self.titleLabel.text = @"对方看不到你的朋友圈、状态、微信状态等";
        self.titleLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.85f];
        [self.titleLabel sizeToFit];
    }
    return self;
}

@end
