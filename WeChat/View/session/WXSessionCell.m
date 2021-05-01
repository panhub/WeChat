//
//  WXSessionCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSessionCell.h"
#import "WXSession.h"
#import "WXMessage.h"

@interface WXSessionCell ()
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *badgeLabel;
@property (nonatomic, weak) UIImageView *badgeView;
@end

@implementation WXSessionCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(15.f, 10.f, self.contentView.height_mn - 20.f, self.contentView.height_mn - 20.f);
        UIViewSetCornerRadius(self.imgView, 5.f);
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, self.imgView.top_mn + 3.f, 0.f, 0.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.85f];
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.left_mn = self.titleLabel.left_mn;
        self.detailLabel.font = [UIFont systemFontOfSize:14.5f];
        self.detailLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.42f];
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 16.f, 16.f)
                                                            image:[[UIImage imageNamed:@"session_msg_notify_disable"] imageWithColor:[UIColor.grayColor colorWithAlphaComponent:.85f]]];
        badgeView.hidden = YES;
        badgeView.right_mn = self.contentView.width_mn - self.imgView.left_mn;
        [self.contentView addSubview:badgeView];
        self.badgeView = badgeView;
        
        UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.imgView.top_mn + 3.f, 0.f, 12.f)
                                                text:nil
                                           textColor:[UIColor.grayColor colorWithAlphaComponent:.7f]
                                                font:[UIFont systemFontOfSize:12.f]];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 16.f)];
        badgeLabel.userInteractionEnabled = NO;
        badgeLabel.backgroundColor = BADGE_COLOR;
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.font = [UIFont systemFontOfSize:13.f];
        badgeLabel.hidden = YES;
        badgeLabel.layer.cornerRadius = badgeLabel.height_mn/2.f;
        badgeLabel.clipsToBounds = YES;
        [self.contentView addSubview:badgeLabel];
        self.badgeLabel = badgeLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

#pragma mark - config data
- (void)setSession:(WXSession *)session {
    _session = session;
    
    [self setBadgeValue:@(session.unread_count).stringValue];
    
    WXUser *user = session.user;
    
    self.imgView.image = user.avatar;

    self.timeLabel.text = [WechatHelper msgTimeWithTimestamp:session.message.timestamp];
    [self.timeLabel sizeToFit];
    self.timeLabel.right_mn = self.contentView.width_mn - self.imgView.left_mn;
    
    self.titleLabel.text = user.name;
    [self.titleLabel sizeToFit];
    self.titleLabel.width_mn = MIN(self.timeLabel.left_mn - self.titleLabel.left_mn - 7.f, self.titleLabel.width_mn);
    
    self.detailLabel.text = session.desc;
    [self.detailLabel sizeToFit];
    self.detailLabel.bottom_mn = self.imgView.bottom_mn - (self.titleLabel.top_mn - self.imgView.top_mn);
    self.detailLabel.width_mn = self.badgeView.left_mn - self.detailLabel.left_mn - (session.mute ? 7.f : 0.f);
    
    self.badgeView.hidden = !session.mute;
    self.badgeView.centerY_mn = self.detailLabel.centerY_mn;
    
    self.contentView.backgroundColor = session.front ? VIEW_COLOR : UIColor.whiteColor;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    if (badgeValue.length <= 0 || [badgeValue isEqualToString:@"0"]) {
        _badgeLabel.hidden = YES;
        return;
    }
    if (badgeValue.length == 1) {
        _badgeLabel.width_mn = _badgeLabel.height_mn;
    } else {
        CGFloat width = [NSString stringSize:badgeValue font:_badgeLabel.font].width + 13.f;
        width = MAX(width, _badgeLabel.height_mn);
        _badgeLabel.width_mn = width;
    }
    _badgeLabel.center_mn = CGPointMake(self.imgView.right_mn, self.imgView.top_mn);
    [_badgeLabel setText:badgeValue];
    _badgeLabel.hidden = NO;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
