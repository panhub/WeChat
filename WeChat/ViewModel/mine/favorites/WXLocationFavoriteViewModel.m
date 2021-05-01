//
//  WXLocationFavoriteViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLocationFavoriteViewModel.h"

@implementation WXLocationFavoriteViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 图片
    self.imageViewModel.content = self.favorite.image;
    self.imageViewModel.frame = CGRectMake(WXFavoriteHorizontalMargin + WXFavoriteSeparatorHeight, WXFavoriteVerticalMargin, WXFavoriteImageMinWH, WXFavoriteImageMinWH);
    
    // 标题最大宽度
    CGFloat max = ceil(MN_SCREEN_MIN - CGRectGetMaxX(self.imageViewModel.frame) - WXFavoriteTitleLeftInterval - WXFavoriteHorizontalMargin - WXFavoriteSeparatorHeight);
    
    // 标题
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.favorite.title ? : @""];
    title.font = WXFavoriteTitleFont;
    title.color = WXFavoriteTitleColor;
    
    CGSize size = [NSString stringSize:(self.favorite.title ? : @"") font:WXFavoriteTitleFont];
    size.width = MIN(size.width, max);
    size.height = MAX(size.height, WXFavoriteTitleFont.pointSize);
    
    CGRect titleFrame = CGRectZero;
    titleFrame.origin.y = CGRectGetMinY(self.imageViewModel.frame);
    if (self.favorite.subtitle.length <= 0) titleFrame.origin.y = floor(CGRectGetMidY(self.imageViewModel.frame) - size.height/2.f);
    titleFrame.origin.x = CGRectGetMaxX(self.imageViewModel.frame) + WXFavoriteTitleLeftInterval;
    titleFrame.size = size;
    self.titleViewModel.frame = titleFrame;
    self.titleViewModel.content = title.copy;
    
    // 副标题
    NSMutableAttributedString *subtitle = [[NSMutableAttributedString alloc] initWithString:self.favorite.subtitle ? : @""];
    subtitle.font = WXFavoriteSubTitleFont;
    subtitle.color = WXFavoriteSubTitleColor;
    
    size = [NSString stringSize:(self.favorite.subtitle ? : @"") font:WXFavoriteSubTitleFont];
    size.width = MIN(size.width, max);
    size.height = MAX(size.height, WXFavoriteSubTitleFont.pointSize);
    
    CGRect subtitleFrame = CGRectZero;
    subtitleFrame.origin.x = CGRectGetMinX(self.titleViewModel.frame);
    subtitleFrame.origin.y = CGRectGetMaxY(self.imageViewModel.frame) - 4.f - size.height;
    subtitleFrame.size = size;
    self.subtitleViewModel.frame = subtitleFrame;
    self.subtitleViewModel.content = subtitle.copy;
    
    // 来源
    CGRect rect = self.sourceViewModel.frame;
    rect.origin.y = MAX(CGRectGetMaxY(subtitleFrame), CGRectGetMaxY(self.imageViewModel.frame)) + WXFavoriteSourceTopInterval;
    self.sourceViewModel.frame = rect;
    
    // 时间
    rect = self.timeViewModel.frame;
    if (self.sourceViewModel.frame.size.height > 0.f) {
        rect.origin.y = CGRectGetMidY(self.sourceViewModel.frame) - rect.size.height/2.f;
    } else {
        rect.origin.y = CGRectGetMinY(self.sourceViewModel.frame);
    }
    self.timeViewModel.frame = rect;
    
    // 标签
    rect = self.labelViewModel.frame;
    rect.origin.y = CGRectGetMidY(self.timeViewModel.frame) - rect.size.height/2.f;
    self.labelViewModel.frame = rect;
}

@end
