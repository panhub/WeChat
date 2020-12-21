//
//  WXMomentInputView.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentInputView.h"
#import "WXMomentReplyViewModel.h"
#import "WXMomentViewModel.h"

@interface WXMomentInputView () <UITextViewDelegate, MNEmojiKeyboardDelegate, MNTextViewHandler>
{
    CGFloat WXMomentInputViewNormalHeight;
}
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) MNEmojiTextView *textView;
@property (nonatomic, strong) MNEmojiKeyboard *emojiKeyboard;
@property (nonatomic, strong) WXMomentReplyViewModel *viewModel;
@end

#define WXMomentEmojiKeyboardAnimationDuration  .3f

@implementation WXMomentInputView
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, MN_SCREEN_HEIGHT, MN_SCREEN_WIDTH, 55.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        WXMomentInputViewNormalHeight = frame.size.height;
        
        //UIViewAddBlurEffect(self, UIBlurEffectStyleExtraLight);
        self.backgroundColor = [UIColor colorWithRed:246.f/255.f green:246.f/255.f blue:246.f/255.f alpha:1.f];
        
        UIView *shadowView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, .3f)];
        shadowView.backgroundColor = UIColorShadowColor();
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:shadowView];
        
        CGFloat xMargin = 15.f;
        
        UIButton *keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        keyboardButton.frame = CGRectMake(self.width_mn - xMargin - 30.f, (self.height_mn - 30.f)/2.f, 30.f, 30.f);
        keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [keyboardButton setBackgroundImage:[UIImage imageNamed:@"wx_moment_input_emotion"] forState:UIControlStateNormal];
        [keyboardButton setBackgroundImage:[UIImage imageNamed:@"wx_moment_input_keyboard"] forState:UIControlStateSelected];
        keyboardButton.layer.cornerRadius = keyboardButton.height_mn/2.f;
        keyboardButton.clipsToBounds = YES;
        [keyboardButton addTarget:self action:@selector(emojiButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:keyboardButton];
        self.keyboardButton = keyboardButton;
        
        MNEmojiTextView *textView = [[MNEmojiTextView alloc]initWithFrame:CGRectMake(xMargin, 6.f, keyboardButton.left_mn - xMargin*2.f, self.height_mn - 12.f)];
        textView.delegate = self;
        textView.handler = self;
        textView.expandHeight = 115.f;
        textView.tintColor = THEME_COLOR;
        textView.font = [UIFont systemFontOfSize:17.f];
        textView.showsVerticalScrollIndicator = NO;
        textView.showsHorizontalScrollIndicator = NO;
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        textView.keyboardType = UIKeyboardTypeDefault;
        textView.returnKeyType = UIReturnKeySend;
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.backgroundColor = [UIColor whiteColor];
        textView.layer.cornerRadius = 5.f;
        textView.layer.borderColor = SEPARATOR_COLOR.CGColor;
        textView.layer.borderWidth = .4f;
        textView.clipsToBounds = YES;
        textView.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.9f];
        textView.scrollsToTop = NO;
        textView.enablesReturnKeyAutomatically = YES;
        textView.textContainerInset = UIEdgeInsetsMake((textView.height_mn - textView.font.lineHeight)/2.f, 6.f, (textView.height_mn - textView.font.lineHeight)/2.f, 6.f);
        textView.textContainer.lineFragmentPadding = 0.f;
        if (@available(iOS 11.0, *)) textView.textDragInteraction.enabled = NO;
        [self addSubview:textView];
        self.textView = textView;
        
        /// 监听键盘变化
        [self handEvents];
    }
    return self;
}

- (void)handEvents {
    /// 键盘变化通知
    @weakify(self);
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (!self.userInteractionEnabled) return;
        UIKeyboardWillChangeFrameConvert(notify, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
            if (to.origin.y >= MN_SCREEN_HEIGHT) {
                /// 收起键盘
                [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                    self.top_mn = to.origin.y;
                } completion:nil];
                /// 回调编辑事件
                if (self.endEditingHandler) {
                    self.endEditingHandler(self.viewModel.indexPath, YES);
                }
            } else {
                //弹起 或 改变高度
                [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                    self.bottom_mn = to.origin.y;
                } completion:nil];
                /// 回调编辑事件
                if (self.beginEditingHandler) {
                    self.beginEditingHandler(self.viewModel.indexPath, NO);
                }
            }
        });
    }];
}

#pragma mark - 切换键盘
- (void)emojiButtonTouchUpInside:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.textView.inputView = sender.selected ? self.emojiKeyboard : nil;
    [self.textView reloadInputViews];
    if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textView:(MNEmojiTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        [textView resignFirstResponder];
        self.viewModel.content = textView.emoji_plainText;
        [self.viewModel.viewModel replyMomentWithModel:self.viewModel];
        return NO;
    }
    return YES;
}

#pragma mark - MNTextViewHandler
- (void)textView:(MNTextView *)textView fixedHeightSubscribeNext:(CGFloat)change {
    [UIView animateWithDuration:.3f animations:^{
        self.top_mn -= change;
        self.height_mn += change;
    } completion:nil];
    if (self.beginEditingHandler) {
        self.beginEditingHandler(self.viewModel.indexPath, YES);
    }
}

#pragma mark - MNEmojiKeyboardDelegate
- (void)emojiKeyboard:(MNEmojiKeyboard *)emojiKeyboard emojiButtonTouchUpInside:(MNEmoji *)emoji {
    [_textView inputEmoji:emoji];
}

- (void)emojiKeyboardDeleteButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    [self.textView deleteBackward];
}

- (void)emojiKeyboardReturnButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    [self textView:self.textView shouldChangeTextInRange:self.textView.selectedRange replacementText:@"\n"];
}

#pragma mark - Become/Resign Responder
- (BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textView resignFirstResponder];
}

#pragma mark - 绑定视图模型
- (void)bindViewModel:(WXMomentReplyViewModel *)viewModel {
    self.textView.text = @"";
    self.viewModel = viewModel;
    self.textView.placeholder = viewModel.placeholder;
    self.top_mn = MN_SCREEN_HEIGHT;
    self.height_mn = WXMomentInputViewNormalHeight;
    self.keyboardButton.selected = NO;
    self.textView.inputView = nil;
}

#pragma mark - MNEmojiKeyboard
- (MNEmojiKeyboard *)emojiKeyboard {
    if (!_emojiKeyboard) {
        MNEmojiKeyboard *emojiKeyboard = [MNEmojiKeyboard new];
        emojiKeyboard.delegate = self;
        emojiKeyboard.configuration.allowsUseEmojiPackets = NO;
        emojiKeyboard.configuration.returnKeyType = _textView.returnKeyType;
        _emojiKeyboard = emojiKeyboard;
    }
    return _emojiKeyboard;
}

@end
