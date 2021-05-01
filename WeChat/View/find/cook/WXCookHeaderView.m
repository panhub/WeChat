//
//  WXCookHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/8/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookHeaderView.h"

@interface WXCookHeaderView ()

@end

@implementation WXCookHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorWithSingleRGB(51.f);
        SDCycleScrollView *scrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0.f, 0.f, self.width_mn, MN_SCREEN_HEIGHT/3.f)
                                                                           delegate:nil
                                                                   placeholderImage:nil];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.runLoopMode = NSDefaultRunLoopMode;
        scrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        scrollView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        scrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        scrollView.autoScrollTimeInterval = 4.f;
        scrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        scrollView.currentPageDotColor = THEME_COLOR;
        scrollView.pageDotColor = [UIColor whiteColor];
        scrollView.localizationImageNamesGroup = @[UIImageNamed(@"cook_banner-1"), UIImageNamed(@"cook_banner-2"), UIImageNamed(@"cook_banner-3"), UIImageNamed(@"cook_banner-4"), UIImageNamed(@"cook_banner-5")];
        [self addSubview:scrollView];
        self.height_mn = scrollView.bottom_mn;
    }
    return self;
}

@end
