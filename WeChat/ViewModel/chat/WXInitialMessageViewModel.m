//
//  WXInitialMessageViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/24.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXInitialMessageViewModel.h"

@implementation WXInitialMessageViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 文字内容
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.message.content];
    string.font = WXInitialMsgTextFont;
    string.color = WXInitialMsgTextColor;
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineSpacing = 3.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    string.paragraphStyle = paragraphStyle;
    self.textLabelModel.content = string.copy;
    
    // 文字部分
    CGRect frame = CGRectZero;
    frame.size = [string sizeOfLimitWidth:MN_SCREEN_MIN - WXMsgAvatarLeftOrRightMargin*2.f];
    frame.origin.x = floor((MN_SCREEN_MIN - frame.size.width)/2.f);
    frame.origin.y = CGRectGetMaxY(self.timeLabelModel.frame);//CGRectGetMinY(self.headButtonModel.frame);
    self.textLabelModel.frame = frame;
    
    // 用于计算高度
    self.imageViewModel.frame = frame;
}

@end
