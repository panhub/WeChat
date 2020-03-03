//
//  WXShakeTVController.m
//  MNChat
//
//  Created by Vincent on 2020/2/2.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeTVController.h"

@interface WXShakeTVController ()
@property (nonatomic, strong) MNWebProgressView *progressView;
@end

@implementation WXShakeTVController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"看电视，玩微信摇电视";
    }
    return self;
}

- (void)createView {
    [super createView];
    // 创建视图
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = UIColor.clearColor;
    self.navigationBar.backgroundColor = UIColorWithSingleRGB(237.f);
    
    self.contentView.alpha = 0.f;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:scrollView];
    
    NSArray <NSString *>*imgs = @[@"shake_tv_nomatch_1", @"shake_tv_nomatch_2"];
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:obj]];
        imageView.size_mn = CGSizeMultiplyToWidth(imageView.image.size, scrollView.width_mn);
        imageView.top_mn = scrollView.contentSize.height;
        if (idx == 1) imageView.top_mn -= .2f;
        [scrollView addSubview:imageView];
        scrollView.contentSize = CGSizeMake(scrollView.width_mn, imageView.bottom_mn);
    }];
    
    MNWebProgressView *progressView = [[MNWebProgressView alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn - 2.5f, self.navigationBar.width_mn, 2.5f)];
    progressView.tintColor = THEME_COLOR;
    [self.navigationBar addSubview:progressView];
    self.progressView = progressView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) [self updateProgressIfNeeds];
}

- (void)updateProgressIfNeeds {
    [self.progressView setProgress:(self.progressView.progress + .2f) animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.progressView.progress >= .6f) {
            [self.progressView setProgress:1.f animated:YES];
            [UIView animateWithDuration:.3f animations:^{
                self.contentView.alpha = 1.f;
            }];
        } else {
            [self updateProgressIfNeeds];
        }
    });
}

#pragma mark - Overwrite
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 35.f, 35.f)];
    leftItem.backgroundImage = [UIImage imageNamed:@"wx_common_closeHL"];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    rightItem.touchInset = UIEdgeInsetWith(-5.f);
    rightItem.backgroundImage = [UIImage imageNamed:@"wx_common_more_black"];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    self.contentView.alpha = 0.f;
    self.progressView.progress = .01f;
    [self updateProgressIfNeeds];
}

@end
