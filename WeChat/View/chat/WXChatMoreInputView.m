//
//  WXChatMoreInputView.m
//  MNChat
//
//  Created by Vincent on 2019/3/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatMoreInputView.h"

@implementation WXChatMoreInputView

- (instancetype)init {
    return [self initWithFrame:(CGRect){0.f, MN_SCREEN_HEIGHT, [[MNEmojiKeyboard keyboard] frame].size}];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [MNEmojiKeyboard keyboard].backgroundColor;
        [self createView];
    }
    return self;
}

- (void)createView {
    
    CGFloat x = 20.f;
    CGFloat w = 65.f;
    CGFloat y = (self.height_mn - w*2.f - 30.f - 17.f)/2.f;
    CGFloat interval = (self.width_mn - x*2.f - w*4.f)/3.f;
    NSArray *imgs = @[@"wx_chat_album", @"wx_chat_camera", @"wx_chat_video", @"wx_chat_location", @"wx_chat_redpacket", @"wx_chat_transfer", @"wx_chat_card", @"wx_chat_favorites"];
    NSArray *titles = @[@"照片", @"拍摄", @"视频通话", @"位置", @"红包", @"转账", @"个人名片", @"收藏"];
    [UIView gridLayoutWithInitial:CGRectMake(x, y, w, w) offset:UIOffsetMake(interval, 30.f) count:imgs.count rows:4 handler:^(CGRect rect, NSUInteger idx, BOOL *stop) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = rect;
        button.tag = WXChatInputMorePhoto + idx;
        [button setBackgroundImage:[UIImage imageNamed:imgs[idx]] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = 10.f;
        button.clipsToBounds = YES;
        [button addTarget:self action:@selector(moreInputButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UILabel *label = [UILabel labelWithFrame:CGRectMake(button.left_mn, button.bottom_mn + 5.f, button.width_mn, 12.f)
                                            text:titles[idx]
                                   alignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor darkTextColor], .5f)
                                            font:UIFontRegular(12.f)];
        [self addSubview:label];
    }];
}

- (void)moreInputButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(moreInputView:didSelectButtonAtIndex:)]) {
        [self.delegate moreInputView:self didSelectButtonAtIndex:sender.tag];
    }
}

@end
