//
//  SETextView.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SETextView.h"
#import "UIView+SEFrame.h"

@interface SETextView ()
@property (nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation SETextView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame textContainer:nil];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self displayPlaceholderIfNeeded];
    self.placeholderLabel.frame = [self placeholderFrame];
    [self sendSubviewToBack:self.placeholderLabel];
}

#pragma mark - UITextViewTextDidChangeNotification
- (void)textDidChangeNotification:(NSNotification *)notify {
    if (notify.object != self) return;
    [self displayPlaceholderIfNeeded];
}

#pragma mark - 显示/隐藏占位文字
- (void)displayPlaceholderIfNeeded {
    self.placeholderLabel.hidden = (self.text.length > 0 || self.placeholder.length <= 0);
}

#pragma mark - Setter
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = font;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self displayPlaceholderIfNeeded];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText.length > 0 && self.attributes.count > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        [attributedString addAttributes:self.attributes range:NSMakeRange(0, attributedString.length)];
        attributedText = [attributedString copy];
    }
    [super setAttributedText:attributedText];
    [self displayPlaceholderIfNeeded];
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.placeholderLabel.text = placeholder;
    [self displayPlaceholderIfNeeded];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    [self setNeedsLayout];
}

#pragma mark - Getter
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        UILabel *placeholderLabel = [[UILabel alloc] init];
        placeholderLabel.hidden = YES;
        placeholderLabel.font = self.font;
        placeholderLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:.7f];
        placeholderLabel.textAlignment = NSTextAlignmentLeft;
        placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:placeholderLabel];
        _placeholderLabel = placeholderLabel;
    }
    return _placeholderLabel;
}

- (NSString *)placeholder {
    return self.placeholderLabel.text;
}

- (UIColor *)placeholderColor {
    return self.placeholderLabel.textColor;
}

#pragma mark - PlaceholderLabel Frame
- (CGRect)placeholderFrame {
    UIEdgeInsets contentInset = self.contentInset;
    UIEdgeInsets textContainerInset = self.textContainerInset;
    CGRect frame = [self caretRectForPosition:self.beginningOfDocument];
    frame.size.width = self.bounds.size.width - contentInset.left - contentInset.right - frame.origin.x - textContainerInset.right;
    frame.size.width = MAX(frame.size.width, 0.f);
    return frame;
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}

@end
