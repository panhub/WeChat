//
//  WXVoiceMessageViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/6/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXVoiceMessageViewModel.h"
#import "WXFileModel.h"

@implementation WXVoiceMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    /// 语音
    WXFileModel *model = self.message.fileModel;
    self.imageViewModel.extend = model;
    if (model) {
        NSString *duration = [model.content stringByAppendString:@"''"];
        NSMutableAttributedString *string = duration.attributedString.mutableCopy;
        string.color = WXVoiceMsgDurationTextColor;
        string.font = WXVoiceMsgDurationTextFont;
        string.alignment = NSTextAlignmentRight;
        self.textLabelModel.content = string.copy;
        CGSize size = [string sizeOfLimitHeight:CGFLOAT_MAX];
        CGFloat width = duration.intValue/10.f*15.f + 65.f;
        width = MIN(width, WXMsgContentMaxWidth);
        if (self.message.isMine) {
            self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - width - WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), width, CGRectGetHeight(self.headButtonModel.frame));
            self.voiceViewModel.frame = CGRectMake(self.imageViewModel.frame.size.width - WXVoiceMsgIconWH - WXVoiceMsgIconLeftOrRightMargin, (self.imageViewModel.frame.size.height - WXVoiceMsgIconWH)/2.f, WXVoiceMsgIconWH, WXVoiceMsgIconWH);
            self.textLabelModel.frame = CGRectMake(CGRectGetMinX(self.voiceViewModel.frame) - WXVoiceMsgIconTextMargin - size.width, (self.imageViewModel.frame.size.height - size.height)/2.f, size.width, size.height);
        } else {
            self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), width, CGRectGetHeight(self.headButtonModel.frame));
            self.voiceViewModel.frame = CGRectMake(WXVoiceMsgIconLeftOrRightMargin, (self.imageViewModel.frame.size.height - WXVoiceMsgIconWH)/2.f, WXVoiceMsgIconWH, WXVoiceMsgIconWH);
            self.textLabelModel.frame = CGRectMake(CGRectGetMaxX(self.voiceViewModel.frame) + WXVoiceMsgIconTextMargin, (self.imageViewModel.frame.size.height - size.height)/2.f, size.width, size.height);
        }
        UIImage *image = self.message.isMine ? [UIImage imageNamed:@"wx_voice_send_playing3"] : [UIImage imageNamed:@"wx_voice_receive_playing3"];
        self.voiceViewModel.content = image;
    } else {
        if (self.message.isMine) {
            self.imageViewModel.frame = CGRectMake(CGRectGetMinX(self.headButtonModel.frame) - 100.f - WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), 100.f, CGRectGetHeight(self.headButtonModel.frame));
        } else {
            self.imageViewModel.frame = CGRectMake(CGRectGetMaxX(self.headButtonModel.frame) + WXMsgAvatarContentMinMargin, CGRectGetMinY(self.headButtonModel.frame), 100.f, CGRectGetHeight(self.headButtonModel.frame));
        }
        self.voiceViewModel.frame = CGRectZero;
        self.textLabelModel.frame = CGRectZero;
        self.textLabelModel.content = @"".attributedString;
    }
}

#pragma mark - Getter
- (WXExtendViewModel *)voiceViewModel {
    if (!_voiceViewModel) {
        _voiceViewModel = [WXExtendViewModel new];
    }
    return _voiceViewModel;
}

- (NSArray <UIImage *>*)images {
    if (!_images) {
        if (self.message.isMine) {
            _images = @[@"wx_voice_send_playing1".image, @"wx_voice_send_playing2".image, @"wx_voice_send_playing3".image];
        } else {
            _images = @[@"wx_voice_receive_playing1".image, @"wx_voice_receive_playing2".image, @"wx_voice_receive_playing3".image];
        }
    }
    return _images;
}

@end
