//
//  MNAssetToolBar.m
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetToolBar.h"
#import "MNAsset.h"
#import "MNAssetPickConfiguration.h"

#define MNAssetToolBarHighlightColor    [UIColor colorWithRed:7.f/255.f green:192.f/255.f blue:96.f/255.f alpha:1.f]
#define MNAssetToolBarDisabledColor    [UIColor colorWithRed:211.f/255.f green:211.f/255.f blue:211.f/255.f alpha:1.f]

@interface MNAssetToolBar ()
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UILabel *fileSizeLabel;
@property (nonatomic, strong) UIView *fileSizeView;
@property (nonatomic, strong) UIControl *fileSizeControl;
@end

@implementation MNAssetToolBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *blurImage = [UIImage imageWithColor:[UIColor.whiteColor colorWithAlphaComponent:.97f] size:self.size_mn];
        UIImageView *blurEffect = [UIImageView imageViewWithFrame:self.bounds image:blurImage];
        blurEffect.userInteractionEnabled = YES;
        [self addSubview:blurEffect];
        
        UIButton *previewButton = [UIButton buttonWithFrame:CGRectMake(15.f, 0.f, 50.f, 31.5f) image:nil title:@"预览" titleColor:MNAssetToolBarHighlightColor titleFont:[UIFont systemFontOfSize:16.f]];
        previewButton.centerY_mn = (self.height_mn - MN_TAB_SAFE_HEIGHT)/2.f;
        previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [previewButton setTitleColor:MNAssetToolBarDisabledColor forState:UIControlStateDisabled];
        [previewButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previewButton];
        self.previewButton = previewButton;
        
        UIButton *doneButton = [UIButton buttonWithFrame:previewButton.frame image:[UIImage imageWithColor:MNAssetToolBarHighlightColor] title:@"确定" titleColor:[UIColor colorWithRed:251.f/255.f green:251.f/255.f blue:251.f/255.f alpha:1.f] titleFont:[UIFont systemFontOfSize:15.f]];
        doneButton.right_mn = self.width_mn - previewButton.left_mn;
        doneButton.tag = 1;
        doneButton.layer.cornerRadius = 4.f;
        doneButton.clipsToBounds = YES;
        [doneButton setBackgroundImage:[UIImage imageWithColor:MNAssetToolBarHighlightColor] forState:UIControlStateHighlighted];
        [doneButton setBackgroundImage:[UIImage imageWithColor:MNAssetToolBarDisabledColor] forState:UIControlStateDisabled];
        [doneButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        self.doneButton = doneButton;
        
        UIButton *clearButton = previewButton.viewCopy;
        clearButton.tag = 2;
        clearButton.centerX_mn = self.width_mn/2.f;
        clearButton.centerY_mn = doneButton.centerY_mn;
        [clearButton setTitle:@"清除" forState:UIControlStateNormal];
        clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [clearButton setTitleColor:MNAssetToolBarHighlightColor forState:UIControlStateNormal];
        [clearButton setTitleColor:MNAssetToolBarDisabledColor forState:UIControlStateDisabled];
        [clearButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        self.clearButton = clearButton;
        
        UILabel *fileSizeLabel = [UILabel labelWithFrame:CGRectZero text:@"" alignment:NSTextAlignmentCenter textColor:MNAssetToolBarDisabledColor font:[UIFont systemFontOfSize:13.f]];
        fileSizeLabel.width_mn = 10.f;
        fileSizeLabel.right_mn = doneButton.left_mn;
        fileSizeLabel.centerY_mn = doneButton.centerY_mn;
        fileSizeLabel.hidden = YES;
        fileSizeLabel.userInteractionEnabled = NO;
        [self addSubview:fileSizeLabel];
        self.fileSizeLabel = fileSizeLabel;
        
        UIControl *fileSizeControl = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 18.f, 18.f)];
        fileSizeControl.centerY_mn = doneButton.centerY_mn;
        fileSizeControl.right_mn = fileSizeLabel.left_mn;
        fileSizeControl.touchInset = UIEdgeInsetWith(-5.f);
        fileSizeControl.hidden = YES;
        fileSizeControl.layer.cornerRadius = fileSizeControl.height_mn/2.f;
        fileSizeControl.layer.borderWidth = 1.f;
        fileSizeControl.layer.borderColor = MNAssetToolBarDisabledColor.CGColor;
        fileSizeControl.clipsToBounds = YES;
        [fileSizeControl addTarget:self action:@selector(fileSizeControlTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fileSizeControl];
        self.fileSizeControl = fileSizeControl;
        
        UIView *fileSizeView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(fileSizeControl.bounds, UIEdgeInsetsMake(4.f, 4.f, 4.f, 4.f))];
        fileSizeView.backgroundColor = MNAssetToolBarHighlightColor;
        fileSizeView.layer.cornerRadius = fileSizeView.height_mn/2.f;
        fileSizeView.clipsToBounds = YES;
        fileSizeView.userInteractionEnabled = NO;
        [fileSizeControl addSubview:fileSizeView];
        self.fileSizeView = fileSizeView;
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

- (void)fileSizeControlTouchUpInside:(UIControl *)control {
    [self.configuration setValue:@(!self.configuration.isOriginalExporting) forKey:@"isOriginalExporting"];
    [self updateFileSizeControl];
}

#pragma mark - Setter
- (void)setAssets:(NSArray<MNAsset *> *)assets {
    _assets = assets.copy;
    NSString *title = assets.count > 0 ? [NSString stringWithFormat:@"(%@)", @(assets.count)] : @"";
    title = [@"确定" stringByAppendingString:title];
    CGFloat right = self.doneButton.right_mn;
    CGFloat width = [NSString stringSize:title font:self.doneButton.titleLabel.font].width;
    width += 15.f;
    self.doneButton.width_mn = width;
    self.doneButton.right_mn = right;
    [self.doneButton setTitle:title forState:UIControlStateNormal];
    self.previewButton.enabled = self.clearButton.enabled = assets.count > 0;
    self.doneButton.enabled = (assets.count > 0 && assets.count >= self.configuration.minPickingCount);
    [self updateFileSizeControl];
}

- (void)setConfiguration:(MNAssetPickConfiguration *)configuration {
    _configuration = configuration;
    self.fileSizeControl.hidden = !configuration.isAllowsOriginalExporting;
    self.fileSizeLabel.hidden = (!configuration.isAllowsOriginalExporting && !configuration.isAllowsDisplayFileSize);
    self.assets = self.assets;
    if (configuration.isAllowsPreviewing) {
        if (self.previewButton.right_mn <= self.clearButton.left_mn) return;
        self.previewButton.left_mn = self.clearButton.left_mn;
        self.clearButton.centerX_mn = self.width_mn/2.f;
        self.previewButton.hidden = NO;
    } else {
        if (self.clearButton.right_mn <= self.previewButton.left_mn) return;
        self.clearButton.left_mn = self.previewButton.left_mn;
        self.previewButton.centerX_mn = self.width_mn/2.f;
        self.previewButton.hidden = YES;
    }
}

#pragma mark - 更新原图控件
- (void)updateFileSizeControl {
    if (self.fileSizeLabel.isHidden) return;
    NSString *fileSizeString = self.configuration.isAllowsOriginalExporting ? @"原图" : @"";
    if (self.configuration.isAllowsDisplayFileSize) {
        long long fileSize = self.assets.count > 0 ? [[self.assets valueForKeyPath:@"@sum.fileSize"] longLongValue] : 0;
        if (fileSize >= 1024*1024/10) {
            fileSizeString = [NSString stringWithFormat:@"%.1fM",(double)fileSize/1024.f/1024.f];
        } else if (fileSize >= 1024) {
            fileSizeString = [NSString stringWithFormat:@"%.0fK",(double)fileSize/1024.f];
        } else if (fileSize > 0) {
            fileSizeString = [NSString stringWithFormat:@"%lldB", fileSize];
        }
    }
    self.fileSizeLabel.text = fileSizeString;
    [self.fileSizeLabel sizeToFit];
    self.fileSizeLabel.width_mn += 10.f;
    self.fileSizeLabel.right_mn = self.doneButton.left_mn;
    self.fileSizeLabel.centerY_mn = self.doneButton.centerY_mn;
    self.fileSizeLabel.textColor = self.configuration.isOriginalExporting ? MNAssetToolBarHighlightColor : MNAssetToolBarDisabledColor;
    if (self.fileSizeControl.isHidden) return;
    self.fileSizeControl.right_mn = self.fileSizeLabel.left_mn;
    self.fileSizeControl.centerY_mn = self.fileSizeLabel.centerY_mn;
    self.fileSizeView.backgroundColor = self.fileSizeLabel.textColor;
    self.fileSizeControl.layer.borderColor = self.fileSizeLabel.textColor.CGColor;
}

@end
