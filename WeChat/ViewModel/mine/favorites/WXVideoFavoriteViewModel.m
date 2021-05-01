//
//  WXVideoFavoriteViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXVideoFavoriteViewModel.h"

@interface WXVideoFavoriteViewModel ()
@property (nonatomic, strong) WXExtendViewModel *playViewModel;
@end

@implementation WXVideoFavoriteViewModel
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 图片
    self.imageViewModel.content = self.favorite.image;
    self.imageViewModel.frame = CGRectMake(WXFavoriteHorizontalMargin + WXFavoriteSeparatorHeight, WXFavoriteVerticalMargin, WXFavoriteImageMaxWH, WXFavoriteImageMaxWH);
    
    // 播放
    CGRect rect = CGRectZero;
    rect.size = CGSizeMake(WXFavoritePlayWH, WXFavoritePlayWH);
    rect.origin.x = (WXFavoriteImageMaxWH - WXFavoritePlayWH)/2.f;
    rect.origin.y = (WXFavoriteImageMaxWH - WXFavoritePlayWH)/2.f;
    self.playViewModel = WXExtendViewModel.new;
    self.playViewModel.frame = rect;
    
    // 来源
    rect = self.sourceViewModel.frame;
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
