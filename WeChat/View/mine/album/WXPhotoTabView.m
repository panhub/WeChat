//
//  WXPhotoTabView.m
//  WeChat
//
//  Created by Vicent on 2021/4/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXPhotoTabView.h"
#import "WXPhotoTipButton.h"
#import "WXMoment.h"

@interface WXPhotoTabView ()
@property (nonatomic, strong) UIImageView *likedView;
@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) WXPhotoTipButton *likeTip;
@property (nonatomic, strong) WXPhotoTipButton *likeButton;
@property (nonatomic, strong) WXPhotoTipButton *commentTip;
@property (nonatomic, strong) WXPhotoTipButton *commentButton;
@end

@implementation WXPhotoTabView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.width = MN_SCREEN_MIN;
    frame.size.height = MN_TAB_SAFE_HEIGHT + 45.f;
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = MN_RGB(23.f);
        
        WXPhotoTipButton *likeButton = WXPhotoTipButton.new;
        likeButton.imageView.image = [UIImage imageNamed:@"album_like"];
        likeButton.titleLabel.text = @"赞";
        likeButton.titleLabel.textColor = UIColor.whiteColor;
        likeButton.titleLabel.font = [UIFont systemFontOfSizes:13.f weights:MNFontWeightMedium];
        likeButton.margin = 4.f;
        likeButton.imageView.width_mn = 15.f;
        [likeButton.imageView sizeFitToWidth];
        [likeButton sizeToFit];
        likeButton.left_mn = 8.f;
        likeButton.top_mn = 12.f;
        likeButton.touchInset = UIEdgeInsetWith(-5.f);
        [self addSubview:likeButton];
        self.likeButton = likeButton;
        
        UIImageView *separator = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"album_comment_line"]];
        separator.width_mn = 1.5f;
        separator.height_mn = likeButton.height_mn + 10.f;
        separator.contentMode = UIViewContentModeScaleAspectFill;
        separator.clipsToBounds = YES;
        separator.centerY_mn = likeButton.centerY_mn;
        separator.left_mn = likeButton.right_mn + 7.f;
        [self addSubview:separator];
        self.separator = separator;
        
        WXPhotoTipButton *commentButton = WXPhotoTipButton.new;
        commentButton.imageView.image = [UIImage imageNamed:@"album_comment"];
        commentButton.titleLabel.text = @"评论";
        commentButton.titleLabel.font = likeButton.titleLabel.font;
        commentButton.titleLabel.textColor = likeButton.titleLabel.textColor;
        commentButton.margin = likeButton.margin;
        commentButton.imageView.width_mn = likeButton.imageView.width_mn;
        [commentButton.imageView sizeFitToWidth];
        [commentButton sizeToFit];
        commentButton.left_mn = separator.right_mn + 7.f;
        commentButton.centerY_mn = likeButton.centerY_mn;
        commentButton.touchInset = UIEdgeInsetWith(-5.f);
        [self addSubview:commentButton];
        self.commentButton = commentButton;
        
        WXPhotoTipButton *commentTip = WXPhotoTipButton.new;
        commentTip.imageView.image = [UIImage imageNamed:@"album_comment"];
        commentTip.titleLabel.text = @"";
        commentTip.titleLabel.font = commentButton.titleLabel.font;
        commentTip.titleLabel.textColor = UIColor.whiteColor;
        commentTip.margin = 4.f;
        commentTip.imageView.width_mn = 15.f;
        [commentTip.imageView sizeFitToWidth];
        [commentTip sizeToFit];
        commentTip.right_mn = self.width_mn - likeButton.left_mn;
        commentTip.centerY_mn = likeButton.centerY_mn;
        commentTip.touchInset = UIEdgeInsetWith(-3.f);
        [self addSubview:commentTip];
        self.commentTip = commentTip;
        
        WXPhotoTipButton *likeTip = WXPhotoTipButton.new;
        likeTip.imageView.image = [UIImage imageNamed:@"album_like"];
        likeTip.titleLabel.text = @"";
        likeTip.titleLabel.font = commentTip.titleLabel.font;
        likeTip.titleLabel.textColor = commentTip.titleLabel.textColor;
        likeTip.margin = commentTip.margin;
        likeTip.imageView.width_mn = commentTip.imageView.width_mn;
        [likeTip.imageView sizeFitToWidth];
        [likeTip sizeToFit];
        likeTip.right_mn = commentTip.left_mn - commentTip.margin;
        likeTip.centerY_mn = commentTip.centerY_mn;
        likeTip.touchInset = commentTip.touchInset;
        [self addSubview:likeTip];
        self.likeTip = likeTip;
        
        UIImageView *likedView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"album_like"]];
        likedView.alpha = 0.f;
        likedView.userInteractionEnabled = NO;
        [self addSubview:likedView];
        self.likedView = likedView;
    }
    return self;
}

- (void)addLikeTargetForTouchEvent:(id)target action:(SEL)action {
    [self.likeButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCommentTargetForTouchEvent:(id)target action:(SEL)action {
    [self.commentButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)addDetailTargetForTouchEvent:(id)target action:(SEL)action {
    [self.likeTip addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.commentTip addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)startLikeAnimation {
    CGRect rect = [self.likeButton convertRect:self.likeButton.imageView.frame toView:self];
    self.likedView.alpha = 1.f;
    self.likedView.transform = CGAffineTransformIdentity;
    self.likedView.frame = rect;
    [UIView animateWithDuration:1.f animations:^{
        self.likedView.alpha = 0.f;
        self.likedView.transform = CGAffineTransformMakeScale(2.3f, 2.3f);
    }];
}

#pragma mark - Setter
- (void)setProfile:(WXProfile *)profile {
    if (profile == _profile) return;
    _profile = profile;
    [self update];
}

- (void)update {
    
    WXProfile *profile = self.profile;
    if (!profile) return;
    
    NSArray <WXMoment *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName where:@{sql_field(profile.identifier):sql_pair(profile.moment)}.sqlQueryValue limit:NSRangeZero class:WXMoment.class];
    if (rows.count <= 0) return;
    
    WXMoment *moment = rows.lastObject;
    
    NSString *likeTitle = [moment.likes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", WXUser.shareInfo.uid]].count ? @"取消" : @"赞";
    self.likeButton.titleLabel.text = likeTitle;
    [self.likeButton sizeToFit];
    
    self.separator.left_mn = self.likeButton.right_mn + 7.f;
    self.commentButton.left_mn = self.separator.right_mn + 7.f;
    self.commentButton.centerY_mn = self.likeButton.centerY_mn;
    
    self.likeTip.titleLabel.text = moment.likes.count ? @(moment.likes.count).stringValue : @"";
    self.commentTip.titleLabel.text = moment.comments.count ? @(moment.comments.count).stringValue : @"";
    
    [self.likeTip sizeToFit];
    [self.commentTip sizeToFit];
    
    self.commentTip.right_mn = self.width_mn - self.likeButton.left_mn;
    self.likeTip.right_mn = self.commentTip.left_mn - 3.f;
    
    self.commentButton.centerY_mn = self.separator.centerY_mn = self.likeTip.centerY_mn = self.commentTip.centerY_mn = self.likeButton.centerY_mn;
}

@end
