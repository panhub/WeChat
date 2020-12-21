//
//  UITextView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/5/21.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UITextView+MNHelper.h"
#import "NSObject+MNSwizzle.h"
#import <objc/runtime.h>

static NSString * MNTextViewActionKey = @"com.mn.textview.perform.actions.key";

@implementation UITextView (MNHelper)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(@"UITextView") swizzleInstanceMethod:@selector(canPerformAction:withSender:) withSelector:@selector(mn_canPerformAction:withSender:)];
    });
}

- (MNTextViewActions)performActions {
    NSNumber *number = objc_getAssociatedObject(self, &MNTextViewActionKey);
    if (number) return ((MNTextViewActions)[number unsignedIntegerValue]);
    return MNTextViewActionAll;
}

- (void)setPerformActions:(MNTextViewActions)performActions {
    objc_setAssociatedObject(self, &MNTextViewActionKey, @(performActions), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mn_canPerformAction:(SEL)action withSender:(id)sender {
    MNTextViewActions type = self.performActions;
    if (type == MNTextViewActionAll) {
        return [self mn_canPerformAction:action withSender:sender];
    } else if (type == MNTextViewActionNone) {
        return NO;
    } else {
        if (action == @selector(paste:)&&(type & MNTextViewActionPaste)) return NO;
        if (action == @selector(select:)&&(type & MNTextViewActionSelect)) return NO;
        if (action == @selector(selectAll:)&&(type & MNTextViewActionSelectAll)) return NO;
        if (action == @selector(cut:)&&(type & MNTextViewActionCut)) return NO;
        if (action == @selector(copy:)&&(type & MNTextViewActionCopy)) return NO;
        if (action == @selector(delete:)&&(type & MNTextViewActionDelete)) return NO;
    }
    return [self mn_canPerformAction:action withSender:sender];
}

- (void)setTextFont:(id)textFont {
    if (!textFont) return;
    if ([textFont isKindOfClass:[UIFont class]]) {
        self.font = (UIFont *)textFont;
    } else if ([textFont isKindOfClass:[NSNumber class]]) {
        self.font = UIFontRegular([textFont floatValue]);
    }
}

- (id)textFont {
    return self.font;
}

+ (UITextView *)textFieldWithFrame:(CGRect)frame
                              font:(id)font
                          delegate:(id<UITextViewDelegate>)delegate
{
    UITextView *textView = [[self alloc] initWithFrame:frame];
    textView.delegate = delegate;
    textView.textFont = font;
    textView.backgroundColor = [UIColor whiteColor];
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDefault;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0.f;
    [textView adjustContentInset];
    return textView;
}

@end
