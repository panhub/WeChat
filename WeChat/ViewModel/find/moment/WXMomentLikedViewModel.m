//
//  WXMomentLikedViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentLikedViewModel.h"

@implementation WXMomentLikedViewModel
@synthesize content = _content;

- (instancetype)initWithMoment:(WXMoment *)moment {
    if (self = [super init]) {
        [self setValue:moment forKey:@"moment"];
        self.type = WXMomentItemTypeLiked;
        [self updateContent];
    }
    return self;
}

- (void)updateContent {
    /// 更新内容
    if (self.content.length > 2) {
        [self.content replaceCharactersInRange:NSMakeRange(2, self.content.length - 2) withAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    }
    NSMutableString *string = @"".mutableCopy;
    [self.moment.likes.copy enumerateObjectsUsingBlock:^(NSString * _Nonnull uid, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [[[WechatHelper helper] userForUid:uid] name];
        if (name.length > 0) {
            [string appendFormat:@"%@, ", name];
        }
    }];
    if (string.length > 2) {
        [string deleteCharactersInRange:NSMakeRange(string.length - 2, 2)];
    }
    [self.content appendAttributedString:[[NSAttributedString alloc] initWithString:string.copy]];
    /// 更新约束
    [self updateLayout];
}

- (void)updateLayout {
    self.content.font = WXMomentLikedTextFont;
    self.content.color = WXMomentNicknameTextColor;
    self.content.lineSpacing = 2.f;
    self.content.alignment = NSTextAlignmentLeft;
    CGSize size = [self.content sizeOfLimitWidth:WXMomentContentWidth() - WXMomentLikeLeftOrRightMargin*2.f];
    self.contentFrame = CGRectMake(WXMomentLikeLeftOrRightMargin, WXMomentLikeTopOrBottomMargin, size.width, size.height);
    self.height = size.height + WXMomentLikeTopOrBottomMargin*2.f;
}

- (NSMutableAttributedString *)content {
    if (!_content) {
        UIFont *font = WXMomentLikedTextFont;
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageWithCGImage:UIImageNamed(@"wx_moment_liked").CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        attachment.bounds = CGRectMake(0.f, font.descender, font.lineHeight, font.lineHeight);
        _content = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [_content appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    return _content;
}

- (BOOL)isHiddenDivider {
    return self.moment.comments.count <= 0;
}

@end
