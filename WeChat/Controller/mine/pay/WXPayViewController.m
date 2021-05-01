//
//  WXPayViewController.m
//  WeChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPayViewController.h"
#import "WXPayHeaderView.h"
#import "WXWalletViewController.h"

@interface WXPayViewController () <WXPayHeaderViewDelegate>

@end

@implementation WXPayViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"支付";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.rightItemImage = [UIImage imageNamed:@"wx_common_more_black"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = UIColorWithSingleRGB(247.f);
    [self.contentView addSubview:scrollView];
    
    MNAdsorbView *adsorbView = [[MNAdsorbView alloc] initWithFrame:CGRectMake(0.f, 0.f, scrollView.width_mn, 10.f)];
    adsorbView.imageView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:adsorbView];
    
    WXPayHeaderView *headerView = [[WXPayHeaderView alloc] initWithFrame:CGRectMake(0.f, adsorbView.bottom_mn, scrollView.width_mn, 0.f)];
    headerView.delegate = self;
    [scrollView addSubview:headerView];
    
    UIImage *image = [UIImage imageNamed:@"wx_pay_bg"];
    CGSize size = CGSizeMultiplyToWidth(image.size, scrollView.width_mn);
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, headerView.bottom_mn, scrollView.width_mn, size.height) image:image];
    [scrollView addSubview:imageView];
    
    CGSize contentSize = scrollView.contentSize;
    contentSize.height = imageView.bottom_mn;
    scrollView.contentSize = contentSize;
}

#pragma mark - WXPayHeaderViewDelegate
- (void)headerView:(WXPayHeaderView *)headerView didSelectButtonAtIndex:(NSInteger)index {
    if (index == 0) {
        
    } else {
        UIViewControllerPush(@"WXWalletViewController", YES);
    }
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    UIViewControllerPush(@"WXPaySetingController", YES);
}

@end
