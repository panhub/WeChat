//
//  WXFavoriteViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXFavoriteViewModel.h"

static NSArray <NSString *>*WXCollectClassPool;

@interface WXFavoriteViewModel ()
@property (nonatomic, strong) WXExtendViewModel *timeViewModel;
@property (nonatomic, strong) WXExtendViewModel *sourceViewModel;
@property (nonatomic, strong) WXExtendViewModel *titleViewModel;
@property (nonatomic, strong) WXExtendViewModel *labelViewModel;
@property (nonatomic, strong) WXExtendViewModel *subtitleViewModel;
@property (nonatomic, strong) WXExtendViewModel *imageViewModel;
@end

@implementation WXFavoriteViewModel
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WXCollectClassPool = @[@"WXWebFavoriteViewModel", @"WXTextFavoriteViewModel", @"WXImageFavoriteViewModel", @"WXVideoFavoriteViewModel", @"WXLocationFavoriteViewModel"];
    });
}

+ (instancetype)viewModelWithFavorite:(WXFavorite *)favorite {
    Class cls = NSClassFromString(WXCollectClassPool[favorite.type]);
    WXFavoriteViewModel *viewModel = [cls new];
    viewModel.favorite = favorite;
    [viewModel layoutSubviews];
    return viewModel;
}

#pragma mark - Getter
- (void)layoutSubviews {
    // 来源
    WXUser *user = [WechatHelper.helper userForUid:self.favorite.uid];
    NSString *name = user ? user.name : @"";
    NSString *string = name.length ? name : self.favorite.source;
    NSMutableAttributedString *source = [[NSMutableAttributedString alloc] initWithString:string ? : @""];
    source.font = WXFavoriteSourceFont;
    source.color = WXFavoriteSourceColor;
    
    CGRect sourceFrame = CGRectZero;
    sourceFrame.origin.x = WXFavoriteHorizontalMargin + WXFavoriteSeparatorHeight;
    sourceFrame.size = [source sizeOfLimitWidth:MN_SCREEN_MIN];
    self.sourceViewModel.frame = sourceFrame;
    self.sourceViewModel.content = source.copy;
    
    // 时间
    NSMutableAttributedString *time = [[NSMutableAttributedString alloc] initWithString:[WechatHelper favoriteTimeWithTimestamp:self.favorite.timestamp]];
    time.font = WXFavoriteTimeFont;
    time.color = WXFavoriteTimeColor;
    
    CGRect timeFrame = CGRectZero;
    timeFrame.origin.x = CGRectGetMaxX(sourceFrame) + (sourceFrame.size.width > 0.f ? WXFavoriteTimeSourceInterval : 0.f);
    timeFrame.size = [time sizeOfLimitWidth:MN_SCREEN_MIN];
    self.timeViewModel.frame = timeFrame;
    self.timeViewModel.content = time.copy;
    
    // 标签
    CGRect labelFrame = CGRectMake(0.f, 0.f, WXFavoriteLabelWH, WXFavoriteLabelWH);
    labelFrame.origin.x = MN_SCREEN_MIN - WXFavoriteSeparatorHeight - WXFavoriteHorizontalMargin - WXFavoriteLabelWH;
    self.labelViewModel.frame = labelFrame;
}

#pragma mark - Getter
- (WXExtendViewModel *)timeViewModel {
    if (!_timeViewModel) {
        _timeViewModel = WXExtendViewModel.new;
    }
    return _timeViewModel;
}

- (WXExtendViewModel *)labelViewModel {
    if (!_labelViewModel) {
        _labelViewModel = WXExtendViewModel.new;
    }
    return _labelViewModel;
}

- (WXExtendViewModel *)sourceViewModel {
    if (!_sourceViewModel) {
        _sourceViewModel = WXExtendViewModel.new;
    }
    return _sourceViewModel;
}

- (WXExtendViewModel *)titleViewModel {
    if (!_titleViewModel) {
        _titleViewModel = WXExtendViewModel.new;
    }
    return _titleViewModel;
}

- (WXExtendViewModel *)subtitleViewModel {
    if (!_subtitleViewModel) {
        _subtitleViewModel = WXExtendViewModel.new;
    }
    return _subtitleViewModel;
}

- (WXExtendViewModel *)imageViewModel {
    if (!_imageViewModel) {
        _imageViewModel = WXExtendViewModel.new;
    }
    return _imageViewModel;
}

- (CGRect)frame {
    return CGRectMake(WXFavoriteSeparatorHeight, 0.f, MN_SCREEN_MIN - WXFavoriteSeparatorHeight*2.f, ceil(CGRectGetMaxY(self.timeViewModel.frame) + WXFavoriteVerticalMargin));
}

@end
