//
//  WXTextMessageViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTextMessageViewModel.h"

@implementation WXTextMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    /// 文字消息内容
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.message.content];
    [string matchingEmojiWithFont:WXTextMsgTextFont];
    string.font = WXTextMsgTextFont;
    string.color = WXTextMsgTextColor;
    self.textLabelModel.content = string.copy;
    if (string.length) self.imageViewModel.extend = string.copy;
    CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth() - WXTextMsgContentLeftMargin - WXTextMsgContentRightMargin)];
    if (self.message.isMine) {
        self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgAvatarContentMinMargin - WXTextMsgContentLeftMargin - size.width - WXTextMsgContentRightMargin, CGRectGetMinY(self.headButtonModel.frame), size.width + WXTextMsgContentLeftMargin + WXTextMsgContentRightMargin, size.height + WXTextMsgContentTopBottomMargin*2.f);
        self.textLabelModel.frame = CGRectMake(WXTextMsgContentRightMargin, WXTextMsgContentTopBottomMargin, size.width, size.height);
    } else {
        self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), size.width + WXTextMsgContentLeftMargin + WXTextMsgContentRightMargin, size.height + WXTextMsgContentTopBottomMargin*2.f);
        self.textLabelModel.frame = CGRectMake(WXTextMsgContentLeftMargin, WXTextMsgContentTopBottomMargin, size.width, size.height);
    }
}

@end
