//
//  WXChatSettingHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatSettingHeaderView.h"

@interface WXChatSettingHeaderView ()
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *avatarButton;
@end

@implementation WXChatSettingHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, MN_SEPARATOR_HEIGHT)];
        shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        shadow.backgroundColor = SEPARATOR_COLOR;
        [self addSubview:shadow];
        
        CGFloat y = (self.height_mn - 50.f - 6.f - 12.f)/2.f;
        
        UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        avatarButton.frame = CGRectMake(30.f, y, 50.f, 50.f);
        avatarButton.layer.cornerRadius = 5.f;
        avatarButton.clipsToBounds = YES;
        avatarButton.touchInset = UIEdgeInsetWith(-10.f);
        [avatarButton addTarget:self action:@selector(avatarButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:avatarButton];
        self.avatarButton = avatarButton;
        
        UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(0.f, avatarButton.bottom_mn + 6.f, avatarButton.width_mn + 40.f, 12.f)
                                                text:nil
                                       alignment:NSTextAlignmentCenter
                                           textColor:UIColorWithAlpha([UIColor darkTextColor], .7f)
                                                font:[UIFont systemFontOfSize:12.f]];
        nameLabel.centerX_mn = avatarButton.centerX_mn;
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, MN_SEPARATOR_HEIGHT)];
        separator.bottom_mn = self.height_mn;
        separator.backgroundColor = SEPARATOR_COLOR;
        [self addSubview:separator];
        self.separator = separator;
    }
    return self;
}

- (void)avatarButtonTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(headerViewAvatarButtonTouchUpInside:)]) {
        [self.delegate headerViewAvatarButtonTouchUpInside:self];
    }
}

#pragma mark - Setter
- (void)setUser:(WXUser *)user {
    _user = user;
    [self.avatarButton setBackgroundImage:user.avatar forState:UIControlStateNormal];
    self.nameLabel.text = user.notename.length > 0 ? user.notename : user.nickname;
}

#pragma mark - Overwrite
- (void)layoutSubviews {
    [super layoutSubviews];
    self.separator.bottom_mn = self.height_mn;
}

@end
