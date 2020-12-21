//
//  WXMomentCommentViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentCommentViewModel.h"

@implementation WXMomentCommentViewModel
@synthesize content = _content;

- (instancetype)initWithComment:(WXMomentComment *)comment {
    if (self = [super init]) {
        [self setValue:comment forKey:@"comment"];
        self.type = WXMomentItemTypeComment;
        
        NSString *from = [[[WechatHelper helper] userForUid:comment.from_uid] name];
        NSStringReplacingEmpty(&from);
        NSAttributedString *from_name = [[NSAttributedString alloc] initWithString:from attributes:@{NSFontAttributeName:WXMomentCommentNicknameFont, NSForegroundColorAttributeName:WXMomentNicknameTextColor}];
        [self.content appendAttributedString:from_name];
        
        NSString *to = [[[WechatHelper helper] userForUid:comment.to_uid] name];
        if (to.length > 0) {
            NSAttributedString *reply = [[NSAttributedString alloc] initWithString:@"回复" attributes:@{NSFontAttributeName:WXMomentCommentTextFont, NSForegroundColorAttributeName:WXMomentCommentTextColor}];
            [self.content appendAttributedString:reply];
            
            NSAttributedString *to_name = [[NSAttributedString alloc] initWithString:to attributes:@{NSFontAttributeName:WXMomentCommentNicknameFont, NSForegroundColorAttributeName:WXMomentNicknameTextColor}];
            [self.content appendAttributedString:to_name];
        }
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@",comment.content]];
        [content matchingEmojiWithFont:WXMomentCommentTextFont];
        [content addAttribute:NSFontAttributeName value:WXMomentCommentTextFont range:content.rangeOfAll];
        [content addAttribute:NSForegroundColorAttributeName value:WXMomentCommentTextColor range:content.rangeOfAll];
        [self.content appendAttributedString:content];
        
        [self updateLayout];
    }
    return self;
}

- (void)updateLayout {
    CGSize size = [self.content sizeOfLimitWidth:WXMomentContentWidth() - WXMomentCommentLeftOrRightMargin*2.f];
    self.contentFrame = CGRectMake(WXMomentCommentLeftOrRightMargin, WXMomentCommentTopOrBottomMargin, size.width, size.height);
    self.height = size.height + WXMomentCommentTopOrBottomMargin*2.f;
}

- (NSMutableAttributedString *)content {
    if (!_content) {
        _content = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    return _content;
}

@end
