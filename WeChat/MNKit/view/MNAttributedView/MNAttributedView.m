//
//  MNAttributedView.m
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/18.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import "MNAttributedView.h"

@interface MNAttributedView ()<UITextViewDelegate>
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, copy) MNAttributedViewHandler handler;
@end

@implementation MNAttributedView
+ (instancetype)attributedViewWithFrame:(CGRect)frame
                                handler:(MNAttributedViewHandler)handler {
    return [self attributedViewWithFrame:frame attributedText:nil handler:handler];
}

+ (instancetype)attributedViewWithFrame:(CGRect)frame
                                   text:(NSString *)text
                                handler:(MNAttributedViewHandler)handler
{
    MNAttributedView *attributedView = [[MNAttributedView alloc] initWithFrame:frame];
    attributedView.text = text;
    attributedView.handler = handler;
    return attributedView;
}

+ (instancetype)attributedViewWithFrame:(CGRect)frame
                         attributedText:(NSAttributedString *)attributedText
                                handler:(MNAttributedViewHandler)handler {
    MNAttributedView *attributedView = [[MNAttributedView alloc] initWithFrame:frame];
    attributedView.attributedText = attributedText;
    attributedView.handler = handler;
    return attributedView;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds];
    textView.backgroundColor = [UIColor clearColor];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont systemFontOfSize:15.f];
    textView.delegate = self;
    textView.editable = NO;
    //textView.selectable = YES;
    textView.textAlignment = NSTextAlignmentCenter;
    textView.tintColor = [UIColor clearColor];
    textView.contentInset = UIEdgeInsetsZero;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0.f;
    textView.performActions = MNTextViewActionNone;
    [self addSubview:textView];
    self.textView = textView;
}

#pragma mark - UITextViewDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if (self.handler) {
        self.handler(URL, characterRange);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(attributedViewDidInteractWithURL:range:)]) {
        [self.delegate attributedViewDidInteractWithURL:URL range:characterRange];
    }
    return NO;
}
#else
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (self.handler) {
        self.handler(URL, characterRange);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(attributedViewDidInteractWithURL:range:)]) {
        [self.delegate attributedViewDidInteractWithURL:URL range:characterRange];
    }
    return NO;
}
#endif
#pragma clang diagnostic pop

#pragma mark - Setter/Getter
- (void)setText:(NSString *)text {
    if (text.length > 0 && self.attributes.count > 0) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText addAttributes:self.attributes range:NSMakeRange(0, attributedText.length)];
        self.textView.attributedText = [attributedText copy];
    } else {
        self.textView.text = text;
    }
}

- (NSString *)text {
    return self.textView.text;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    self.textView.attributedText = attributedText;
}

- (NSAttributedString *)attributedText {
    return self.textView.attributedText;
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    if (attributes.count <= 0) return;
    _attributes = [attributes copy];
    NSMutableAttributedString *attributedText = self.textView.attributedText.mutableCopy;
    if (attributedText.length <= 0) return;
    [attributedText addAttributes:attributes range:NSMakeRange(0, attributedText.length)];
    self.textView.attributedText = [attributedText copy];
}

- (void)setLinkTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)linkTextAttributes {
    self.textView.linkTextAttributes = linkTextAttributes;
}

- (NSDictionary<NSAttributedStringKey,id> *)linkTextAttributes {
    return self.textView.linkTextAttributes;
}

@end
