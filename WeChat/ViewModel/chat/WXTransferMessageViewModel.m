//
//  WXTransferMessageViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferMessageViewModel.h"
#import "WXRedpacket.h"

@implementation WXTransferMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    /// 红包信息
    WXRedpacket *redpacket = kTransform(WXRedpacket *, self.message.fileModel.content);
    /// 气泡图片
    UIImage *image;
    if (self.message.isMine) {
        image = redpacket.isOpen > 0 ? UIImageNamed(@"wx_chat_send_redpacket_border") : UIImageNamed(@"wx_chat_send_redpacket_borderHL");
    } else {
        image = redpacket.isOpen > 0 ? UIImageNamed(@"wx_chat_receive_redpacket_border") : UIImageNamed(@"wx_chat_receive_redpacket_borderHL");
    }
    self.borderModel.content = [image stretchableImageWithLeftCapWidth:35.f topCapHeight:35.f];
    /// 红包背景大小
    CGSize size = CGSizeMultiplyToWidth(image.size, WXMsgContentMaxWidth);
    if (self.message.isMine) {
        self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgAvatarContentMinMargin - size.width, CGRectGetMinY(self.headButtonModel.frame), size.width, size.height);
    } else {
        self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), size.width, size.height);
    }
    self.imageViewModel.content = image;
    self.imageViewModel.extend = redpacket;
    /// 图片
    image = [UIImage imageNamed:(redpacket.isOpen ? @"wx_transfer_draw_icon" : @"wx_transfer_icon")];
    size = CGSizeMultiplyToWidth(image.size, WXTransferMsgIconWidth);
    self.iconViewModel.content = image;
    if (self.message.isMine) {
        self.iconViewModel.frame = CGRectMake(WXTransferMsgContentLeftMargin, MEAN(self.imageViewModel.frame.size.height*WXTransferBackgroundRatio - size.height), size.width, size.height);
    } else {
        self.iconViewModel.frame = CGRectMake(WXTransferMsgContentRightMargin, MEAN(self.imageViewModel.frame.size.height*WXTransferBackgroundRatio - size.height), size.width, size.height);
    }
    /// 标题
    UIFont *textFont = WXTransferMsgTitleTextFont;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[@"¥" stringByAppendingString:redpacket.money]];
    string.color = WXTransferMsgTitleTextColor;
    string.font = textFont;
    self.textLabelModel.content = string.copy;
    self.textLabelModel.frame = CGRectMake(CGRectGetMaxX(self.iconViewModel.frame) + WXTransferMsgIconTextMargin, CGRectGetMinY(self.iconViewModel.frame), self.imageViewModel.frame.size.width - self.iconViewModel.frame.size.width - WXTransferMsgIconTextMargin - WXTransferMsgContentLeftMargin - WXTransferMsgContentRightMargin, textFont.pointSize);
    /// 领取文字
    if (redpacket.isOpen) {
        /// 区分是否是领取插入的消息
        /// 这里不可使用fromUser.uid判断, 转账领取消息的用户uid是对调的
        BOOL isMine = [redpacket.from_uid isEqualToString:[WXUser.shareInfo uid]];
        string = [[NSMutableAttributedString alloc] initWithString:(redpacket.isMine == isMine ? @"已被领取" : @"已收钱")];
        /// 拼接描述信息
        if (redpacket.isMine == isMine && redpacket.text.length > 0) {
            [string appendAttributedString:[[@"-" stringByAppendingString:redpacket.text] attributedString]];
        }
    } else {
        /// 区分是否有描述
        if (redpacket.text.length <= 0) {
            string = [[NSMutableAttributedString alloc] initWithString:(redpacket.isMine ? [@"转账给" stringByAppendingString:redpacket.toUser.name] : @"转账给你")];
        } else {
            string = [[NSMutableAttributedString alloc] initWithString:redpacket.text];
        }
    }
    string.color = WXTransferMsgStateTextColor;
    string.font = WXTransferMsgStateTextFont;
    self.stateLabelModel.content = string.copy;
    self.stateLabelModel.frame = CGRectMake(CGRectGetMinX(self.textLabelModel.frame), CGRectGetMaxY(self.iconViewModel.frame) - WXTransferMsgStateTextFont.pointSize, CGRectGetWidth(self.textLabelModel.frame), WXTransferMsgStateTextFont.pointSize);
    /// 微信转账
    string = [[NSMutableAttributedString alloc] initWithString:redpacket.type];
    string.font = WXTransferMsgDetailTextFont;
    string.color = WXTransferMsgDetailTextColor;
    self.detailLabelModel.content = string.copy;
    size = [string sizeOfLimitWidth:200.f];
    self.detailLabelModel.frame = CGRectMake(self.iconViewModel.frame.origin.x, MEAN(self.imageViewModel.frame.size.height*(1.f - WXTransferBackgroundRatio) - size.height) + self.imageViewModel.frame.size.height*WXTransferBackgroundRatio, size.width, size.height);
}

#pragma mark - Overwrite
- (BOOL)update {
    /// 到这里一般是转账状态改变 未领取->领取
    if ([super update]) {
        [self layoutSubviews];
        return YES;
    }
    return NO;
}

#pragma mark - Getter
- (WXExtendViewModel *)iconViewModel {
    if (!_iconViewModel) {
        _iconViewModel = [WXExtendViewModel new];
    }
    return _iconViewModel;
}

- (WXExtendViewModel *)stateLabelModel {
    if (!_stateLabelModel) {
        _stateLabelModel = [WXExtendViewModel new];
    }
    return _stateLabelModel;
}

@end
