//
//  WXErasureViewController.m
//  WeChat
//
//  Created by Vicent on 2021/1/30.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXErasureViewController.h"
#import "MNVideoTailorController.h"
#import "ZMTokenRequest.h"
#import "ZMRegularRequest.h"
#import "ZMVideoUrlRequest.h"

@interface WXErasureViewController ()<UITextFieldDelegate, MNVideoTailorDelegate>
@property (nonatomic, copy) NSString *regular;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation WXErasureViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"一键去水印";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:scrollView];
    
    UIButton *extractButton = [UIButton buttonWithFrame:CGRectZero image:[UIImage imageWithColor:THEME_COLOR] title:@"提取视频" titleColor:UIColor.whiteColor titleFont:[UIFont systemFontOfSize:16.f]];
    [extractButton sizeToFit];
    extractButton.width_mn += 25.f;
    extractButton.height_mn = 42.f;
    extractButton.top_mn = self.navigationBar.bottom_mn + 17.f;
    extractButton.right_mn = scrollView.width_mn - 15.f;
    UIViewSetCornerRadius(extractButton, 5.f);
    [extractButton addTarget:self action:@selector(extract) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:extractButton];
    
    UITextField *textField = [UITextField textFieldWithFrame:CGRectZero font:[UIFont systemFontOfSize:16.f] placeholder:@"请输入视频地址" delegate:self];
    textField.left_mn = 15.f;
    textField.width_mn = extractButton.left_mn - 27.f;
    textField.height_mn = extractButton.height_mn + 2.f;
    textField.centerY_mn = extractButton.centerY_mn;
    textField.tintColor = THEME_COLOR;
    textField.borderStyle = UITextBorderStyleNone;
    textField.keyboardType = UIKeyboardTypeURL;
    textField.returnKeyType = UIReturnKeySearch;
    UIViewSetBorderRadius(textField, 5.f, .9f, [UIColor.grayColor colorWithAlphaComponent:.12f]);
    UIView *leftView = [[UIView alloc] init];
    leftView.width_mn = 7.f;
    leftView.height_mn = textField.height_mn;
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [scrollView addSubview:textField];
    self.textField = textField;
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectZero text:@"支持以下平台的视频提取" alignment:NSTextAlignmentCenter textColor:UIColor.darkTextColor font:[UIFont systemFontOfSize:14.f]];
    hintLabel.numberOfLines = 1;
    [hintLabel sizeToFit];
    hintLabel.top_mn = textField.bottom_mn + 23.f;
    hintLabel.centerX_mn = scrollView.width_mn/2.f;
    [scrollView addSubview:hintLabel];
    
    __block CGFloat y = 0.f;
    NSArray <NSString *>*imgs = @[@"qsy_dy",@"qsy_ks",@"qsy_ws",@"qsy_hs"];
    NSArray <NSString *>*titles = @[@"抖音",@"快手",@"微视",@"火山"];
    CGFloat w = 55.f;
    CGFloat m = 28.f;
    CGFloat x = (scrollView.width_mn - imgs.count*w - (imgs.count - 1)*m)/2.f;
    if (x < textField.left_mn) {
        x = textField.left_mn;
        m = (extractButton.right_mn - textField.left_mn - imgs.count*w)/(imgs.count - 1);
    }
    [UIView gridLayoutWithInitial:CGRectMake(x, hintLabel.bottom_mn + 12.f, w, w + 25.f) offset:UIOffsetMake(m, m) count:imgs.count rows:imgs.count handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIControl *control = [[UIControl alloc] initWithFrame:rect];
        [scrollView addSubview:control];
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, rect.size.width, rect.size.width) image:[UIImage imageNamed:imgs[idx]]];
        [control addSubview:imageView];
        
        UILabel *label = [UILabel labelWithFrame:CGRectZero text:titles[idx] alignment:NSTextAlignmentCenter textColor:UIColor.darkTextColor font:[UIFont systemFontOfSize:13.f]];
        label.numberOfLines = 1;
        [label sizeToFit];
        label.bottom_mn = control.height_mn;
        label.centerX_mn = control.width_mn/2.f;
        [control addSubview:label];
        
        y = control.bottom_mn;
    }];
    
    hintLabel = [UILabel labelWithFrame:CGRectZero text:@"简易教程" alignment:NSTextAlignmentCenter textColor:UIColor.darkTextColor font:[UIFont systemFontOfSize:14.f]];
    hintLabel.numberOfLines = 1;
    [hintLabel sizeToFit];
    hintLabel.top_mn = y + 23.f;
    hintLabel.centerX_mn = scrollView.width_mn/2.f;
    [scrollView addSubview:hintLabel];
    
    x = textField.left_mn;
    imgs = @[@"qsy_xk_1", @"qsy_xk_2"];
    m = 15.f;
    w = (extractButton.right_mn - textField.left_mn - m)/2.f;
    [UIView gridLayoutWithInitial:CGRectMake(x, hintLabel.bottom_mn + 13.f, ceil(w), 0.f) offset:UIOffsetMake(m, 0.f) count:imgs.count rows:imgs.count handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:rect image:[UIImage imageNamed:imgs[idx]]];
        [imageView sizeFitToWidth];
        [scrollView addSubview:imageView];
        
        y = imageView.bottom_mn;
    }];
    
    CGSize contentSize = scrollView.bounds.size;
    contentSize.height = MAX(contentSize.height, y + MAX(MN_TAB_SAFE_HEIGHT, 15.f));
    scrollView.contentSize = contentSize;
}

- (void)handEvents {
    [super handEvents];
    @weakify(self);
    [self handNotification:UIApplicationDidBecomeActiveNotification eventHandler:^(NSNotification *_Nonnull notify) {
        @strongify(self);
        if (self.isAppear && self.contentView.isDialoging == NO) {
            [self check];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear && self.regular.length) {
        [self check];
    }
}

- (void)loadData {
    @weakify(self);
    [ZMTokenRequest.new loadData:^{
        @strongify(self);
        [self.contentView showWechatDialog];
    } completion:^(MNURLResponse * _Nonnull r) {
        if (r.code == MNURLResponseCodeSucceed) {
            [ZMRegularRequest.new loadData:^{
                @strongify(self);
                if (!self.contentView.isDialoging) [self.contentView showWechatDialog];
            } completion:^(MNURLResponse * _Nonnull response) {
                if (response.code == MNURLResponseCodeSucceed) {
                    @strongify(self);
                    NSDictionary *data = [NSDictionary dictionaryValueWithDictionary:response.data forKey:@"data"];
                    self.regular = [NSDictionary stringValueWithDictionary:data forKey:@"regular"];
                    [self.contentView closeDialog];
                    if (self.isAppear && self.isFirstAppear) [self check];
                } else {
                    @strongify(self);
                    [self.contentView showInfoDialog:response.message];
                }
            }];
        } else {
            @strongify(self);
            [self.contentView showInfoDialog:r.message];
        }
    }];
}

- (void)check {
    NSString *pasteboardString = UIPasteboard.generalPasteboard.string;
    if (pasteboardString.length <= 0) return;
    // 匹配链接
    NSArray <NSString *>*urls = [NSString matchString:pasteboardString useingExpressions:@[self.regular]];
    if (urls.count <= 0) return;
    NSString *url = urls.firstObject;
    // 检查是否与输入框相同
    if (url.length <= 0) return;
    // 需要显示的字符串
    NSString *display_url = url.copy;
    if (display_url.length > 30) {
        display_url = [display_url substringToIndex:30];
        display_url = [display_url stringByAppendingString:@"..."];
    }
    // 检查是否与当前弹窗提示信息相同<如有的话>
    if ([display_url isEqualToString:MNAlertView.currentAlertView.messageText] || [url isEqualToString:self.textField.text]) return;
    // 关闭所有弹窗, 显示新弹窗
    @weakify(self);
    [MNAlertView close];
    // 显示新弹窗
    [[MNAlertView alertViewWithTitle:@"检查到URL链接" message:display_url handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.ensureButtonIndex) return;
        weakself.textField.text = url;
        [weakself extract];
    } ensureButtonTitle:@"立即提取" otherButtonTitles:@"取消", nil] show];
    [MNAlertView setAlertViewButtonTitleColor:THEME_COLOR ofIndex:1];
}

- (void)extract {
    NSString *string = self.textField.text;
    if (string.length <= 0) return;
    @weakify(self);
    [[[ZMVideoUrlRequest alloc] initWithVideoUrl:string] loadData:^{
        [weakself.contentView showWechatDialog];
    } completion:^(MNURLResponse * _Nonnull response) {
        if (response.code == MNURLResponseCodeSucceed) {
            [weakself download:kTransform(ZMVideoUrlRequest *, response.request).downloadUrl];
        } else {
            [weakself.contentView showInfoDialog:response.message];
        }
    }];
}

- (void)download:(NSString *)url {
    if (url.length <= 0) {
        [self.contentView showInfoDialog:@"查询视频失败"];
        return;
    }
    @weakify(self);
    NSString *filePath = MNCacheDirectoryAppending([MNFileHandle fileNameWithExtension:@"mp4"]);
    MNURLDownloadRequest *downloadRequest = MNURLDownloadRequest.new;
    downloadRequest.url = url;
    [downloadRequest downloadData:^{
        [weakself.contentView showProgressDialog:@"正在下载视频"];
    } filePath:^NSURL *(NSURLResponse *response, NSURL *location) {
        return [NSURL fileURLWithPath:filePath];
    } progress:^(NSProgress *progress) {
        [weakself.contentView updateDialogProgress:progress.fractionCompleted];
    } completion:^(MNURLResponse *response) {
        if (response.code == MNURLResponseCodeSucceed) {
            [weakself.contentView closeDialogWithCompletionHandler:^{
                MNVideoTailorController *vc = MNVideoTailorController.new;
                vc.videoPath = filePath;
                vc.outputPath = MNCacheDirectoryAppending([MNFileHandle fileNameWithExtension:@"mp4"]);
                vc.allowsResizeSize = NO;
                vc.deleteVideoWhenFinish = NO;
                vc.delegate = self;
                [weakself.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            [weakself.contentView showInfoDialog:response.message];
        }
    }];
}

#pragma mark - MNVideoTailorDelegate
- (void)videoTailorControllerDidCancel:(MNVideoTailorController *_Nonnull)tailorController {
    [NSFileManager.defaultManager removeItemAtPath:tailorController.videoPath error:nil];
    [tailorController.navigationController popViewControllerAnimated:YES];
}

- (void)videoTailorController:(MNVideoTailorController *_Nonnull)tailorController didTailoringVideoAtPath:(NSString *_Nonnull)videoPath {
    @weakify(self);
    @weakify(tailorController);
    [tailorController.view showWechatDialog];
    [MNAssetHelper writeVideoToAlbum:videoPath completionHandler:^(NSString * _Nullable identifier, NSError * _Nullable error) {
        if (!identifier || error) {
            [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
            [weaktailorController.view showErrorDialog:@"保存视频失败"];
        } else {
            [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
            [NSFileManager.defaultManager removeItemAtPath:weaktailorController.videoPath error:nil];
            [weaktailorController.view showCompletedDialog:@"已保存至系统相册" completionHandler:^{
                UIViewController *vc = weakself.navigationController.viewControllers[[weakself.navigationController.viewControllers indexOfObject:weakself] - 1];
                [weaktailorController.navigationController popToViewController:vc animated:YES];
            }];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self extract];
    return YES;
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
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
