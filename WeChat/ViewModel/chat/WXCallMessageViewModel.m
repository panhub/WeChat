//
//  WXCallMessageViewModel.m
//  WeChat
//
//  Created by Vincent on 2020/2/14.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXCallMessageViewModel.h"

@implementation WXCallMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageViewModel.extend = @(self.message.type);
    NSString *img = self.message.type == WXVoiceCallMessage ? @"call_voice_voip" : (self.message.isMine ? @"call_video_voip" : @"call_video_voip_receive");
    UIImage *badgeImage = [UIImage imageNamed:img];
    CGSize badgeSize = CGSizeMake(WXCallMsgTextFont.pointSize*1.5f, WXCallMsgTextFont.pointSize*1.5f);
    self.badgeViewModel.content = badgeImage;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.message.content];
    string.font = WXCallMsgTextFont;
    string.color = WXCallMsgTextColor;
    self.textLabelModel.content = string.copy;
    CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth - WXTextMsgContentLeftMargin - WXTextMsgContentRightMargin)];
    if (self.message.isMine) {
        self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgAvatarContentMinMargin - WXTextMsgContentLeftMargin - size.width - WXTextMsgContentRightMargin - WXCallMsgTextBadgeMargin - badgeSize.width, CGRectGetMinY(self.headButtonModel.frame), size.width + WXTextMsgContentLeftMargin + WXTextMsgContentRightMargin + badgeSize.width + WXCallMsgTextBadgeMargin, size.height + WXTextMsgContentTopBottomMargin*2.f);
        self.textLabelModel.frame = CGRectMake(WXTextMsgContentRightMargin, WXTextMsgContentTopBottomMargin, size.width, size.height);
        self.badgeViewModel.frame = CGRectMake(CGRectGetMaxX(self.textLabelModel.frame) + WXCallMsgTextBadgeMargin, (CGRectGetHeight(self.imageViewModel.frame) - badgeSize.height)/2.f, badgeSize.width, badgeSize.height);
    } else {
        self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), size.width + WXTextMsgContentLeftMargin + WXTextMsgContentRightMargin + badgeSize.width + WXCallMsgTextBadgeMargin, size.height + WXTextMsgContentTopBottomMargin*2.f);
        self.badgeViewModel.frame = CGRectMake(WXTextMsgContentLeftMargin, (CGRectGetHeight(self.imageViewModel.frame) - badgeSize.height)/2.f, badgeSize.width, badgeSize.height);
        self.textLabelModel.frame = CGRectMake(CGRectGetMaxX(self.badgeViewModel.frame) + WXCallMsgTextBadgeMargin, WXTextMsgContentTopBottomMargin, size.width, size.height);
    }
}

#pragma mark - Getter
- (WXExtendViewModel *)badgeViewModel {
    if (!_badgeViewModel) {
        _badgeViewModel = WXExtendViewModel.new;
    }
    return _badgeViewModel;
}

@end
