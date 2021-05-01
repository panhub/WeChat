//
//  WXUserInfoHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserInfoHeaderView.h"
#import "WXUser.h"

@interface WXUserInfoHeaderView ()
@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) UILabel *noteNameLabel;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *wechatIdLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIImageView *starView;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UIImageView *genderView;
@property (nonatomic, strong) UIImageView *lookedView;
@property (nonatomic, strong) UIImageView *privacyView;
@end

#define WXUserInfoViewMargin    5.f

@implementation WXUserInfoHeaderView
- (void)createView {
    [super createView];
    
    UIImageView *starView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 0.f, 23.f)
                                                      image:[UIImage imageNamed:@"wx_contacts_star"]];
    starView.clipsToBounds = YES;
    starView.centerY_mn = 13.f;
    [self.contentView addSubview:starView];
    self.starView = starView;
    
    UIImageView *privacyView = [UIImageView imageViewWithFrame:starView.frame
                                                         image:[UIImage imageNamed:@"wx_contacts_privacy"]];
    privacyView.clipsToBounds = YES;
    [self.contentView addSubview:privacyView];
    self.privacyView = privacyView;
    
    UIImageView *lookedView = [UIImageView imageViewWithFrame:starView.frame
                                                        image:[UIImage imageNamed:@"wx_contacts_looked"]];
    lookedView.clipsToBounds = YES;
    [self.contentView addSubview:lookedView];
    self.lookedView = lookedView;
    
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(23.f, 7.f, 62.f, 62.f) image:nil];
    UIViewSetCornerRadius(headView, 5.f);
    [self.contentView addSubview:headView];
    self.headView = headView;
    
    UILabel *noteNameLabel = [UILabel labelWithFrame:CGRectMake(headView.right_mn + 18.f, 0.f, self.width_mn - headView.right_mn - 28.f, 25.f)
                                                text:nil
                                           textColor:[UIColor blackColor]
                                                font:[UIFont systemFontOfSizes:22.f weights:.3f]];
    [self.contentView addSubview:noteNameLabel];
    self.noteNameLabel = noteNameLabel;
    
    UIImageView *genderView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 0.f, 18.f)
                                                        image:[UIImage imageNamed:@"wx_contacts_gender_male"]];
    genderView.centerY_mn = starView.centerY_mn;
    genderView.clipsToBounds = YES;
    [self.contentView addSubview:genderView];
    self.genderView = genderView;
    
    UILabel *nickNameLabel = [UILabel labelWithFrame:CGRectMake(noteNameLabel.left_mn, noteNameLabel.bottom_mn + 8.f, noteNameLabel.width_mn, 15.f)
                                                text:nil
                                           textColor:UIColorWithAlpha([UIColor darkTextColor], .5f)
                                                font:[UIFont systemFontOfSize:15.f]];
    [self.contentView addSubview:nickNameLabel];
    self.nickNameLabel = nickNameLabel;
    
    UILabel *wechatIdLabel = [UILabel labelWithFrame:CGRectMake(noteNameLabel.left_mn, nickNameLabel.bottom_mn + 8.f, noteNameLabel.width_mn, 15.f)
                                                text:nil
                                           textColor:nickNameLabel.textColor
                                                font:[UIFont systemFontOfSize:15.f]];
    [self.contentView addSubview:wechatIdLabel];
    self.wechatIdLabel = wechatIdLabel;
    
    UILabel *locationLabel = [UILabel labelWithFrame:CGRectMake(noteNameLabel.left_mn, wechatIdLabel.bottom_mn + 8.f, noteNameLabel.width_mn, 15.f)
                                                text:nil
                                           textColor:nickNameLabel.textColor
                                                font:[UIFont systemFontOfSize:15.f]];
    [self.contentView addSubview:locationLabel];
    self.locationLabel = locationLabel;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_more_line"]];
    separator.clipsToBounds = YES;
    separator.left_mn = 15.f;
    separator.height_mn = 1.f;
    separator.width_mn = self.contentView.width_mn - 15.f;
    separator.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:separator];
    self.separator = separator;
    
    self.height_mn = locationLabel.bottom_mn + 35.f;
    
    @weakify(self);
    [self.headView handTapEventHandler:^(id sender) {
        @strongify(self);
        [MNAssetBrowser presentContainer:self.headView];
    }];
}

- (void)setUser:(WXUser *)user {
    /// 头像
    self.headView.image = user.avatar ? : [UIImage imageNamed:@"common_head_placeholder"];
    /// 备注
    self.noteNameLabel.text = [NSString replacingEmptyCharacters:user.name];
    [self.noteNameLabel sizeToFit];
    /// 昵称
    self.nickNameLabel.text = user.nickname.length ? [@"昵称: " stringByAppendingString:user.nickname] : @"";
    [self.nickNameLabel sizeToFit];
    self.nickNameLabel.top_mn = self.noteNameLabel.bottom_mn + (user.nickname.length ? WXUserInfoViewMargin : 0.f);
    if (user.nickname.length <= 0) self.nickNameLabel.height_mn = 0.f;
    /// 微信号
    self.wechatIdLabel.text = user.wechatId ? [@"微信号: " stringByAppendingString:user.wechatId] : @"";
    [self.wechatIdLabel sizeToFit];
    self.wechatIdLabel.top_mn = self.nickNameLabel.bottom_mn + WXUserInfoViewMargin;
    /// 地区
    self.locationLabel.text = user.location ? [@"地区: " stringByAppendingString:user.location] : @"";
    self.locationLabel.top_mn = self.wechatIdLabel.bottom_mn + (user.location.length ? WXUserInfoViewMargin : 0.f);
    if (user.location.length <= 0) self.locationLabel.height_mn = 0.f;
    
    /// 性别
    self.genderView.left_mn = self.noteNameLabel.right_mn + 5.f;
    self.genderView.width_mn = user.gender ? self.genderView.height_mn : 0.f;
    self.genderView.image = [UIImage imageNamed:(user.gender == WechatGenderMale ? @"wx_contacts_gender_male" : @"wx_contacts_gender_female")];
    
    /// 星标朋友
    self.starView.width_mn = user.asterisk ? self.starView.height_mn : 0.f;
    self.starView.right_mn = self.width_mn - 15.f;
    /// 不让他看
    self.privacyView.width_mn = user.privacy ? self.privacyView.height_mn : 0.f;
    self.privacyView.right_mn = self.starView.left_mn;
    /// 不看他
    self.lookedView.width_mn = user.looked ? self.lookedView.height_mn : 0.f;
    self.lookedView.right_mn = self.privacyView.left_mn;
    
    /// 修改高度
    self.height_mn = MAX(self.headView.bottom_mn, self.locationLabel.bottom_mn) + 35.f;
    self.imageView.frame = self.bounds;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    UITableView *tableView = [self nextResponderForClass:UITableView.class];
    if (tableView) tableView.tableHeaderView = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.separator.bottom_mn = self.contentView.height_mn;
}

@end
