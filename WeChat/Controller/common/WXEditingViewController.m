//
//  WXEditingViewController.m
//  WeChat
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
        self.numberOfLines = 1;
        self.font = [UIFont systemFontOfSize:17.f];
        self.keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.backgroundColor = VIEW_COLOR;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    
    CGFloat margin = 13.f;
    
    NSMutableString *string = @"啊啊啊啊啊".mutableCopy;
    if (self.numberOfLines > 0) {
        for (NSInteger i = 0; i < self.numberOfLines - 1; i++) {
            [string appendString:@"\n啊啊啊啊啊"];
        }
    }
    
    CGFloat height = ceil([string sizeWithFont:self.font].height);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, scrollView.width_mn, height + margin*2.f)];
    view.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:view];
    
    MNTextView *textView = [[MNTextView alloc] initWithFrame:UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetWith(margin))];
    textView.delegate = self;
    textView.text = _text;
    textView.font = self.font;
    textView.placeholder = self.placeholder;
    textView.tintColor = THEME_COLOR;
    textView.backgroundColor = UIColor.whiteColor;
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    textView.keyboardType = self.keyboardType;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0.f;
    [view addSubview:textView];
    self.textView = textView;
    
    ((UIButton *)self.navigationBar.rightBarItem).enabled = textView.text.length >= self.minOfWordInput;
    
    if (self.numberOfWords > 0) {
        textView.handler = self;
        UILabel *numberLabel = [UILabel labelWithFrame:CGRectMake(textView.left_mn, textView.bottom_mn + margin, textView.width_mn, 15) text:NSStringFromNumber(@(self.numberOfWords - textView.text.length)) alignment:NSTextAlignmentRight textColor:UIColorWithAlpha([UIColor darkGrayColor], .6f) font:[UIFont systemFontOfSize:15.f]];
        numberLabel.numberOfLines = 1;
        [view addSubview:numberLabel];
        self.numberLabel = numberLabel;
        view.height_mn = numberLabel.bottom_mn + 7.f;
    }
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, view.width_mn, MN_SEPARATOR_HEIGHT)];
    topLine.backgroundColor = SEPARATOR_COLOR;
    [view addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, view.width_mn, MN_SEPARATOR_HEIGHT)];
    bottomLine.bottom_mn = view.height_mn;
    bottomLine.backgroundColor = SEPARATOR_COLOR;
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
    if (textView.markedTextRange || text.length <= 0) return YES;
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        [self navigationBarRightBarItemTouchUpInside:self.navigationBar.rightBarItem];
        return NO;
    }
    if (self.numberOfWords > 0 && (range.location + text.length - range.length) > self.numberOfWords) return NO;
    if (self.shieldCharacters && [self.shieldCharacters containsObject:text]) return NO;
    return YES;
}

#pragma mark - MNTextViewHandler
- (void)textViewTextDidChange:(MNTextView *)textView {
    if (self.numberOfWords > 0) {
        if (textView.text.length > self.numberOfWords) {
            textView.text = [textView.text substringToIndex:self.numberOfWords];
        }
        self.numberLabel.text = [@(self.numberOfWords - textView.text.length) stringValue];
    }
    ((UIButton *)self.navigationBar.rightBarItem).enabled = textView.text.length >= self.minOfWordInput;
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
                                              title:@"确定"
                                         titleColor:[UIColor whiteColor]
                                               titleFont:[UIFont systemFontOfSizes:16.f weights:.15f]];
    UIViewSetCornerRadius(rightItem, 3.f);
    rightItem.backgroundColor = THEME_COLOR;
    [rightItem setTitleColor:MN_RGB(183.f) forState:UIControlStateDisabled];
    [rightItem setBackgroundImage:[UIImage imageWithColor:MN_RGB(225.f)] forState:UIControlStateDisabled];
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

- (void)setMinOfWordInput:(NSUInteger)minOfWordInput {
    _minOfWordInput = minOfWordInput;
    if (self.textView) {
        // 已创建了视图
        ((UIButton *)self.navigationBar.rightBarItem).enabled = self.textView.text.length >= minOfWordInput;
    }
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
