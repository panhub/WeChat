//
//  WXMyMomentViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyMomentViewModel.h"
#import "WXMoment.h"
#import "WXMyMoment.h"
#import "WXLocation.h"
#import "WXTimeline.h"

@interface WXMyMomentViewModel ()

@end

@implementation WXMyMomentViewModel

- (instancetype)initWithMoment:(WXMoment *)moment {
    if (self = [super init]) {
        self.moment = moment;
        NSArray <NSString *>*components = [[NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy-M-d"] componentsSeparatedByString:@"-"];
        self.year = components.firstObject;
        self.month = components[1];
        self.day = components.lastObject;
    }
    return self;
}

- (void)layoutSubviews {
    
    // 日期
    NSArray <NSString *>*components = [[NSDate stringValueWithTimestamp:NSDate.timestamps format:@"yyyy-M-d"] componentsSeparatedByString:@"-"];
    NSString *year = components.firstObject;
    NSString *month = components[1];
    NSString *day = components.lastObject;
    
    
    NSMutableAttributedString *dateAttributedString;
    if (self.year.integerValue == year.integerValue && self.month.integerValue == month.integerValue && self.day.integerValue == day.integerValue) {
        // 今天
        NSString *date = @"今天";
        dateAttributedString = [[NSMutableAttributedString alloc] initWithString:date];
        [dateAttributedString addAttribute:NSFontAttributeName value:WXMyMomentTodayFont range:date.rangeOfAll];
        [dateAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentTodayTextColor range:date.rangeOfAll];
    } else {
        NSDateComponents *components = [NSDate dateComponentSince:self.moment.timestamp];
        if (components.year == 0 && components.month == 0 && components.day == 1) {
            // 昨天
            NSString *date = @"昨天";
            dateAttributedString = [[NSMutableAttributedString alloc] initWithString:date];
            [dateAttributedString addAttribute:NSFontAttributeName value:WXMyMomentTodayFont range:date.rangeOfAll];
            [dateAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentTodayTextColor range:date.rangeOfAll];
        } else {
            // 具体日期
            month = [self.month stringByAppendingString:@"月"];
            NSString *date = [self.day stringByAppendingString:month];
            dateAttributedString = [[NSMutableAttributedString alloc] initWithString:date];
            [dateAttributedString addAttribute:NSFontAttributeName value:WXMyMomentDayFont range:[date rangeOfString:self.day]];
            [dateAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentDayTextColor range:[date rangeOfString:self.day]];
            [dateAttributedString addAttribute:NSFontAttributeName value:WXMyMomentMonthFont range:[date rangeOfString:month]];
            [dateAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentMonthTextColor range:[date rangeOfString:month]];
        }
    }
    
    if (!self.isFirst) dateAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    CGSize dateSize = [dateAttributedString sizeOfLimitWidth:MN_SCREEN_MIN];
    
    CGRect dateRect = CGRectZero;
    dateRect.origin = CGPointMake(WXMyMomentLeftMargin, WXMyMomentTopMargin);
    dateRect.size = CGSizeMake(ceil(dateSize.width), ceil(dateSize.height));
    WXExtendViewModel *dateViewModel = WXExtendViewModel.new;
    dateViewModel.frame = dateRect;
    dateViewModel.content = dateAttributedString.copy;
    self.dateViewModel = dateViewModel;
    
    // 位置
    NSString *location = self.moment.location.locationValue.debugDescription;
    if (location.length <= 0 || !self.isFirst) location = @"";
    NSMutableAttributedString *locationAttributedString = [[NSMutableAttributedString alloc] initWithString:location];
    [locationAttributedString addAttribute:NSFontAttributeName value:WXMyMomentLocationFont range:location.rangeOfAll];
    [locationAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentLocationTextColor range:location.rangeOfAll];
    
    CGSize locationSize = [locationAttributedString sizeOfLimitWidth:(WXMyMomentPictureLeftMargin - WXMyMomentLeftMargin - WXMyMomentDatePictureInterval)];
    locationSize.height = MIN(locationSize.height, 35.f);
    
    CGRect locationRect = CGRectZero;
    locationRect.origin = CGPointMake(WXMyMomentLeftMargin, CGRectGetMaxY(dateViewModel.frame) + (locationRect.size.height > 0.f ? WXMyMomentDateLocationInterval : 0.f));
    locationRect.size = CGSizeMake(ceil(locationSize.width), ceil(locationSize.height));
    WXExtendViewModel *locationViewModel = WXExtendViewModel.new;
    locationViewModel.frame = locationRect;
    locationViewModel.content = locationAttributedString.copy;
    self.locationViewModel = locationViewModel;
    
    // 图片
    CGRect pictureRect = CGRectZero;
    pictureRect.origin = CGPointMake(WXMyMomentPictureLeftMargin, 0.f);
    pictureRect.size = self.moment.profiles.count ? CGSizeMake(WXMyMomentPictureWH, WXMyMomentPictureWH) : CGSizeZero;
    WXExtendViewModel *pictureViewModel = WXExtendViewModel.new;
    pictureViewModel.frame = pictureRect;
    pictureViewModel.content = self.moment.profiles.copy;
    self.pictureViewModel = pictureViewModel;
    
    NSString *content = self.moment.content ? : @"";
    
    CGFloat hm = pictureRect.size.width <= 0.f ? 5.f : 0.f;
    CGFloat vm = (pictureRect.size.width <= 0.f && content.length) ? 2.5f : 0.f;
    CGFloat max = MN_SCREEN_MIN - CGRectGetMaxX(pictureRect) - (pictureRect.size.width > 0.f ? WXMyMomentPictureContentInterval : 0.f) - WXMyMomentRightMargin - hm*2.f;
    
    // 内容尺寸
    NSMutableAttributedString *contentAttributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [contentAttributedString matchingEmojiWithFont:WXMyMomentContentFont];
    [contentAttributedString addAttribute:NSFontAttributeName value:WXMyMomentContentFont range:contentAttributedString.rangeOfAll];
    [contentAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentContentTextColor range:contentAttributedString.rangeOfAll];
    CGSize contentSize = [contentAttributedString sizeOfLimitWidth:max];
    contentSize.width = max;
    contentSize.height = MIN(ceil(contentSize.height) + 3.f, 60.f);
    
    // 内容背景
    CGRect backgroundRect = CGRectZero;
    backgroundRect.origin.x = CGRectGetMaxX(pictureRect) + (pictureRect.size.width > 0.f ? WXMyMomentPictureContentInterval : 0.f);
    backgroundRect.size.width = MN_SCREEN_MIN - backgroundRect.origin.x - WXMyMomentRightMargin;
    backgroundRect.size.height = ceil(contentSize.height) + vm*2.f;
    WXExtendViewModel *backgroundViewModel = WXExtendViewModel.new;
    backgroundViewModel.frame = backgroundRect;
    backgroundViewModel.content = pictureRect.size.width > 0.f ? UIColor.whiteColor : WXMomentCommentViewBackgroundColor;
    self.backgroundViewModel = backgroundViewModel;
    
    // 内容视图模型
    CGRect contentRect = CGRectZero;
    contentRect.origin = CGPointMake(hm, vm);
    contentRect.size = CGSizeMake(ceil(contentSize.width), ceil(contentSize.height));
    WXExtendViewModel *contentViewModel = WXExtendViewModel.new;
    contentViewModel.frame = contentRect;
    contentViewModel.content = contentAttributedString.copy;
    self.contentViewModel = contentViewModel;
    
    // 图片张数
    NSString *number = self.moment.profiles.count > 1 ? [NSString stringWithFormat:@"共%@张", @(self.moment.profiles.count).stringValue] : @"";
    NSMutableAttributedString *numberAttributedString = [[NSMutableAttributedString alloc] initWithString:number];
    [numberAttributedString addAttribute:NSFontAttributeName value:WXMyMomentNumberFont range:number.rangeOfAll];
    [numberAttributedString addAttribute:NSForegroundColorAttributeName value:WXMyMomentNumberTextColor range:number.rangeOfAll];
    CGSize numberSize = [numberAttributedString sizeOfLimitWidth:MN_SCREEN_MIN];
    CGRect numberRect = CGRectZero;
    numberRect.origin.x = CGRectGetMinX(backgroundRect);
    numberRect.origin.y = CGRectGetMaxY(pictureRect) - ceil(numberSize.height) - 1.f;
    numberRect.size = CGSizeMake(ceil(numberSize.width), ceil(numberSize.height));
    WXExtendViewModel *numberViewModel = WXExtendViewModel.new;
    numberViewModel.frame = numberRect;
    numberViewModel.content = numberAttributedString.copy;
    self.numberViewModel = numberViewModel;
    
    // 分享的链接
    CGRect webRect = CGRectZero;
    webRect.origin.x = CGRectGetMinX(pictureRect);
    webRect.origin.y = CGRectGetMaxY(backgroundRect);
    webRect.size.width = MN_SCREEN_MIN - webRect.origin.x - WXMyMomentRightMargin;
    webRect.size.height = self.moment.webpage ? 53.f : 0.f;
    WXExtendViewModel *webViewModel = WXExtendViewModel.new;
    webViewModel.frame = webRect;
    webViewModel.content = self.moment.webpage;
    self.webViewModel = webViewModel;
}

- (CGFloat)rowHeight {
    CGFloat max = MAX(CGRectGetMaxY(self.locationViewModel.frame), CGRectGetMaxY(self.pictureViewModel.frame));
    max = MAX(max, CGRectGetMaxY(self.backgroundViewModel.frame));
    max = MAX(max, CGRectGetMaxY(self.webViewModel.frame));
    return max + (self.isLast ? 27.f : 4.f);
}

@end
