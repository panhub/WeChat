//
//  WXChatInputView.m
//  MNChat
//
//  Created by Vincent on 2019/3/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatInputView.h"
#import "WXChatMoreInputView.h"
#import "WXChatVoiceInputView.h"

const CGFloat WXChatToolBarNormalHeight = 55.f;

typedef NS_ENUM(NSInteger, WXChatInputType) {
    WXChatInputNormal = 0,
    WXChatInputVoice
};

typedef NS_ENUM(NSInteger, WXChatKeyboardType) {
    WXChatKeyboardSystem = 0,
    WXChatKeyboardEmoji,
    WXChatKeyboardMore
};

@interface WXChatInputView () <UITextViewDelegate, MNTextViewHandler, MNEmojiKeyboardDelegate, WXChatMoreInputDelegate, WXChatVoiceInputViewDelegate>
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) MNEmojiTextView *textView;
@property (nonatomic, strong) WXChatMoreInputView *moreView;
@property (nonatomic, strong) WXChatVoiceInputView *voiceView;
@property (nonatomic, strong) MNEmojiKeyboard *emojiKeyboard;
@property (nonatomic, assign) WXChatInputType inputType;
@property (nonatomic, assign) WXChatKeyboardType keyboardType;
@end

@implementation WXChatInputView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = WXChatToolBarNormalHeight;
    if (self = [super initWithFrame:frame]) {
        self.keyboardType = WXChatKeyboardSystem;
        [self createView];
        [self handEvents];
    }
    return self;
}

- (void)createView {
    
    self.backgroundColor = [UIColor colorWithRed:246.f/255.f green:246.f/255.f blue:246.f/255.f alpha:1.f];
    //[self addSubview:UIBlurEffectCreate(self.bounds, UIBlurEffectStyleExtraLight)];
    
    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, .2f)];
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    separator.image = [UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .15f)];
    separator.clipsToBounds = YES;
    separator.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:separator];
    
    CGFloat interval = 12.f;
    CGFloat size = 28.f;
    CGFloat width = self.width_mn - size*3.f - interval*5.f;
    
    UIButton *voiceButton = [UIButton buttonWithFrame:CGRectMake(interval, MEAN(self.height_mn - size), size, size)
                                                image:UIImageNamed(@"wx_chat_voice")
                                                title:nil
                                           titleColor:nil
                                                 titleFont:nil];
    [voiceButton setBackgroundImage:UIImageNamed(@"wx_chat_keyboard") forState:UIControlStateSelected];
    voiceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [voiceButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceButton];
    self.voiceButton = voiceButton;
    
    WXChatVoiceInputView *voiceView = [[WXChatVoiceInputView alloc] initWithFrame:CGRectMake(voiceButton.right_mn + interval, MEAN(self.height_mn - 40.f), width, 40.f)];
    voiceView.delegate = self;
    voiceView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    voiceView.layer.cornerRadius = 5.f;
    voiceView.clipsToBounds = YES;
    voiceView.hidden = YES;
    [self addSubview:voiceView];
    self.voiceView = voiceView;
    
    MNEmojiTextView *textView = [[MNEmojiTextView alloc] initWithFrame:voiceView.frame];
    textView.delegate = self;
    textView.handler = self;
    textView.expandHeight = 120.f;
    textView.tintColor = THEME_COLOR;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont systemFontOfSize:17.f];
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeySend;
    textView.backgroundColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 5.f;
    textView.clipsToBounds = YES;
    textView.textContainerInset = UIEdgeInsetsMake((textView.height_mn - textView.font.lineHeight)/2.f, 5.f, (textView.height_mn - textView.font.lineHeight)/2.f, 5.f);
    textView.textContainer.lineFragmentPadding = 0.f;
    [self addSubview:textView];
    self.textView = textView;
    
    UIButton *keyboardButton = [UIButton buttonWithFrame:voiceButton.frame
                                                image:UIImageNamed(@"wx_chat_face")
                                                title:nil
                                           titleColor:nil
                                                 titleFont:nil];
    keyboardButton.tag = 1;
    keyboardButton.left_mn = textView.right_mn + interval;
    keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [keyboardButton setBackgroundImage:UIImageNamed(@"wx_chat_keyboard") forState:UIControlStateSelected];
    [keyboardButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:keyboardButton];
    self.keyboardButton = keyboardButton;
    
    UIButton *addButton = [UIButton buttonWithFrame:voiceButton.frame
                                                   image:UIImageNamed(@"wx_chat_add")
                                                   title:nil
                                              titleColor:nil
                                                    titleFont:nil];
    addButton.tag = 2;
    addButton.left_mn = keyboardButton.right_mn + interval;
    addButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [addButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton];
}

- (void)handEvents {
    @weakify(self);
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(NSNotification *not) {
        UIKeyboardWillChangeFrameConvert(not, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
            @strongify(self);
            if (self.keyboardType == WXChatKeyboardMore || !self.userInteractionEnabled) return;
            [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                self.bottom_mn = to.origin.y;
            } completion:^(BOOL finished) {
                if (self.keyboardButton.selected && to.origin.y >= SCREEN_HEIGHT) {
                    self.textView.inputView = nil;
                    self.keyboardButton.selected = NO;
                    self.keyboardType = WXChatKeyboardSystem;
                }
            }];
            if ([self.delegate respondsToSelector:@selector(inputViewDidChangeFrame:animated:)]) {
                [self.delegate inputViewDidChangeFrame:self animated:YES];
            }
        });
    }];
}

#pragma mark - 按钮点击事件
- (void)buttonClicked:(UIButton *)button {
    if (button.tag == 0) {
        self.textView.text = @"";
        [self resignFirstResponder];
        button.selected = !button.selected;
        self.inputType = button.selected ? WXChatInputVoice : WXChatInputNormal;
        if (!button.selected) [self.textView becomeFirstResponder];
    } else if (button.tag == 1) {
        /// 文字&表情
        self.voiceButton.selected = NO;
        self.inputType = WXChatInputNormal;
        button.selected = !button.selected;
        self.keyboardType = button.selected ? WXChatKeyboardEmoji : WXChatKeyboardSystem;
        self.textView.inputView = button.selected ? self.emojiKeyboard : nil;
        [self.textView reloadInputViews];
        if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
    } else {
        /// 添加按钮
        if (self.keyboardType == WXChatKeyboardMore) return;
        self.keyboardType = WXChatKeyboardMore;
        [self.textView resignFirstResponder];
        if (self.keyboardButton.selected) {
            self.keyboardButton.selected = NO;
            self.textView.inputView = nil;
        }
        [self becomeMoreInputWithHandler:nil];
    }
}

#pragma mark - 控制更多视图
- (void)becomeMoreInputWithHandler:(void(^)(BOOL succeed))handler {
    if (self.moreView.top_mn < SCREEN_HEIGHT) {
        if (handler) handler(YES);
        return;
    }
    [UIView animateWithDuration:.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.moreView.bottom_mn = SCREEN_HEIGHT;
        if (self.keyboardType == WXChatKeyboardMore) self.bottom_mn = self.moreView.top_mn;
    } completion:handler];
    if (self.keyboardType == WXChatKeyboardMore) {
        self.voiceButton.selected = NO;
        self.inputType = WXChatInputNormal;
        if ([self.delegate respondsToSelector:@selector(inputViewDidChangeFrame:animated:)]) {
            [self.delegate inputViewDidChangeFrame:self animated:YES];
        }
    }
}

- (void)resignMoreInputWithHandler:(void(^)(BOOL succeed))handler {
    if (self.moreView.top_mn >= SCREEN_HEIGHT) {
        if (handler) handler(YES);
        return;
    }
    [UIView animateWithDuration:.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.moreView.top_mn = SCREEN_HEIGHT;
        if (self.keyboardType == WXChatKeyboardMore) self.bottom_mn = self.moreView.top_mn;
    } completion:handler];
    if (self.keyboardType == WXChatKeyboardMore) {
        self.textView.inputView = nil;
        self.keyboardButton.selected = NO;
        self.keyboardType = WXChatKeyboardSystem;
        if ([self.delegate respondsToSelector:@selector(inputViewDidChangeFrame:animated:)]) {
            [self.delegate inputViewDidChangeFrame:self animated:YES];
        }
    }
}

- (BOOL)resignFirstResponder {
    [self resignMoreInputWithHandler:nil];
    return [_textView resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [_textView isFirstResponder] || self.moreView.top_mn < SCREEN_HEIGHT;
}

#pragma mark - MNEmojiKeyboardDelegate
- (void)emojiKeyboardDeleteButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == NSNotFound || (selectedRange.location + selectedRange.length) == 0) return;
    [self.textView deleteBackward];
}

- (void)emojiKeyboardReturnButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    [self textView:_textView shouldChangeTextInRange:NSRangeZero replacementText:@"\n"];
}

- (void)emojiKeyboard:(MNEmojiKeyboard *)emojiKeyboard emojiButtonTouchUpInside:(MNEmoji *)emoji {
    if (emoji.type == MNEmojiTypeText) {
        [self.textView inputEmoji:emoji];
    } else if ([self.delegate respondsToSelector:@selector(inputViewShouldSendEmotion:)]) {
        [self.delegate inputViewShouldSendEmotion:emoji.image];
    }
}

- (void)emojiKeyboardFavoritesButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    if ([self.delegate respondsToSelector:@selector(inputViewShouldInsertEmojiToFavorites:)]) {
        [self.delegate inputViewShouldInsertEmojiToFavorites:self];
    }
}

- (void)emojiKeyboardPacketButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    if ([self.delegate respondsToSelector:@selector(inputViewShouldAddEmojiPackets:)]) {
        [self.delegate inputViewShouldAddEmojiPackets:self];
    }
}

#pragma mark - 插入表情图片
- (BOOL)insertEmojiToFavorites:(UIImage *)emojiImage {
    return [self.emojiKeyboard insertEmojiToFavorites:emojiImage desc:nil];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.keyboardType = self.keyboardButton.selected ? WXChatKeyboardEmoji : WXChatKeyboardSystem;
    [self resignMoreInputWithHandler:nil];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        NSString *plainText = textView.emoji_plainText;
        textView.text = @"";
        if (plainText.length > 0) {
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendText:)]) {
                [self.delegate inputViewShouldSendText:plainText];
            }
        } else {
            [textView resignFirstResponder];
        }
        return NO;
    }
    return YES;
}

#pragma mark - MNTextViewHandler
- (void)textView:(MNTextView *)textView fixedHeightSubscribeNext:(CGFloat)height {
    [UIView animateWithDuration:.25f animations:^{
        self.height_mn += height;
        self.top_mn -= height;
    }];
    if ([self.delegate respondsToSelector:@selector(inputViewDidChangeFrame:animated:)]) {
        [self.delegate inputViewDidChangeFrame:self animated:YES];
    }
}

#pragma mark - WXChatMoreInputDelegate
- (void)moreInputView:(WXChatMoreInputView *)inputView didSelectButtonAtIndex:(NSInteger)index {
    @weakify(self);
    [self resignMoreInputWithHandler:^(BOOL succeed) {
        @strongify(self);
        if (index == WXChatInputMorePhoto) {
            /// 照片
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendAsset:)]) {
                [self.delegate inputViewShouldSendAsset:self];
            }
        } else if (index == WXChatInputMoreCapture) {
            /// 拍摄
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendCapture:)]) {
                [self.delegate inputViewShouldSendCapture:self];
            }
        } else if (index == WXChatInputMoreCall) {
            /// FaceTime
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendCall:)]) {
                [self.delegate inputViewShouldSendCall:self];
            }
        } else if (index == WXChatInputMoreLocation) {
            /// 位置
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendLocation:)]) {
                [self.delegate inputViewShouldSendLocation:self];
            }
        } else if (index == WXChatInputMoreRedpacket) {
            /// 红包
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendRedpacket:)]) {
                [self.delegate inputViewShouldSendRedpacket:self];
            }
        } else if (index == WXChatInputMoreTransfer) {
            /// 转账
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendTransfer:)]) {
                [self.delegate inputViewShouldSendTransfer:self];
            }
        } else if (index == WXChatInputMoreCard) {
            /// 名片
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendCard:)]) {
                [self.delegate inputViewShouldSendCard:self];
            }
        } else if (index == WXChatInputMoreFavorites) {
            /// 收藏
            if ([self.delegate respondsToSelector:@selector(inputViewShouldSendWebpage:)]) {
                [self.delegate inputViewShouldSendWebpage:self];
            }
        }
    }];
}

#pragma mark - WXChatVoiceInputViewDelegate
- (void)voiceInputViewDidBeginRecording:(WXChatVoiceInputView *)inputView {
    if ([self.delegate respondsToSelector:@selector(inputViewShouldSendVoice:)]) {
        [self.delegate inputViewShouldSendVoice:self];
    }
}

- (void)voiceInputViewDidCancelRecording:(WXChatVoiceInputView *)inputView {
    if ([self.delegate respondsToSelector:@selector(inputViewDidCancelVoice:)]) {
        [self.delegate inputViewDidCancelVoice:self];
    }
}

- (void)voiceInputViewDidEndRecording:(NSString *)voicePath {
    if ([self.delegate respondsToSelector:@selector(inputViewDidSendVoice:)]) {
        [self.delegate inputViewDidSendVoice:voicePath];
    }
}

- (void)voiceInputViewDidFailedRecording:(WXChatVoiceInputView *)inputView {
    if ([self.delegate respondsToSelector:@selector(inputViewDidCancelVoice:)]) {
        [self.delegate inputViewDidCancelVoice:self];
    }
    [self.viewController.view showInfoDialog:@"录音失败"];
}

#pragma mark - Setter
- (void)setInputType:(WXChatInputType)inputType {
    _inputType = inputType;
    self.voiceView.hidden = inputType == WXChatInputNormal;
    self.textView.hidden = !self.voiceView.hidden;
}

#pragma mark - Getter
- (MNEmojiKeyboard *)emojiKeyboard {
    if (!_emojiKeyboard) {
        MNEmojiKeyboard *emojiKeyboard = [MNEmojiKeyboard keyboard];
        emojiKeyboard.delegate = self;
        emojiKeyboard.configuration.returnKeyType = self.textView.returnKeyType;
        _emojiKeyboard = emojiKeyboard;
    }
    return _emojiKeyboard;
}

- (WXChatMoreInputView *)moreView {
    if (!_moreView) {
        WXChatMoreInputView *moreView = [[WXChatMoreInputView alloc] init];
        moreView.delegate = self;
        [self.superview addSubview:moreView];
        _moreView = moreView;
    }
    return _moreView;
}

@end
