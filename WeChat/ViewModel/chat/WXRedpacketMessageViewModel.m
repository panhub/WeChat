//
//  WXRedpacketMessageViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketMessageViewModel.h"
#import "WXRedpacket.h"

@implementation WXRedpacketMessageViewModel
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
    /// 红包图片
    image = [UIImage imageNamed:(redpacket.isOpen ? @"wx_redpacket_draw_icon" : @"wx_redpacket_icon")];
    size = CGSizeMultiplyToWidth(image.size, WXRedpacketMsgIconWidth);
    self.iconViewModel.content = image;
    if (self.message.isMine) {
        self.iconViewModel.frame = CGRectMake(WXRedpacketMsgContentLeftMargin, MEAN(self.imageViewModel.frame.size.height*WXRedpacketBackgroundRatio - size.height), size.width, size.height);
    } else {
        self.iconViewModel.frame = CGRectMake(WXRedpacketMsgContentRightMargin, MEAN(self.imageViewModel.frame.size.height*WXRedpacketBackgroundRatio - size.height), size.width, size.height);
    }
    /// 标题
    UIFont *titleFont = redpacket.isOpen ? WXRedpacketMsgTitleTextFont2 : WXRedpacketMsgTitleTextFont1;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:redpacket.text];
    string.color = WXRedpacketMsgTitleTextColor;
    string.font = titleFont;
    self.textLabelModel.content = string.copy;
    if (redpacket.isOpen) {
        self.textLabelModel.frame = CGRectMake(CGRectGetMaxX(self.iconViewModel.frame) + WXRedpacketMsgIconTextMargin, CGRectGetMinY(self.iconViewModel.frame), self.imageViewModel.frame.size.width - self.iconViewModel.frame.size.width - WXRedpacketMsgIconTextMargin - WXRedpacketMsgContentLeftMargin - WXRedpacketMsgContentRightMargin, titleFont.pointSize);
        string = [[NSMutableAttributedString alloc] initWithString:(redpacket.isMine ? @"已被领完" : @"已领取")];
        string.color = WXRedpacketMsgStateTextColor;
        string.font = WXRedpacketMsgStateTextFont;
        self.stateLabelModel.content = string.copy;
        self.stateLabelModel.frame = CGRectMake(CGRectGetMinX(self.textLabelModel.frame), CGRectGetMaxY(self.iconViewModel.frame) - WXRedpacketMsgStateTextFont.pointSize, CGRectGetWidth(self.textLabelModel.frame), WXRedpacketMsgStateTextFont.pointSize);
    } else {
        self.textLabelModel.frame = CGRectMake(CGRectGetMaxX(self.iconViewModel.frame) + WXRedpacketMsgIconTextMargin, MEAN(self.imageViewModel.frame.size.height*WXRedpacketBackgroundRatio - titleFont.pointSize), self.imageViewModel.frame.size.width - self.iconViewModel.frame.size.width - WXRedpacketMsgIconTextMargin - WXRedpacketMsgContentLeftMargin - WXRedpacketMsgContentRightMargin, titleFont.pointSize);
        self.stateLabelModel.frame = CGRectZero;
        self.stateLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
    }
    /// 微信红包
    string = [[NSMutableAttributedString alloc] initWithString:redpacket.type];
    string.font = WXRedpacketMsgDetailTextFont;
    string.color = WXRedpacketMsgDetailTextColor;
    self.detailLabelModel.content = string.copy;
    size = [string sizeOfLimitWidth:200.f];
    self.detailLabelModel.frame = CGRectMake(self.iconViewModel.frame.origin.x, MEAN(self.imageViewModel.frame.size.height*(1.f - WXRedpacketBackgroundRatio) - size.height) + self.imageViewModel.frame.size.height*WXRedpacketBackgroundRatio, size.width, size.height);
    /// 描述
    if (redpacket.isOpen) {
        NSString *desc = redpacket.isMine ? [redpacket.toUser.name stringByAppendingString:@"领取了你的红包"] : [NSString stringWithFormat:@"你领取了%@的红包", redpacket.fromUser.name];
        string = [[NSMutableAttributedString alloc] initWithString:desc];
        string.font = WXRedpacketMsgDescTextFont;
        string.color = WXRedpacketMsgDescTextColor;
        [string setColor:WXRedpacketMsgDescTextHighlightColor range:[desc rangeOfString:@"红包"]];
        [string insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
        UIFont *font = [UIFont systemFontOfSize:15.f];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageWithCGImage:UIImageNamed(@"wx_redpacket_item").CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        attachment.bounds = CGRectMake(0.f, font.descender, font.lineHeight, font.lineHeight);
        [string insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachment] atIndex:0];
        string.alignment = NSTextAlignmentCenter;
        self.descLabelModel.content = string.copy;
        size = [string sizeOfLimitWidth:self.imageViewModel.frame.size.width];
        self.descLabelModel.frame = CGRectMake(self.imageViewModel.frame.origin.x, CGRectGetMaxY(self.imageViewModel.frame) + WXMsgContentBottomMargin, CGRectGetWidth(self.imageViewModel.frame), size.height);
    } else {
        self.descLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
        self.descLabelModel.frame = self.imageViewModel.frame;
    }
}

#pragma mark - Overwrite
- (BOOL)update {
    /// 到这里一般是红包状态改变 未领取->领取
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

- (WXExtendViewModel *)descLabelModel {
    if (!_descLabelModel) {
        _descLabelModel = [WXExtendViewModel new];
    }
    return _descLabelModel;
}

- (WXExtendViewModel *)stateLabelModel {
    if (!_stateLabelModel) {
        _stateLabelModel = [WXExtendViewModel new];
    }
    return _stateLabelModel;
}

- (CGFloat)height {
    return CGRectGetMaxY(self.descLabelModel.frame) + WXMsgContentBottomMargin;
}

@end
