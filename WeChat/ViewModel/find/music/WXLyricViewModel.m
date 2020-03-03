//
//  WXLyricViewModel.m
//  MNChat
//
//  Created by Vincent on 2020/2/7.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXLyricViewModel.h"

const CGFloat WXMusicLyricHorMargin = 30.f;
const CGFloat WXMusicLyricVerMargin = 7.f;

#define WXMusicPlayerLyricTextColor  (WXPreference.preference.playStyle == WXMusicPlayStyleDark ? R_G_B(248.f, 248.f, 255.f) : [UIColor.darkTextColor colorWithAlphaComponent:.8f])

@interface WXLyricViewModel ()
@property (nonatomic) float lineRatio;
@property (nonatomic) float progress;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGRect contentRect;
@property (nonatomic, copy) NSAttributedString *content;
@end

@implementation WXLyricViewModel
- (instancetype)initWithLyric:(WXLyric *)lyric {
    if (self = [super init]) {
        self.lyric = lyric;
        [self updateContent];
        [self updateProgressWithPlayTimeInterval:0.f];
    }
    return self;
}

- (void)updateContent {
    if (self.lyric.content.length <= 0) {
        self.content = nil;
        self.rowHeight = 0.f;
        self.contentRect = CGRectZero;
        return;
    }
    UIFont *font = UIFontRegular(17.f);
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineSpacing = 1.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributedString = self.lyric.content.attributedString.mutableCopy;
    [attributedString addAttribute:NSForegroundColorAttributeName value:WXMusicPlayerLyricTextColor range:attributedString.rangeOfAll];
    [attributedString addAttribute:NSFontAttributeName value:font range:attributedString.rangeOfAll];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedString.rangeOfAll];
    CGFloat maxWidth = UIScreenWidth() - WXMusicLyricHorMargin*2.f;
    CGSize contentSize = [attributedString sizeOfLimitWidth:maxWidth];
    self.contentRect = CGRectMake(WXMusicLyricHorMargin, WXMusicLyricVerMargin, maxWidth, contentSize.height);
    self.rowHeight = contentSize.height + WXMusicLyricVerMargin*2.f;
    self.content = attributedString;
    if (contentSize.height >= font.pointSize*2.f) {
        CGSize size = [NSString getStringSize:self.lyric.content font:font];
        self.lineRatio = MIN(1.f, contentSize.width/size.width);
    } else {
        self.lineRatio = 1.f;
    }
}

- (void)updateProgressWithPlayTimeInterval:(NSTimeInterval)timeInterval {
    if (self.lyric.begin <= timeInterval && self.lyric.end >= timeInterval) {
        self.progress = (timeInterval - self.lyric.begin)/(self.lyric.end - self.lyric.begin);
    } else {
        self.progress = 0.f;
    }
}

@end
