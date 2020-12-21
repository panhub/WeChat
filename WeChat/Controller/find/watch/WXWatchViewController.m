//
//  WXWatchViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWatchViewController.h"
#import "WXWatchView.h"

@interface WXWatchViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WXWatchView *watchView;
@end

@implementation WXWatchViewController

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, MEAN(self.contentView.height_mn - self.contentView.width_mn), self.contentView.width_mn, self.contentView.width_mn)
                                                       image:UIImageNamed(@"wx_watch_bg")];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    
    CGFloat x = 412.f/1264.f*imageView.width_mn;
    CGFloat y = 295.f/1264.f*imageView.height_mn;
    CGFloat wh = 522.f/1264.f*imageView.width_mn;
    
    WXWatchView *watchView = [[WXWatchView alloc] initWithFrame:CGRectMake(x, y, wh, wh)];
    watchView.startAngle = -M_PI_2;
    watchView.endAngle = M_PI_2*3;
    watchView.innerInterval = 3.f;
    watchView.scaleInterval = 7.f;
    watchView.strokeColor = [UIColor whiteColor];
    watchView.fillColor = MN_R_G_B(8.f, 9.f, 10.f);
    watchView.divide = 12;
    watchView.subdivide = 5;
    watchView.detailViewHandler = ^UIView *(NSUInteger idx) {
        if (idx == 0) return nil;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 25.f, 15.f)];
        label.text = [NSString stringWithFormat:@"%@", @(idx)];
        label.font = [UIFont systemFontOfSize:15.f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    };
    UIViewSetCornerRadius(watchView, MEAN(watchView.width_mn));
    watchView.backgroundColor = [UIColor blackColor];
    [imageView addSubview:watchView];
    self.watchView = watchView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.watchView fire];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)
                                              image:UIImageNamed(@"wx_applet_close")
                                              title:nil
                                         titleColor:nil
                                               titleFont:nil];
    [rightItem setBackgroundImage:UIImageNamed(@"wx_applet_close") forState:UIControlStateHighlighted];
    [rightItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (void)dealloc {
    [_watchView invalidate];
}

@end
