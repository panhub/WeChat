//
//  WXScanViewController.m
//  MNChat
//
//  Created by Vincent on 2019/4/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXScanViewController.h"
#import "WXQRCodeViewController.h"
#import "WXUserInfoViewController.h"
#import "WXScanResultViewController.h"

@interface WXScanViewController () <MNScannerDelegate, MNScanViewDelegate>
@property (nonatomic, strong) UILabel *lightLabel;
@property (nonatomic, strong) UIButton *lightButton;
@property (nonatomic, strong) MNScanView *scanView;
@property (nonatomic, strong) MNScanner *scanner;
@property (nonatomic, strong) UIImageView *focusView;
@end

@implementation WXScanViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"扫描二维码";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.titleColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.shadowView.hidden = YES;
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(76.f);
    
    MNScanView *scanView = [[MNScanView alloc] initWithFrame:self.contentView.bounds];
    scanView.delegate = self;
    scanView.cornerSize = CGSizeMake(3.f, 25.f);
    scanView.cornerColor = MN_R_G_B(128.f, 246.f, 63.f);
    scanView.scanLineImage = UIImageNamed(@"wx_common_scan_line");
    [self.contentView addSubview:scanView];
    self.scanView = scanView;
    
    UIImageView *focusView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 55.f, 55.f) image:[UIImage imageNamed:@"wx_video_recording_focusing"]];
    focusView.hidden = YES;
    [scanView addSubview:focusView];
    self.focusView = focusView;
    
    UILabel *lightLabel = [UILabel labelWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 100.f), CGRectGetMaxY(scanView.scanRect) - 25.f, 100.f, 13.f)
                                             text:@"轻触点亮"
                                    alignment:NSTextAlignmentCenter
                                        textColor:UIColorWithAlpha([UIColor whiteColor], .65f)
                                             font:UIFontRegular(13.f)];
    lightLabel.hidden = YES;
    [self.contentView addSubview:lightLabel];
    self.lightLabel = lightLabel;
    
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.hidden = YES;
    lightButton.frame = CGRectMake(MEAN(self.contentView.width_mn - 50.f), lightLabel.top_mn - 43.f, 50.f, 50.f);
    [lightButton setImage:UIImageNamed(@"wx_scan_light") forState:UIControlStateNormal];
    [lightButton setImage:UIImageNamed(@"wx_scan_light_HL") forState:UIControlStateSelected];
    lightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [lightButton addTarget:self action:@selector(lightButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:lightButton];
    self.lightButton = lightButton;
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(10.f, CGRectGetMaxY(scanView.scanRect) + 8.f, self.contentView.width_mn - 20.f, 13.f)
                                            text:@"将二维码放入框内, 即可自动扫描"
                                   alignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor whiteColor], .65f)
                                            font:UIFontRegular(13.f)];
    [self.contentView addSubview:hintLabel];
    
    UIButton *QRButton = [UIButton buttonWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 100.f), hintLabel.bottom_mn, 100.f, 40.f)
                                             image:nil
                                             title:@"我的二维码"
                                        titleColor:scanView.cornerColor
                                              titleFont:UIFontRegular(13.f)];
    [QRButton addTarget:self action:@selector(mineQRButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:QRButton];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    MNScanner *scanner = [[MNScanner alloc] init];
    scanner.delegate = self;
    scanner.outputView = self.contentView;
    scanner.scanRect = self.scanView.scanRect;
    [scanner prepareRunning];
    self.scanner = scanner;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scanner startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactiveTransitionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanner closeTorch];
    [self.scanner stopRunning];
    self.navigationController.interactiveTransitionEnabled = YES;
}

#pragma mark - MNScannerDelegate
- (void)scanner:(MNScanner *)scanner didFailWithError:(NSError *)error {
    [[MNAlertView alertViewWithTitle:nil message:error.localizedDescription handler:nil ensureButtonTitle:nil otherButtonTitles:@"确定", nil] showInView:self.view];
}

- (void)scannerDidStartRunning:(MNScanner *)scanner {
    [self.scanView startScanning];
}

- (void)scannerDidStopRunning:(MNScanner *)scanner {
    [self.scanView stopScanning];
}

- (void)scannerDidOpenTorch:(MNScanner *)scanner {
    self.lightButton.selected = YES;
    self.lightLabel.text = @"轻触关闭";
    self.lightLabel.hidden = self.lightButton.hidden = NO;
}

- (void)scannerDidCloseTorch:(MNScanner *)scanner {
    self.lightButton.selected = NO;
    self.lightLabel.text = @"轻触点亮";
    self.lightLabel.hidden = self.lightButton.hidden = YES;
}

- (void)scannerUpdateCurrentSampleBrightnessValue:(CGFloat)brightnessValue {
    if (self.scanner.isOnTorch) return;
    self.lightLabel.hidden = self.lightButton.hidden = (brightnessValue > 1.f);
}

- (void)scannerDidReadMetadataWithResult:(NSString *)result {
    if (result.length <= 0) return;
    [self.scanner closeTorch];
    [self.scanner stopRunning];
    [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"qrcode_found" ofType:@"caf" inDirectory:@"sound"] shake:NO];
    if ([result hasPrefix:WXQRCodeMetadataPrefix]) {
        /// 这是自己的二维码
        result = [result stringByReplacingOccurrencesOfString:WXQRCodeMetadataPrefix withString:@""];
        WXUser *user = [WXUser userWithInfo:result.JsonValue];
        WXUserInfoViewController *vc = [[WXUserInfoViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([result hasPrefix:@"http"]) {
        /// 是否浏览器打开
        [[MNAlertView alertViewWithTitle:@"是否打开链接?" message:result handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == alertView.ensureButtonIndex) {
                MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:result];
                [self.navigationController pushViewController:vc animated:YES];
            } else if (buttonIndex == 0) {
                [self.scanner startRunning];
            } else {
                [UIPasteboard generalPasteboard].string = result;
                [self.view showInfoDialog:@"已复制链接"];
                [self.scanner startRunning];
            }
        } ensureButtonTitle:@"应用内打开" otherButtonTitles:@"取消", @"复制内容", nil] show];
    } else {
        /// 展示扫描信息
        WXScanResultViewController *vc = [[WXScanResultViewController alloc] initWithResult:result];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - MNScanViewDelegate
- (void)scanView:(MNScanView *)scanView didClickAtPoint:(CGPoint)point {
    if (!self.focusView.hidden) return;
    [self.scanner setFocusPoint:point];
    self.focusView.center_mn = point;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(.5f, .5f);
    }];
    dispatch_after_main(.6f, ^{
        self.focusView.hidden = YES;
        self.focusView.transform = CGAffineTransformIdentity;
    });
}

#pragma mark - 手电筒响应方法
- (void)lightButtonClicked {
    if (self.scanner.isOnTorch) {
        [self.scanner closeTorch];
    } else {
        [self.scanner openTorch];
    }
}

#pragma mark - 我的二维码
- (void)mineQRButtonClicked {
    WXQRCodeViewController *vc = [WXQRCodeViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftBarItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    leftBarItem.backgroundImage = UIImageNamed(@"wx_common_back_white");
    [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftBarItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 35.f)
                                                 image:nil
                                                 title:@"相册"
                                            titleColor:[UIColor whiteColor]
                                                  titleFont:UIFontRegular(16.f)];
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    MNAssetPicker *picker = [MNAssetPicker picker];
    picker.configuration.allowsCapturing = NO;
    picker.configuration.allowsEditing = NO;
    picker.configuration.maxPickingCount = 1;
    picker.configuration.allowsPickingGif = NO;
    picker.configuration.allowsPickingVideo = NO;
    picker.configuration.allowsPickingLivePhoto = NO;
    [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
        if (assets.count <= 0) return;
        UIImage *image = assets.firstObject.content;
        if (!image) return;
        [MNScanner readImageMetadata:image completion:^(NSString *result) {
            [self scannerDidReadMetadataWithResult:result];
        }];
    } cancelHandler:nil];
}

#pragma mark - config controller
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
