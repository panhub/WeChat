//
//  WXMomentCommentViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentCommentViewModel.h"
#import "WXTimeline.h"

@implementation WXMomentCommentViewModel
@synthesize comment = _comment;

- (instancetype)initWithComment:(WXComment *)comment {
    if (self = [super init]) {
        
        _comment = comment;
        
        self.type = WXMomentEventTypeComment;
        
        self.content = [[NSMutableAttributedString alloc] init];
        
        [self updateLayout];
    }
    return self;
}

- (void)updateLayout {
    
    NSString *from = [[[WechatHelper helper] userForUid:self.comment.from_uid] name];
    
    NSAttributedString *from_name = [[NSAttributedString alloc] initWithString:from attributes:@{NSFontAttributeName:WXMomentCommentNicknameFont, NSForegroundColorAttributeName:WXMomentNicknameTextColor}];
    [self.content appendAttributedString:from_name];
    
    NSString *to = [[[WechatHelper helper] userForUid:self.comment.to_uid] name];
    if (to.length > 0) {
        NSAttributedString *reply = [[NSAttributedString alloc] initWithString:@"回复" attributes:@{NSFontAttributeName:WXMomentCommentTextFont, NSForegroundColorAttributeName:WXMomentCommentTextColor}];
        [self.content appendAttributedString:reply];
        
        NSAttributedString *to_name = [[NSAttributedString alloc] initWithString:to attributes:@{NSFontAttributeName:WXMomentCommentNicknameFont, NSForegroundColorAttributeName:WXMomentNicknameTextColor}];
        [self.content appendAttributedString:to_name];
    }
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@",self.comment.content]];
    [content matchingEmojiWithFont:WXMomentCommentTextFont];
    [content addAttribute:NSFontAttributeName value:WXMomentCommentTextFont range:content.rangeOfAll];
    [content addAttribute:NSForegroundColorAttributeName value:WXMomentCommentTextColor range:content.rangeOfAll];
    [self.content appendAttributedString:content];
    
    CGSize contentSize = [self.content sizeOfLimitWidth:WXMomentContentWidth - WXMomentCommentLeftOrRightMargin*2.f];
    self.contentFrame = CGRectMake(WXMomentCommentLeftOrRightMargin, WXMomentCommentTopOrBottomMargin, contentSize.width, contentSize.height);
    self.height = contentSize.height + WXMomentCommentTopOrBottomMargin*2.f;
}

@end
