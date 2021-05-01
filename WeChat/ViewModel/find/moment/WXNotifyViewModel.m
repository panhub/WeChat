//
//  WXNotifyViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXNotifyViewModel.h"
#import "WXNotify.h"
#import "WXMoment.h"
#import "WXTimeline.h"
#import "WXMomentNotify.h"

 CGFloat const WXNotifyCellHeight = WXNotifyTopMargin + WXNotifyBottomMargin + WXNotifyPictureWH;

@interface WXNotifyViewModel ()
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic, strong) WXNotify *notify;
@property (nonatomic, strong) WXMoment *moment;
@property (nonatomic, strong) WXExtendViewModel *avatarViewModel;
@property (nonatomic, strong) WXExtendViewModel *contentViewModel;
@property (nonatomic, strong) WXExtendViewModel *pictureViewModel;
@property (nonatomic, strong) WXExtendViewModel *nickViewModel;
@property (nonatomic, strong) WXExtendViewModel *likeViewModel;
@property (nonatomic, strong) WXExtendViewModel *dateViewModel;
@property (nonatomic, strong) WXExtendViewModel *commentViewModel;

@end

@implementation WXNotifyViewModel
+ (instancetype)viewModelWithNotify:(WXNotify *)notify {
    
    NSArray <WXMoment *>*rows = [[MNDatabase database] selectRowsModelFromTable:WXMomentTableName where:@{sql_field(notify.identifier):sql_pair(notify.moment)}.sqlQueryValue limit:NSRangeZero class:WXMoment.class];
    if (rows.count <= 0) return nil;
    
    WXUser *user = [WechatHelper.helper userForUid:notify.from_uid];
    if (!user) return nil;
    
    WXMoment *moment = rows.firstObject;
    
    WXNotifyViewModel *viewModel = WXNotifyViewModel.new;
    
    WXExtendViewModel *avatarViewModel = WXExtendViewModel.new;
    avatarViewModel.frame = CGRectMake(WXNotifyLeftMargin, WXNotifyTopMargin, WXNotifyAvatarWH, WXNotifyAvatarWH);
    avatarViewModel.content = user.avatar;
    viewModel.avatarViewModel = avatarViewModel;
    
    WXExtendViewModel *pictureViewModel = WXExtendViewModel.new;
    pictureViewModel.frame = CGRectMake(MN_SCREEN_MIN - WXNotifyRightMargin - WXNotifyPictureWH, WXNotifyTopMargin, (moment.profiles.count ? WXNotifyPictureWH : 0.f), WXNotifyPictureWH);
    pictureViewModel.content = moment.profiles;
    viewModel.pictureViewModel = pictureViewModel;
    
    WXExtendViewModel *contentViewModel = WXExtendViewModel.new;
    contentViewModel.frame = pictureViewModel.frame;
    if (moment.profiles.count) {
        contentViewModel.content = @"".attributedString;
    } else {
        NSString *content = moment.content.length ? moment.content : moment.webpage.title;
        if (content.length <= 0) content = @"";
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineSpacing = 2.f;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
        attributedString.font = WXNotifyContentFont;
        attributedString.color = WXNotifyContentFontColor;
        attributedString.paragraphStyle = paragraphStyle;
        [attributedString matchingEmojiWithFont:WXNotifyContentFont];
        contentViewModel.content = attributedString.copy;
    }

    CGFloat max = CGRectGetMinX(pictureViewModel.frame) - CGRectGetMaxX(avatarViewModel.frame) - WXNotifyAvatarNickInterval*2.f;
    
    NSString *nick = user.name;
    NSMutableAttributedString *nickAttributedString = [[NSMutableAttributedString alloc] initWithString:nick];
    nickAttributedString.font = WXNotifyNickFont;
    nickAttributedString.color = WXNotifyNickFontColor;
    CGSize nickSize = [nick sizeWithFont:WXNotifyNickFont];
    nickSize.width = MIN(nickSize.width, max);
    WXExtendViewModel *nickViewModel = WXExtendViewModel.new;
    nickViewModel.frame = CGRectMake(CGRectGetMaxX(avatarViewModel.frame) + WXNotifyAvatarNickInterval, CGRectGetMinY(avatarViewModel.frame), nickSize.width, nickSize.height);
    nickViewModel.content = nickAttributedString.copy;
    viewModel.nickViewModel = nickViewModel;
    
    NSString *date =  [WechatHelper momentTimeWithTimestamp:notify.timestamp];
    NSMutableAttributedString *dateAttributedString = [[NSMutableAttributedString alloc] initWithString:date];
    dateAttributedString.font = WXNotifyDateFont;
    dateAttributedString.color = WXNotifyDateFontColor;
    CGSize dateSize = [date sizeWithFont:WXNotifyDateFont];
    dateSize.width = MIN(dateSize.width, max);
    WXExtendViewModel *dateViewModel = WXExtendViewModel.new;
    dateViewModel.frame = CGRectMake(nickViewModel.frame.origin.x, CGRectGetMaxY(pictureViewModel.frame) - floor(dateSize.height), dateSize.width, dateSize.height);
    dateViewModel.content = dateAttributedString.copy;
    viewModel.dateViewModel = dateViewModel;
    
    WXExtendViewModel *likeViewModel = WXExtendViewModel.new;
    likeViewModel.frame = CGRectMake(nickViewModel.frame.origin.x, (CGRectGetMinY(dateViewModel.frame) - CGRectGetMaxY(nickViewModel.frame))/2.f + CGRectGetMaxY(nickViewModel.frame) - WXNotifyLikeWH/2.f, WXNotifyLikeWH, WXNotifyLikeWH);
    likeViewModel.content = @(notify.content.length > 0);
    viewModel.likeViewModel = likeViewModel;
    
    NSString *comment = notify.content ? : @"";
    NSMutableAttributedString *commentAttributedString = [[NSMutableAttributedString alloc] initWithString:comment];
    commentAttributedString.font = WXNotifyCommentFont;
    commentAttributedString.color = WXNotifyCommentFontColor;
    CGSize commentSize = [comment sizeWithFont:WXNotifyCommentFont];
    commentSize.width = MIN(commentSize.width, max);
    WXExtendViewModel *commentViewModel = WXExtendViewModel.new;
    commentViewModel.frame = CGRectMake(nickViewModel.frame.origin.x, CGRectGetMidY(likeViewModel.frame) - commentSize.height/2.f, commentSize.width, commentSize.height);
    commentViewModel.content = commentAttributedString.copy;
    viewModel.commentViewModel = commentViewModel;
    
    return viewModel;
}

@end
