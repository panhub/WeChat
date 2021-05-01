//
//  WXMessageViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMessageViewModel.h"
#import "WXTextMessageViewModel.h"
#import "WXImageMessageViewModel.h"
#import "WXLocationMessageViewModel.h"
#import "WXWebpageMessageViewModel.h"
#import "WXRedpacketMessageViewModel.h"
#import "WXTransferMessageViewModel.h"
#import "WXVoiceMessageViewModel.h"
#import "WXVideoMessageViewModel.h"
#import "WXCardMessageViewModel.h"

static NSArray <NSString *>*WXMessageClassArray;

@interface WXMessageViewModel ()

@end

@implementation WXMessageViewModel
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WXMessageClassArray = @[@"WXInitialMessageViewModel", @"WXTextMessageViewModel", @"WXImageMessageViewModel", @"WXVoiceMessageViewModel", @"WXTurnMessageViewModel", @"WXVideoMessageViewModel", @"WXLocationMessageViewModel", @"WXWebpageMessageViewModel", @"WXRedpacketMessageViewModel", @"WXTransferMessageViewModel", @"WXCardMessageViewModel", @"WXEmotionMessageViewModel", @"WXCallMessageViewModel", @"WXCallMessageViewModel"];
    });
}

+ (instancetype)viewModelWithMessage:(WXMessage *)message {
    Class cls = NSClassFromString(WXMessageClassArray[message.type]);
    WXMessageViewModel *viewModel = [cls new];
    viewModel.message = message;
    [viewModel layoutSubviews];
    return viewModel;
}

- (instancetype)init {
    if (self = [super init]) {
        self.allowsPlaySound = YES;
    }
    return self;
}

#pragma mark - UI
- (void)layoutSubviews {
    /// 气泡图片
    UIImage *border = self.message.isMine ? [UIImage imageNamed:@"wx_chat_send_border"] : [UIImage imageNamed:@"wx_chat_receive_border"];
    self.borderModel.content = [border stretchableImageWithLeftCapWidth:35.f topCapHeight:35.f];
    /// 时间
    if (self.message.show_time) {
        NSString *time = [WechatHelper msgTimeWithTimestamp:self.message.timestamp];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:time];
        string.font = WXMsgCreatedTimeTextFont;
        string.color = WXMsgCreatedTimeTextColor;
        string.alignment = NSTextAlignmentCenter;
        CGSize size = [string sizeOfLimitWidth:MN_SCREEN_WIDTH];
        self.timeLabelModel.content = string.copy;
        self.timeLabelModel.frame = CGRectMake(0.f, 0.f, MN_SCREEN_WIDTH, size.height + WXMsgContentBottomMargin*4.f);
    } else {
        self.timeLabelModel.frame = CGRectZero;
        self.timeLabelModel.content = [[NSAttributedString alloc] initWithString:@""];
    }
    /// 头像
    self.headButtonModel.content = self.message.user.avatar;
    if (self.message.isMine) {
        self.headButtonModel.frame = CGRectMake(MN_SCREEN_WIDTH - WXMsgAvatarWH - WXMsgAvatarLeftOrRightMargin, CGRectGetMaxY(self.timeLabelModel.frame) + WXMsgContentBottomMargin, WXMsgAvatarWH, WXMsgAvatarWH);
    } else {
        self.headButtonModel.frame = CGRectMake(WXMsgAvatarLeftOrRightMargin, CGRectGetMaxY(self.timeLabelModel.frame) + WXMsgContentBottomMargin, WXMsgAvatarWH, WXMsgAvatarWH);
    }
}

- (BOOL)update {
    return [self.message update];
}

#pragma mark - Getter
- (CGFloat)height {
    return ceil(MAX(CGRectGetMaxY(self.imageViewModel.frame), CGRectGetMaxY(self.headButtonModel.frame)) + WXMsgContentBottomMargin);
}

- (WXExtendViewModel *)headButtonModel {
    if (!_headButtonModel) {
        _headButtonModel = [WXExtendViewModel new];
    }
    return _headButtonModel;
}

- (WXExtendViewModel *)timeLabelModel {
    if (!_timeLabelModel) {
        _timeLabelModel = [WXExtendViewModel new];
    }
    return _timeLabelModel;
}

- (WXExtendViewModel *)textLabelModel {
    if (!_textLabelModel) {
        _textLabelModel = [WXExtendViewModel new];
    }
    return _textLabelModel;
}

- (WXExtendViewModel *)detailLabelModel {
    if (!_detailLabelModel) {
        _detailLabelModel = [WXExtendViewModel new];
    }
    return _detailLabelModel;
}

- (WXExtendViewModel *)imageViewModel {
    if (!_imageViewModel) {
        _imageViewModel = [WXExtendViewModel new];
    }
    return _imageViewModel;
}

- (WXExtendViewModel *)borderModel {
    if (!_borderModel) {
        _borderModel = [WXExtendViewModel new];
    }
    return _borderModel;
}

@end
