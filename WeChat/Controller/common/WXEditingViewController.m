//
//  WXEditingViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXEditingViewController.h"

@interface WXEditingViewController () <UITextViewDelegate, MNTextViewHandler>
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) MNTextView *textView;
@end

@implementation WXEditingViewController
- (instancetype)init {
    if (self = [super init]) {
        self.text = @"";
        self.font = [UIFont systemFontOfSize:17.f];
        self.numberOfLines = 1;
        self.keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.backgroundColor = VIEW_COLOR;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    
    CGFloat margin = 13.f;
    CGFloat height = self.numberOfLines > 0 ? self.font.lineHeight*self.numberOfLines : self.font.lineHeight*2;
    height += 1.f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, scrollView.width_mn, height + margin*2.f)];
    view.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:view];
    
    MNTextView *textView = [[MNTextView alloc] initWithFrame:UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetWith(margin))];
    textView.delegate = self;
    textView.text = _text;
    textView.font = self.font;
    textView.placeholder = self.placeholder;
    textView.tintColor = THEME_COLOR;
    textView.backgroundColor = [UIColor whiteColor];
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    textView.keyboardType = self.keyboardType;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0.f;
    [view addSubview:textView];
    self.textView = textView;
    
    if (self.numberOfWords > 0) {
        textView.handler = self;
        UILabel *numberLabel = [UILabel labelWithFrame:CGRectMake(textView.left_mn, textView.bottom_mn + margin, textView.width_mn, 15) text:NSStringFromNumber(@(self.numberOfWords - textView.text.length)) alignment:NSTextAlignmentRight textColor:UIColorWithAlpha([UIColor darkGrayColor], .6f) font:[UIFont systemFontOfSize:15.f]];
        [view addSubview:numberLabel];
        self.numberLabel = numberLabel;
        view.height_mn = numberLabel.bottom_mn + 7.f;
    }
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, view.width_mn, .5f)];
    topLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.2f];
    [view addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, view.height_mn - .5f, view.width_mn, .5f)];
    bottomLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.2f];
    [view addSubview:bottomLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        [self navigationBarRightBarItemTouchUpInside:self.navigationBar.rightBarItem];
        return NO;
    } else if (self.numberOfWords > 0) {
        return range.location + text.length <= self.numberOfWords;
    }
    return YES;
}

#pragma mark - MNTextViewHandler
- (void)textViewTextDidChange:(MNTextView *)textView {
    self.numberLabel.text = [@(self.numberOfWords - textView.text.length) stringValue];
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
                                              image:nil
                                              title:@"确定"
                                         titleColor:[UIColor whiteColor]
                                               titleFont:[UIFont systemFontOfSizes:16.f weights:.15f]];
    rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [self.textView resignFirstResponder];
    if (self.completionHandler) {
        self.completionHandler(self.textView.text, self);
    }
}

#pragma mark - Setter
- (void)setFont:(UIFont *)font {
    if (!font) return;
    _font = font;
}

#pragma mark - Getter
- (NSString *)text {
    return self.textView.text;
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
