//
//  WXMomentLikedViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentLikedViewModel.h"
#import "WXTimeline.h"

@interface WXMomentLikedViewModel ()
@property (nonatomic, strong) WXMoment *moment;
@end

@implementation WXMomentLikedViewModel
@synthesize content = _content;

- (instancetype)initWithMoment:(WXMoment *)moment {
    if (self = [super init]) {
        self.moment = moment;
        self.type = WXMomentEventTypeLiked;
        [self updateLayout];
    }
    return self;
}

- (void)updateLayout {
    
    UIFont *font = WXMomentLikedTextFont;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
    [self.moment.likes enumerateObjectsUsingBlock:^(WXLike * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [[[WechatHelper helper] userForUid:obj.uid] name];
        if (name.length <= 0) return;
        NSString *string = [NSString stringWithFormat:@"%@%@", (content.length ? @", " : @""), name];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:font.pointSize] range:string.rangeOfAll];
        [attributedString addAttribute:NSForegroundColorAttributeName value:UIColor.darkTextColor range:string.rangeOfAll];
        [attributedString addAttribute:NSFontAttributeName value:font range:[string rangeOfString:name]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:WXMomentLikedTextColor range:[string rangeOfString:name]];
        [content appendAttributedString:attributedString];
    }];
    
    if (self.content.length > 2) [self.content deleteCharactersInRange:NSMakeRange(2, self.content.length - 2)];
    [self.content appendAttributedString:content];
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineSpacing = 1.f;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [self.content addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:self.content.rangeOfAll];
    
    CGSize contentSize = [self.content sizeOfLimitWidth:WXMomentContentWidth - WXMomentLikeLeftOrRightMargin*2.f];
    self.contentFrame = CGRectMake(WXMomentLikeLeftOrRightMargin, WXMomentLikeTopOrBottomMargin, contentSize.width, contentSize.height);
    self.height = contentSize.height + WXMomentLikeTopOrBottomMargin*2.f;
}

- (NSMutableAttributedString *)content {
    if (!_content) {
        UIFont *font = WXMomentLikedTextFont;
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageWithCGImage:[[UIImage imageNamed:@"wx_moment_liked"] CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        attachment.bounds = CGRectMake(0.f, font.descender, font.lineHeight, font.lineHeight);
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [content appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [content addAttribute:NSFontAttributeName value:font range:content.rangeOfAll];
        _content = content;
    }
    return _content;
}

- (BOOL)isHiddenDivider {
    return self.moment.comments.count <= 0;
}

@end
