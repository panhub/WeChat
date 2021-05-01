//
//  WXImageFavoriteViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXImageFavoriteViewModel.h"

@implementation WXImageFavoriteViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 图片
    self.imageViewModel.content = self.favorite.image;
    self.imageViewModel.frame = CGRectMake(WXFavoriteHorizontalMargin + WXFavoriteSeparatorHeight, WXFavoriteVerticalMargin, WXFavoriteImageMaxWH, WXFavoriteImageMaxWH);
    
    // 来源
    CGRect rect = self.sourceViewModel.frame;
    rect.origin.y = CGRectGetMaxY(self.imageViewModel.frame) + WXFavoriteSourceTopInterval;
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
