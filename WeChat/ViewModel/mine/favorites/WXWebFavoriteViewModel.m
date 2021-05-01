//
//  WXWebFavoriteViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXWebFavoriteViewModel.h"

@implementation WXWebFavoriteViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 图片
    self.imageViewModel.content = self.favorite.image ? : [UIImage imageNamed:@"favorite_link"];
    self.imageViewModel.frame = CGRectMake(WXFavoriteHorizontalMargin + WXFavoriteSeparatorHeight, WXFavoriteVerticalMargin, WXFavoriteImageMinWH, WXFavoriteImageMinWH);
    
    // 标题最大宽度
    CGFloat max = ceil(MN_SCREEN_MIN - CGRectGetMaxX(self.imageViewModel.frame) - WXFavoriteTitleLeftInterval- WXFavoriteHorizontalMargin - WXFavoriteSeparatorHeight);
    
    // 标题
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.favorite.title ? : @""];
    title.font = WXFavoriteTitleFont;
    title.color = WXFavoriteTitleColor;
    NSMutableParagraphStyle *style = NSMutableParagraphStyle.new;
    style.lineSpacing = 3.f;
    title.paragraphStyle = style;
    
    CGSize size = [title sizeOfLimitWidth:max];
    size.height = MIN(size.height, WXFavoriteTitleFont.pointSize*2.f + 5.f);
    
    CGRect titleFrame = CGRectZero;
    titleFrame.origin.y = CGRectGetMinY(self.imageViewModel.frame);
    titleFrame.origin.x = CGRectGetMaxX(self.imageViewModel.frame) + WXFavoriteTitleLeftInterval;
    titleFrame.size = size;
    self.titleViewModel.frame = titleFrame;
    self.titleViewModel.content = title.copy;
    
    // 来源
    CGRect rect = self.sourceViewModel.frame;
    rect.origin.y = MAX(CGRectGetMaxY(titleFrame), CGRectGetMaxY(self.imageViewModel.frame)) + WXFavoriteSourceTopInterval;
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
