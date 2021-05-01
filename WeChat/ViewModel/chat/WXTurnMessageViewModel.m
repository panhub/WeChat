//
//  WXTurnMessageViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/20.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXTurnMessageViewModel.h"

@implementation WXTurnMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    /// 气泡
    UIImage *border = [UIImage imageNamed:@"wx_chat_turn_border"];
    self.borderModel.content = [border stretchableImageWithLeftCapWidth:35.f topCapHeight:35.f];
    /// 文字消息内容
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.message.content ? : @""];
    string.font = WXTextMsgTextFont;
    string.color = WXTextMsgTextColor;
    self.textLabelModel.content = string.copy;
    self.textLabelModel.extend = @(self.message.content.length <= 0 && [self.message.user_info boolValue]);
    if (string.length) self.imageViewModel.extend = string.copy;
    CGSize size = [string sizeOfLimitWidth:(WXMsgContentMaxWidth - WXTextMsgContentRightMargin*2.f)];
    if (size.width <= 0.f) size = [NSString boundingSizeWithString:@"啊啊啊" size:CGSizeMake(WXMsgContentMaxWidth - WXTextMsgContentRightMargin*2.f, CGFLOAT_MAX) attributes:@{NSFontAttributeName:WXTextMsgTextFont}];
    size.width = MAX(size.width, self.textLabelModel.frame.size.width);
    size.height = MAX(size.height, self.textLabelModel.frame.size.height);
    if (self.message.isMine) {
        
        self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgAvatarContentMinMargin - WXTextMsgContentLeftMargin - size.width - WXTextMsgContentRightMargin, CGRectGetMinY(self.timeLabelModel.frame), size.width + WXTextMsgContentRightMargin*2.f, size.height + WXTextMsgContentTopBottomMargin*2.f);
        self.textLabelModel.frame = CGRectMake(WXTextMsgContentRightMargin, WXTextMsgContentTopBottomMargin, size.width, size.height);
    } else {
        
        self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin + (WXTextMsgContentLeftMargin - WXTextMsgContentRightMargin), CGRectGetMinY(self.timeLabelModel.frame), size.width + WXTextMsgContentRightMargin*2.f, size.height + WXTextMsgContentTopBottomMargin*2.f);
        self.textLabelModel.frame = CGRectMake(WXTextMsgContentRightMargin, WXTextMsgContentTopBottomMargin, size.width, size.height);
    }
}

#pragma mark - Getter
- (CGFloat)height {
    return ceil(MAX(CGRectGetMaxY(self.imageViewModel.frame), CGRectGetMaxY(self.headButtonModel.frame)));
}

@end
