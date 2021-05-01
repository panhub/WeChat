//
//  WXTextFavoriteViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXTextFavoriteViewModel.h"

@implementation WXTextFavoriteViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 标题最大宽度
    CGFloat max = ceil(MN_SCREEN_MIN - WXFavoriteSeparatorHeight*2.f - WXFavoriteHorizontalMargin*2.f);
    
    // 标题
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.favorite.title ? : @""];
    [title matchingEmojiWithFont:WXFavoriteTitleFont];
    title.font = WXFavoriteTitleFont;
    title.color = WXFavoriteTitleColor;
    
    CGRect frame = CGRectZero;
    frame.origin.x = WXFavoriteHorizontalMargin + WXFavoriteSeparatorHeight;
    frame.origin.y = WXFavoriteVerticalMargin;
    frame.size = [title sizeOfLimitWidth:max];
    self.titleViewModel.frame = frame;
    self.titleViewModel.content = title.copy;
    
    // 来源
    CGRect rect = self.sourceViewModel.frame;
    rect.origin.y = CGRectGetMaxY(frame) + WXFavoriteSourceTopInterval;
    self.sourceViewModel.frame = rect;
    
    // 时间
    rect = self.timeViewModel.frame;
    if (self.sourceViewModel.frame.size.height > 0.f) {
        rect.origin.y = floor(CGRectGetMidY(self.sourceViewModel.frame) - rect.size.height/2.f);
    } else {
        rect.origin.y = floor(CGRectGetMinY(self.sourceViewModel.frame));
    }
    self.timeViewModel.frame = rect;
    
    // 标签
    rect = self.labelViewModel.frame;
    rect.origin.y = CGRectGetMidY(self.timeViewModel.frame) - rect.size.height/2.f;
    self.labelViewModel.frame = rect;
}

@end
