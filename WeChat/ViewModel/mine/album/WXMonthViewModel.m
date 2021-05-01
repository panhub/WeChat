//
//  WXMonthViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMonthViewModel.h"
#import "WXAlbum.h"

@interface WXMonthViewModel ()
@property (nonatomic, strong) NSMutableArray <WXProfile *>*pictures;
@property (nonatomic, strong) NSMutableArray <WXExtendViewModel *>*dataSource;
@end

@implementation WXMonthViewModel
- (instancetype)initWithTimestamp:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        
        self.pictures = @[].mutableCopy;
        self.dataSource = @[].mutableCopy;
        
        NSArray <NSString *>*components = [[NSDate stringValueWithTimestamp:timestamp format:@"yyyy-M-d"] componentsSeparatedByString:@"-"];
        self.month = components[1];
        
        NSString *title = [self.month stringByAppendingString:@"月"];
        
        NSArray <NSString *>*dates = [[NSDate stringValueWithTimestamp:NSDate.timestamps format:@"yyyy-M-d"] componentsSeparatedByString:@"-"];
        if ([dates.firstObject isEqualToString:components.firstObject] && [dates[1] isEqualToString:components[1]]) title = @"本月";
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
        [string addAttribute:NSFontAttributeName value:WXAlbumTextFont range:string.rangeOfAll];
        [string addAttribute:NSForegroundColorAttributeName value:WXAlbumTextColor range:string.rangeOfAll];
        
        CGSize size = [string sizeOfLimitWidth:MN_SCREEN_MIN];
        
        WXExtendViewModel *monthViewModel = WXExtendViewModel.new;
        monthViewModel.frame = CGRectMake(WXAlbumMonthLeftMargin, WXAlbumMonthTopMargin, ceil(size.width), ceil(size.height));
        monthViewModel.content = string.copy;
        self.monthViewModel = monthViewModel;
    }
    return self;
}

- (void)layoutSubviews {
    
    // 每个图片的大小
    CGFloat wh = (MN_SCREEN_MIN - WXAlbumPictureLeftMargin - WXAlbumPictureRightMargin - WXAlbumPictureInterval*2.f)/3.f;
    wh = ceil(wh);
    
    [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, wh, wh) offset:UIOffsetMake(WXAlbumPictureInterval, WXAlbumPictureInterval) count:self.pictures.count rows:3 handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
        
        WXProfile *picture = [self.pictures objectAtIndex:idx];
        
        WXExtendViewModel *viewModel = [self viewModelWithIndex:idx];
        viewModel.frame = rect;
        viewModel.content = picture;
    }];
}

- (WXExtendViewModel *)viewModelWithIndex:(NSInteger)index {
    if (index < self.dataSource.count) return [self.dataSource objectAtIndex:index];
    WXExtendViewModel *viewModel = WXExtendViewModel.new;
    [self.dataSource addObject:viewModel];
    return viewModel;
}

- (CGFloat)rowHeight {
    if (self.dataSource.count) {
        return CGRectGetMaxY(self.dataSource.lastObject.frame) + WXAlbumPictureInterval;
    }
    return CGRectGetMaxY(self.monthViewModel.frame);
}

@end
