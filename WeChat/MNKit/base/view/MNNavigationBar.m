//
//  MNNavigationBar.m
//  MNKit
//
//  Created by Vincent on 2017/12/23.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNNavigationBar.h"
#import "UIDevice+MNHelper.h"
#import "UIView+MNLayout.h"
#import "UIView+MNHelper.h"
#import "UIGestureRecognizer+MNHelper.h"
#import "MNConfiguration.h"
#import "UIImage+MNFont.h"
#import "MNExtern.h"
#import "NSString+MNHelper.h"

@interface MNNavigationBar()
@property (nonatomic, strong) UIView *leftBarItem;
@property (nonatomic, strong) UIView *rightBarItem;
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIVisualEffectView *blurEffect;
@property (nonatomic, strong) MNNavBarTitleView *titleView;
@property (nonatomic, weak) id<MNNavigationBarDelegate> delegate;
@end

const CGFloat kNavItemSize = 27.f;
const CGFloat kNavItemMargin = 13.f;

@implementation MNNavigationBar
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<MNNavigationBarDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {

        _delegate = delegate;
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        if (IS_IPAD) {
            self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        } else {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        }
        
        UIVisualEffectView *blurEffect = UIBlurEffectCreate(self.bounds, UIBlurEffectStyleExtraLight);
        [self addSubview:blurEffect];
        _blurEffect = blurEffect;
        
        [self addSubview:self.leftBarItem];
        [self addSubview:self.rightBarItem];
        [self addSubview:self.titleView];
        
        CGFloat margin = self.height_mn - MN_SEPARATOR_HEIGHT;
        margin = MAX(UIStatusBarHeight(), margin);
        UIImageView *shadowView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, margin, self.width_mn, MN_SEPARATOR_HEIGHT)];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        shadowView.clipsToBounds = YES;
        shadowView.contentMode = UIViewContentModeScaleAspectFill;
        shadowView.image = [UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .25f)];
        [self addSubview:shadowView];
        self.shadowView = shadowView;
        
        if ([_delegate respondsToSelector:@selector(navigationBarDidCreateBarItem:)]) {
            [_delegate navigationBarDidCreateBarItem:self];
        }
    }
    return self;
}

#pragma mark - leftBarItem
- (UIView *)leftBarItem {
    if (_leftBarItem) return _leftBarItem;
    if ([_delegate respondsToSelector:@selector(navigationBarShouldCreateLeftBarItem)]) {
        _leftBarItem = [_delegate navigationBarShouldCreateLeftBarItem];
    }
    if (!_leftBarItem) {
        _leftBarItem = [self createLeftItem];
    }
    _leftBarItem.left_mn = kNavItemMargin;
    CGFloat margin = MEAN(self.height_mn - UIStatusBarHeight() - _leftBarItem.height_mn);
    margin = MAX(0.f, margin);
    margin += UIStatusBarHeight();
    _leftBarItem.top_mn = margin;
    _leftBarItem.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    return _leftBarItem;
}

- (UIView *)createLeftItem {
    UIControl *leftBarItem = [[UIControl alloc] init];
    leftBarItem.size_mn = CGSizeMake(kNavItemSize, kNavItemSize);
    if ([_delegate respondsToSelector:@selector(navigationBarShouldDrawBackBarItem)] && [_delegate navigationBarShouldDrawBackBarItem]) {
        UIImage *leftItemImage = UIImageWithUnicode(MNFontUnicodeBack, [UIColor darkTextColor], kNavItemSize);
        leftBarItem.backgroundImage = leftItemImage;
        leftBarItem.touchInset = UIEdgeInsetWith(-5.f);
        [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return leftBarItem;
}

#pragma mark - rightBarItem
- (UIView *)rightBarItem {
    if (_rightBarItem) return _rightBarItem;
    if ([_delegate respondsToSelector:@selector(navigationBarShouldCreateRightBarItem)]) {
        _rightBarItem = [_delegate navigationBarShouldCreateRightBarItem];
    }
    if (!_rightBarItem) {
        _rightBarItem = [self createRightItem];
    }
    CGFloat margin = MEAN(self.height_mn - UIStatusBarHeight() - _rightBarItem.height_mn);
    margin = MAX(0.f, margin);
    margin += UIStatusBarHeight();
    _rightBarItem.top_mn = margin;
    _rightBarItem.right_mn = self.width_mn - kNavItemMargin;
    _rightBarItem.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return _rightBarItem;
}

- (UIView *)createRightItem {
    UIControl *rightBarItem = [[UIControl alloc] init];
    rightBarItem.size_mn = self.leftBarItem.size_mn;
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

#pragma mark - titleView
- (MNNavBarTitleView *)titleView {
    if (!_titleView) {
        CGFloat margin = MAX(self.leftBarItem.right_mn, self.width_mn - self.rightBarItem.left_mn);
        //margin += 3.f;
        CGFloat width = self.width_mn - margin*2.f;
        width = MAX(0.f, width);
        MNNavBarTitleView *titleView = [[MNNavBarTitleView alloc]initWithFrame:CGRectMake(margin, UIStatusBarHeight(), width, self.height_mn - UIStatusBarHeight())];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _titleView = titleView;
    }
    return _titleView;
}

#pragma mark - ActionEvent
- (void)navigationBarLeftBarItemTouchUpInside:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(navigationBarLeftBarItemTouchUpInside:)]) {
        [_delegate navigationBarLeftBarItemTouchUpInside:sender];
    }
}

- (void)navigationBarRightBarItemTouchUpInside:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(navigationBarRightBarItemTouchUpInside:)]) {
        [_delegate navigationBarRightBarItemTouchUpInside:sender];
    }
}

#pragma mark - Setter
- (void)setTranslucent:(BOOL)translucent {
    [_blurEffect setHidden:!translucent];
}

- (void)setBackItemColor:(UIColor *)backItemColor {
    if (!backItemColor) return;
    self.leftItemImage = UIImageWithUnicode(MNFontUnicodeBack, backItemColor, kNavItemSize);
}

- (void)setLeftItemImage:(UIImage *)leftItemImage {
    if (!leftItemImage) return;
    if (_leftBarItem) _leftBarItem.backgroundImage = leftItemImage;
}

- (void)setRightItemImage:(UIImage *)rightItemImage {
    if (!rightItemImage) return;
    if (_rightBarItem) _rightBarItem.backgroundImage = rightItemImage;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (!shadowColor) return;
    _shadowView.image = [UIImage imageWithColor:shadowColor];
}

- (void)setTitle:(NSString *)title {
    _titleView.title = title;
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (!titleFont) return;
    _titleView.titleLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!titleColor) return;
    _titleView.titleLabel.textColor = titleColor;
}

#pragma mark - Getter
- (BOOL)translucent {
    return !_blurEffect.hidden;
}

- (NSString *)title {
    return _titleView.title;
}

- (UIFont *)titleFont {
    return _titleView.titleLabel.font;
}

- (UIColor *)titleColor {
    return _titleView.titleLabel.textColor;
}

#pragma mark - Overwrite
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
