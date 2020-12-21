//
//  WXCardMessageViewModel.m
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXCardMessageViewModel.h"
#import "WXUser.h"

@implementation WXCardMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    // 联系人
    WXUser *user = self.message.fileModel.content;
    self.imageViewModel.extend = user;
    // 头像
    CGRect avatarFrame = CGRectMake((self.message.isMine ? WXCardMsgLeftMargin : WXCardMsgRightMargin), WXCardMsgTopMargin, WXCardMsgAvatarWH, WXCardMsgAvatarWH);
    self.avatarViewModel.frame = avatarFrame;
    self.avatarViewModel.content = user.avatar;
    // 文字高度
    CGSize noteSize = [NSString stringSize:user.notename font:WXCardMsgNotenameTextFont];
    CGSize nickSize = [NSString stringSize:user.nickname font:WXCardMsgNicknameTextFont];
    // 文字间隔
    CGFloat margin = (WXCardMsgAvatarWH - noteSize.height - nickSize.height)/3.f;
    // 备注
    CGRect noteFrame = CGRectMake((self.message.isMine ? WXCardMsgLeftMargin : WXCardMsgRightMargin) + WXCardMsgAvatarWH + WXCardMsgAvatarTextMargin, WXCardMsgTopMargin + margin, noteSize.width, noteSize.height);
    noteFrame.size.width = WXMsgContentMaxWidth() - noteFrame.origin.x - (self.message.isMine ? WXCardMsgRightMargin : WXCardMsgLeftMargin);
    NSMutableAttributedString *noteString = user.notename.attributedString.mutableCopy;
    [noteString addAttribute:NSFontAttributeName value:WXCardMsgNotenameTextFont range:noteString.rangeOfAll];
    [noteString addAttribute:NSForegroundColorAttributeName value:WXCardMsgNotenameTextColor range:noteString.rangeOfAll];
    self.textLabelModel.content = noteString.copy;
    self.textLabelModel.frame = noteFrame;
    // 昵称
    CGRect nickFrame = noteFrame;
    nickFrame.origin.y = CGRectGetMaxY(noteFrame) + margin;
    nickFrame.size.height = nickSize.height;
    NSMutableAttributedString *nickString = user.nickname.attributedString.mutableCopy;
    [nickString addAttribute:NSFontAttributeName value:WXCardMsgNicknameTextFont range:nickString.rangeOfAll];
    [nickString addAttribute:NSForegroundColorAttributeName value:WXCardMsgNicknameTextColor range:nickString.rangeOfAll];
    self.detailLabelModel.content = nickString.copy;
    self.detailLabelModel.frame = nickFrame;
    // 分割线
    CGRect separatorFrame = CGRectMake(avatarFrame.origin.x, CGRectGetMaxY(avatarFrame) + WXCardMsgTopMargin, WXMsgContentMaxWidth() - WXCardMsgLeftMargin - WXCardMsgRightMargin, WXCardMsgSeparatorHeight);
    self.separatorViewModel.frame = separatorFrame;
    // 类型
    CGRect typeFrame = CGRectMake(avatarFrame.origin.x, CGRectGetMaxY(separatorFrame) + WXCardMsgTypeSeparatorMargin, separatorFrame.size.width, WXCardMsgTypeTextFont.pointSize);
    NSMutableAttributedString *typeString = @"个人名片".attributedString.mutableCopy;
    [typeString addAttribute:NSFontAttributeName value:WXCardMsgTypeTextFont range:typeString.rangeOfAll];
    [typeString addAttribute:NSForegroundColorAttributeName value:WXCardMsgTypeTextColor range:typeString.rangeOfAll];
    self.typeLabelModel.content = typeString.copy;
    self.typeLabelModel.frame = typeFrame;
    // 背景
    CGRect cardFrame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - WXMsgContentMaxWidth() - WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), WXMsgContentMaxWidth(), CGRectGetMaxY(typeFrame) + WXCardMsgTypeSeparatorMargin);
    if (self.message.isMine == NO) cardFrame.origin.x = CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin;
    self.imageViewModel.frame = cardFrame;
}

#pragma mark - Getter
- (WXExtendViewModel *)avatarViewModel {
    if (!_avatarViewModel) {
        _avatarViewModel = WXExtendViewModel.new;
    }
    return _avatarViewModel;
}

- (WXExtendViewModel *)separatorViewModel {
    if (!_separatorViewModel) {
        _separatorViewModel = WXExtendViewModel.new;
    }
    return _separatorViewModel;
}

- (WXExtendViewModel *)typeLabelModel {
    if (!_typeLabelModel) {
        _typeLabelModel = WXExtendViewModel.new;
    }
    return _typeLabelModel;
}

@end
