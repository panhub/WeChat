//
//  MNTextView.m
//  MNKit
//
//  Created by Vincent on 2018/12/3.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTextView.h"

@interface MNTextView ()
@property (nonatomic) CGFloat normalHeight;
@property (nonatomic, weak) UILabel *placeholderLabel;
@end

@implementation MNTextView
#pragma mark - Instance
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame textContainer:nil];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
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
    if ([_handler respondsToSelector:@selector(textViewTextDidChange:)]) {
        [_handler textViewTextDidChange:self];
    }
}

#pragma mark - UITextViewContentSizeChangeObserve
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        UITextView *textView = (UITextView *)object;
        if (!textView.isFirstResponder) return;
        CGSize oldSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
        CGFloat oldHeight = oldSize.height;
        CGFloat newHeight = newSize.height;
        CGFloat changeHeight = newHeight - oldHeight;
        if (fabs(changeHeight) < .01f) return;
        /// 增加文字时, 要先达到最大尺寸再修改
        if (changeHeight > 0.f && newHeight <= self.height_mn) return;
        /// 删除文字时, 要先把滑动部分用完再修改
        if (changeHeight < 0.f && newHeight >= self.height_mn) return;
        /// 根据情况计算变化高度
        if (newHeight < _normalHeight) {
            changeHeight = _normalHeight - self.height_mn;
        } else if (newHeight > _expandHeight) {
            changeHeight = _expandHeight - self.height_mn;
        } else {
            changeHeight = newHeight - self.height_mn;
        }
        if (fabs(changeHeight) < .01f) return;
        if ([_handler respondsToSelector:@selector(textView:fixedHeightSubscribeNext:)]) {
            [_handler textView:self fixedHeightSubscribeNext:changeHeight];
        }
    }
}

#pragma mark - 修改偏移以适应文字改变
- (void)changeContentOffsetIfNeeded {
    if (self.isFirstResponder) {
        /// 编辑状态下
        CGRect rect = [self caretRectForPosition:self.selectedTextRange.start];
        if (rect.origin.y > (self.contentOffset.y + self.bounds.size.height + self.contentInset.top)) {
            CGPoint offset = self.contentOffset;
            offset.y = CGRectGetMaxY(rect) - self.bounds.size.height - self.contentInset.top;
            [self setContentOffset:offset animated:YES];
        }
    } else {
        /// 非编辑状态
        CGPoint offset = self.contentOffset;
        if (self.contentSize.height > self.bounds.size.height) {
            offset.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
            [self setContentOffset:offset animated:YES];
        }
    }
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

- (void)setExpandHeight:(CGFloat)expandHeight {
    if (expandHeight == _expandHeight || expandHeight <= self.frame.size.height) return;
    _expandHeight = expandHeight;
    if (expandHeight > 0.f) {
        _normalHeight = self.frame.size.height;
        [self addContentSizeObserve];
    } else {
        [self removeContentSizeObserve];
    }
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

#pragma mark - 是否已监听ContentSize
- (BOOL)observedContentSizeChange {
    id info = self.observationInfo;
    NSArray *observances = [info valueForKey:@"_observances"];
    for (id objc in observances) {
        id observer = [objc valueForKeyPath:@"_observer"];
        if (![observer isEqual:self]) continue;
        id property = [objc valueForKeyPath:@"_property"];
        NSString *keyPath = [property valueForKeyPath:@"_keyPath"];
        if ([keyPath isEqualToString:@"contentSize"]) return YES;
    }
    return NO;
}

#pragma mark - 监听ContentSize
- (void)addContentSizeObserve {
    if (![self observedContentSizeChange]) {
        [self addObserver:self
               forKeyPath:@"contentSize"
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:nil];
    }
}

#pragma mark - 删除ContentSize监听
- (void)removeContentSizeObserve {
    if ([self observedContentSizeChange]) {
        [self removeObserver:self forKeyPath:@"contentSize"];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [self removeContentSizeObserve];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}

@end
