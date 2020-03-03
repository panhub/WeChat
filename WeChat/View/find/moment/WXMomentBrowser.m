//
//  WXMomentBrowser.m
//  MNChat
//
//  Created by Vincent on 2019/9/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentBrowser.h"
#import "WXMomentPreview.h"
#import "WXMomentViewModel.h"

@interface WXMomentBrowser ()<MNAssetBrowseDelegate, MNNavigationBarDelegate>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) MNNavigationBar *browseBar;
@property (nonatomic, strong) WXMomentPreview *previewBar;
@property (nonatomic, strong) MNPageControl *pageControl;
@property (nonatomic, strong) WXMomentViewModel *viewModel;
@end

@implementation WXMomentBrowser
- (instancetype)initWithViewModel:(WXMomentViewModel *)viewModel {
    if (self = [super init]) {
        self.delegate = self;
        self.viewModel = viewModel;
        self.statusBarHidden = NO;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        if (viewModel.moment.isMine) {
            MNNavigationBar *browseBar = [[MNNavigationBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, TOP_BAR_HEIGHT) delegate:self];
            browseBar.leftItemImage = UIImageNamed(@"wx_common_back_white");
            browseBar.rightItemImage = UIImageNamed(@"wx_common_more_white");
            browseBar.titleView.titleLabel.numberOfLines = 2;
            browseBar.translucent = NO;
            browseBar.shadowColor = [UIColor clearColor];
            browseBar.backgroundColor = UIColorWithSingleRGB(46.f);
            browseBar.alpha = 0.f;
            [self addSubview:browseBar];
            self.browseBar = browseBar;
            
            WXMomentPreview *previewBar = [[WXMomentPreview alloc] initWithMoment:viewModel.moment];
            previewBar.bottom_mn = self.height_mn;
            previewBar.alpha = 0.f;
            [self addSubview:previewBar];
            self.previewBar = previewBar;
        }
        
        if (viewModel.moment.pictures.count > 1) {
            MNPageControl *pageControl = [[MNPageControl alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, 20.f)];
            pageControl.alpha = 0.f;
            pageControl.numberOfPages = viewModel.moment.pictures.count;
            pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
            pageControl.userInteractionEnabled = NO;
            pageControl.bottom_mn = self.height_mn - UITabSafeHeight() - 10.f;
            if (viewModel.moment.isMine) pageControl.bottom_mn = self.previewBar.top_mn;
            [self addSubview:pageControl];
            self.pageControl = pageControl;
        }
    }
    return self;
}

#pragma mark - MNAssetBrowseDelegate
- (void)assetBrowserWillPresent:(MNAssetBrowser *)assetBrowser {
    [UIView animateWithDuration:MNAssetBrowsePresentAnimationDuration animations:^{
        self.pageControl.alpha = self.browseBar.alpha = self.previewBar.alpha =  1.f;
    }];
}

- (void)assetBrowserWillDismiss:(MNAssetBrowser *)assetBrowser {
    [UIView animateWithDuration:MNAssetBrowseDismissAnimationDuration animations:^{
        self.pageControl.alpha = self.browseBar.alpha = self.previewBar.alpha = 0.f;
    }];
}

- (void)assetBrowser:(MNAssetBrowser *)assetBrowser didScrollToIndex:(NSInteger)index {
    self.pageControl.currentPageIndex = index;
    if (self.pageControl.numberOfPages <= 1 || !self.browseBar) return;
    NSAttributedString *timeString = self.viewModel.timeViewModel.content;
    NSString *pageString = [NSString stringWithFormat:@"%@/%@", @(index + 1), @(self.pageControl.numberOfPages)];
    NSString *string = [NSString stringWithFormat:@"%@\n%@", timeString.string, pageString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    attributedString.color = [UIColor whiteColor];
    attributedString.alignment = NSTextAlignmentCenter;
    attributedString.font = [UIFont boldSystemFontOfSize:16.5f];
    [attributedString setFont:[UIFont systemFontOfSize:11.f] range:[string rangeOfString:pageString]];
    attributedString.lineSpacing = 0.f;
    self.browseBar.titleView.titleLabel.attributedText = attributedString;
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    [self dismiss];
}

@end
