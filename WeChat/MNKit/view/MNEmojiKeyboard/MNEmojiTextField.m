//
//  MNEmojiTextField.m
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/13.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import "MNEmojiTextField.h"
#import "UITextView+MNEmojiHelper.h"

@implementation MNEmojiTextField
#pragma mark - Instance
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.font = [UIFont systemFontOfSize:16.f];
        self.textColor = [UIColor darkTextColor];
    }
    return self;
}

#pragma mark - Setter
- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText.length > 0 && self.attributes.count > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        [attributedString addAttributes:self.attributes range:NSMakeRange(0, attributedString.length)];
        attributedText = [attributedString copy];
    }
    [super setAttributedText:attributedText];
}

#pragma mark - 复制/粘贴/剪切
- (void)copy:(id)sender {
    [self hand_copy:sender];
}

- (void)paste:(id)sender {
    [self hand_paste:sender];
}

- (void)cut:(id)sender {
    [self hand_cut:sender];
}

@end
