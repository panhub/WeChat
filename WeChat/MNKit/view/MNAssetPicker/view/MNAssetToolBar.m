//
//  MNAssetToolBar.m
//  MNChat
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetToolBar.h"

@interface MNAssetToolBar ()
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *previewButton;
@end

@implementation MNAssetToolBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *blurImage = [UIImage imageWithColor:UIColorWithAlpha([UIColor whiteColor], .97f) size:self.size_mn];
        UIImageView *blurEffect = [UIImageView imageViewWithFrame:self.bounds image:blurImage];
        blurEffect.userInteractionEnabled = YES;
        [self addSubview:blurEffect];
        
        UIButton *previewButton = [UIButton buttonWithFrame:CGRectMake(15.f, 0.f, 50.f, 33.f) image:nil title:@"预览" titleColor:UIColorWithRGB(7.f, 192.f, 96.f) titleFont:[UIFont systemFontOfSize:17.f]];
        previewButton.centerY_mn = (self.height_mn - UITabSafeHeight())/2.f;
        previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [previewButton setTitleColor:UIColorWithSingleRGB(211.f) forState:UIControlStateDisabled];
        [previewButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previewButton];
        self.previewButton = previewButton;
        
        UIButton *doneButton = [UIButton buttonWithFrame:previewButton.frame image:[UIImage imageWithColor:UIColorWithRGB(7.f, 192.f, 96.f)] title:@"确定" titleColor:UIColorWithSingleRGB(251.f) titleFont:[UIFont systemFontOfSize:15.f]];
        doneButton.right_mn = self.width_mn - previewButton.left_mn;
        doneButton.tag = 1;
        doneButton.layer.cornerRadius = 4.f;
        doneButton.clipsToBounds = YES;
        [doneButton setBackgroundImage:[UIImage imageWithColor:UIColorWithRGB(7.f, 192.f, 96.f)] forState:UIControlStateHighlighted];
        [doneButton setBackgroundImage:[UIImage imageWithColor:UIColorWithSingleRGB(211.f)] forState:UIControlStateDisabled];
        [doneButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        self.doneButton = doneButton;
        
        UIButton *clearButton = previewButton.viewCopy;
        clearButton.tag = 2;
        clearButton.centerX_mn = self.width_mn/2.f;
        clearButton.centerY_mn = doneButton.centerY_mn;
        [clearButton setTitle:@"清除" forState:UIControlStateNormal];
        clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [clearButton setTitleColor:UIColorWithRGB(7.f, 192.f, 96.f) forState:UIControlStateNormal];
        [clearButton setTitleColor:UIColorWithSingleRGB(211.f) forState:UIControlStateDisabled];
        [clearButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        self.clearButton = clearButton;
        
        self.count = 0;
    }
    return self;
}

#pragma mark - Event
- (void)buttonClicked:(UIButton *)button {
    if (button.tag == 0) {
        if ([self.delegate respondsToSelector:@selector(assetToolBarLeftBarItemClicked:)]) {
            [self.delegate assetToolBarLeftBarItemClicked:self];
        }
    } else if (button.tag == 1) {
        if ([self.delegate respondsToSelector:@selector(assetToolBarRightBarItemClicked:)]) {
            [self.delegate assetToolBarRightBarItemClicked:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(assetToolBarClearButtonClicked:)]) {
            [self.delegate assetToolBarClearButtonClicked:self];
        }
    }
}

#pragma mark - Setter
- (void)setCount:(NSUInteger)count {
    NSString *title = count > 0 ? [NSString stringWithFormat:@"(%@)", @(count)] : @"";
    title = [@"确定" stringByAppendingString:title];
    CGFloat right = self.doneButton.right_mn;
    CGFloat width = [NSString getStringSize:title font:self.doneButton.titleLabel.font].width;
    width += 20.f;
    self.doneButton.width_mn = width;
    self.doneButton.right_mn = right;
    [self.doneButton setTitle:title forState:UIControlStateNormal];
    self.doneButton.enabled = self.previewButton.enabled = self.clearButton.enabled = count > 0;
}

@end
