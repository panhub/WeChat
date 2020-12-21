//
//  WXRedpacketTextView.m
//  MNChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketTextView.h"

@interface WXRedpacketTextView () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextView *textView;
@end
@implementation WXRedpacketTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.f;
        self.clipsToBounds = YES;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 10.f, self.width_mn - 70.f, self.height_mn - 20.f)];
        textView.delegate = self;
        textView.tintColor = THEME_COLOR;
        textView.font = [UIFont systemFontOfSize:16.f];
        textView.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.8f];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textView.showsVerticalScrollIndicator = NO;
        textView.showsHorizontalScrollIndicator = NO;
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        textView.keyboardType = UIKeyboardTypeDefault;
        textView.returnKeyType = UIReturnKeyDone;
        textView.backgroundColor = [UIColor whiteColor];
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.textContainer.lineFragmentPadding = 0.f;
        [self addSubview:textView];
        self.textView = textView;
        
        UILabel *placeholderLabel = [UILabel labelWithFrame:CGRectMake(textView.left_mn, MEAN(self.height_mn - 16.f), textView.width_mn, 16.f)
                                                       text:@"恭喜发财, 大吉大利"
                                                  textColor:UIColorWithAlpha([UIColor darkTextColor], .35f)
                                                       font:UIFontRegular(16.f)];
        [self addSubview:placeholderLabel];
        self.placeholderLabel = placeholderLabel;
        
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(MEAN(self.width_mn - textView.right_mn - 30.f) + textView.right_mn, MEAN(self.height_mn - 30.f), 30.f, 30.f)
                                               image:UIImageNamed(@"wx_chat_add_expression")
                                               title:nil
                                          titleColor:nil
                                                titleFont:nil];
        [self addSubview:button];
    }
    return self;
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeholderLabel.hidden = YES;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return range.location + text.length <= 25;
}

#pragma mark - Getter
- (NSString *)text {
    if (self.textView.text.length > 0) return self.textView.text;
    return self.placeholderLabel.text;
}

@end
