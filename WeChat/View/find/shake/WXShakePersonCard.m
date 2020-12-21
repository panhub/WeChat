//
//  WXShakePersonCard.m
//  MNChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakePersonCard.h"
#import "WXUser.h"

@interface WXShakePersonCard ()

@property (nonatomic, strong) UILabel *nickLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UIImageView *genderView;

@property (nonatomic, strong) UIImageView *avatarView;

@end

@implementation WXShakePersonCard
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.clearColor;
        
        UIImageView *backgroundView = [UIImageView imageViewWithFrame:self.bounds image:[[UIImage imageNamed:@"shake_card"] stretchableImageWithLeftCapWidth:35.f topCapHeight:35.f]];
        backgroundView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:backgroundView];
        
        UIImageView *avatarView = [UIImageView imageViewWithFrame:CGRectMake(15.f, 15.f, self.height_mn - 30.f, self.height_mn - 30.f) image:nil];
        avatarView.clipsToBounds = YES;
        avatarView.layer.cornerRadius = 5.f;
        [self addSubview:avatarView];
        self.avatarView = avatarView;
        
        UIImageView *indicatorView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"shake_card_indicator"].templateImage];
        indicatorView.size_mn = CGSizeMultiplyToHeight(indicatorView.image.size, 15.f);
        indicatorView.centerY_mn = self.height_mn/2.f;
        indicatorView.right_mn = self.width_mn - avatarView.left_mn;
        indicatorView.tintColor = UIColor.blackColor;
        [self addSubview:indicatorView];
        
        UILabel *nickLabel = [UILabel labelWithFrame:CGRectMake(avatarView.right_mn + 10.f, avatarView.top_mn + 3.f, 0.f, 0.f) text:nil textColor:UIColorWithSingleRGB(178.f) font:[UIFont systemFontOfSize:17.f]];
        [self addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        UILabel *detailLabel = [UILabel labelWithFrame:CGRectMake(nickLabel.left_mn, 0.f, 0.f, 0.f) text:nil textColor:nickLabel.textColor font:[UIFont systemFontOfSize:14.f]];
        [self addSubview:detailLabel];
        self.detailLabel = detailLabel;
        
        UIImageView *genderView = [UIImageView imageViewWithFrame:CGRectMake(0.f, nickLabel.top_mn, nickLabel.font.pointSize, nickLabel.font.pointSize) image:nil];
        [self addSubview:genderView];
        self.genderView = genderView;
        
        [self.subviews setValue:@NO forKey:kPath(self.userInteractionEnabled)];
    }
    return self;
}

- (void)stopAnimating {
    self.hidden = YES;
    [self.layer removeAllAnimations];
}

#pragma mark - Setter
- (void)setUser:(WXUser *)user {
    _user = user;
    user.desc = @"来自摇一摇";
    self.avatarView.image = user.avatar;
    self.nickLabel.text = user.nickname;
    self.detailLabel.text = [NSString stringWithFormat:@"相距%@公里", @(arc4random()%500 + 580)];
    [self.nickLabel sizeToFit];
    self.nickLabel.height_mn = self.nickLabel.font.pointSize;
    [self.detailLabel sizeToFit];
    self.detailLabel.top_mn = self.nickLabel.bottom_mn + 10.f;
    if (user.gender == WechatGenderUnknown) {
        self.genderView.hidden = YES;
    } else {
        self.genderView.left_mn = self.nickLabel.right_mn + 5.f;
        self.genderView.image = [UIImage imageNamed:(user.gender == WechatGenderMale ? @"wx_contacts_gender_male" : @"wx_contacts_gender_female")];
        self.genderView.hidden = NO;
    }
}

- (void)setFrame:(CGRect)frame {
    frame.size = CGSizeMake(250.f, 83.f);
    [super setFrame:frame];
}

#pragma mark - Getter
- (NSString *)distance {
    return self.detailLabel.text;
}

@end
