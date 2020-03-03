//
//  WXSessionListCell.m
//  MNChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSessionListCell.h"
#import "WXSession.h"
#import "WXMessage.h"

@interface WXSessionListCell ()
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *badgeLabel;
@property (nonatomic, weak) UIImageView *remindView;
@end

@implementation WXSessionListCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(15.f, 10.f, self.contentView.height_mn - 20.f, self.contentView.height_mn - 20.f);
        UIViewSetCornerRadius(self.imgView, 5.f);
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, self.imgView.top_mn, self.contentView.width_mn - self.imgView.right_mn - 80.f, self.imgView.height_mn/2.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .85f);
        
        self.detailLabel.frame = self.titleLabel.frame;
        self.detailLabel.top_mn = self.titleLabel.bottom_mn;
        self.detailLabel.font = [UIFont systemFontOfSize:15.f];
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .45f);
        
        UIImageView *remindView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - 30.f, 0.f, 15.f, 15.f)
                                                            image:UIImageNamed(@"wx_conversation_no_remind")];
        remindView.centerY_mn = self.detailLabel.centerY_mn;
        remindView.hidden = YES;
        [self.contentView addSubview:remindView];
        self.remindView = remindView;
        
        self.detailLabel.width_mn = remindView.left_mn - self.detailLabel.left_mn;
        
        UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.imgView.top_mn + 3.f, 0.f, 12.f)
                                                text:nil
                                           textColor:UIColorWithAlpha([UIColor darkTextColor], .4f)
                                                font:[UIFont systemFontOfSize:12.f]];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 16.f)];
        badgeLabel.userInteractionEnabled = NO;
        badgeLabel.backgroundColor = BADGE_COLOR;
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.font = UIFontSystem(13.f);
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
    self.remindView.hidden = !session.remind;
    [self setBadgeValue:NSStringFromNumber(@(session.unread_count))];
    WXUser *user = session.user;
    self.imgView.image = user.avatar;
    self.titleLabel.text = user.name;
    self.detailLabel.text = session.desc;
    self.timeLabel.text = [MNChatHelper chatMsgCreatedTimeWithTimestamp:session.timestamp];
    [self.timeLabel sizeToFit];
    self.timeLabel.right_mn = self.contentView.width_mn - 15.f;
    self.contentView.backgroundColor = session.front ? VIEW_COLOR : [UIColor whiteColor];
}

- (void)setBadgeValue:(NSString *)badgeValue {
    if (badgeValue.length <= 0 || [badgeValue isEqualToString:@"0"]) {
        _badgeLabel.hidden = YES;
        return;
    }
    if (badgeValue.length == 1) {
        _badgeLabel.width_mn = _badgeLabel.height_mn;
    } else {
        CGFloat width = [NSString getStringSize:badgeValue font:_badgeLabel.font].width + 13.f;
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
