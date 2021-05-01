//
//  WXScanResultViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXScanResultViewController.h"

@interface WXScanResultViewController () <UITextViewDelegate>
@property (nonatomic, copy) NSString *result;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) MNWebProgressView *progressView;
@end

@implementation WXScanResultViewController
- (instancetype)init {
    return [self initWithResult:@""];
}

- (instancetype)initWithResult:(NSString *)result {
    if (self = [super init]) {
        self.title = @"扫描结果";
        self.result = result;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.backgroundColor = VIEW_COLOR;
    
    MNWebProgressView *progressView = [[MNWebProgressView alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn - 2.5f, self.navigationBar.width_mn, 2.5f)];
    progressView.tintColor = THEME_COLOR;
    [self.navigationBar addSubview:progressView];
    self.progressView = progressView;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.contentView.bounds];
    textView.delegate = self;
    textView.text = self.result;
    textView.font = [UIFont systemFontOfSize:16.5f];
    textView.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.8f];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDefault;
    textView.backgroundColor = [UIColor whiteColor];
    textView.textContainerInset = UIEdgeInsetWith(8.f);
    textView.textContainer.lineFragmentPadding = 0.f;
    textView.performActions = MNTextViewActionSelect|MNTextViewActionSelectAll|MNTextViewActionPaste;
    [self.contentView addSubview:textView];
    self.textView = textView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstAppear) self.textView.alpha = 0.f;
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
                self.textView.alpha = 1.f;
            }];
        } else {
            [self updateProgressIfNeeds];
        }
    });
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, kNavItemSize)
                                             image:nil
                                             title:@"取消"
                                        titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                              titleFont:@(17.f)];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 53.f, 32.f)
                                              image:[UIImage imageWithColor:THEME_COLOR]
                                              title:@"复制"
                                         titleColor:[UIColor whiteColor]
                                               titleFont:[UIFont systemFontOfSizes:17.f weights:.15f]];
    [rightItem setBackgroundImage:[UIImage imageWithColor:[THEME_COLOR colorWithAlphaComponent:.5f]] forState:UIControlStateDisabled];
    rightItem.enabled = self.result.length > 0;
    //rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [[UIPasteboard generalPasteboard] setString:self.textView.text];
    [self.view showInfoDialog:@"复制成功"];
}

@end
