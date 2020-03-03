//
//  MNEmojiTextView.m
//  MNKit
//
//  Created by Vincent on 2019/2/8.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiTextView.h"
#import "NSAttributedString+MNEmojiHelper.h"

@implementation MNEmojiTextView
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
