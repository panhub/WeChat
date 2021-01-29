//
//  MNAssetSelectButton.m
//  MNKit
//
//  Created by Vincent on 2019/9/9.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetSelectButton.h"
#import "MNAsset.h"

#define MNAssetSelectButtonMinHeight   17.f

@interface MNAssetSelectButton ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MNAssetSelectButton
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        self.backgroundColor = UIColor.clearColor;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:@"选择" alignment:NSTextAlignmentLeft textColor:UIColorWithSingleRGB(224.f) font:[UIFont systemFontOfSize:15.f]];
        [titleLabel sizeToFit];
        titleLabel.width_mn += 7.f;
        titleLabel.centerY_mn = self.height_mn/2.f;
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(titleLabel.right_mn, 0.f, MNAssetSelectButtonMinHeight, MNAssetSelectButtonMinHeight) image:[MNBundle imageForResource:@"icon_checkbox"]];
        imageView.highlightedImage = [MNBundle imageForResource:@"icon_checkboxHL"];
        imageView.centerY_mn = self.height_mn/2.f;
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        self.width_mn = imageView.right_mn;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height = MAX(frame.size.height, MNAssetSelectButtonMinHeight);
    [super setFrame:frame];
}

- (void)updateAsset:(MNAsset *)asset {
    self.titleLabel.text = asset.isSelected ? @"取消" : @"选择";
    self.imageView.highlighted = asset.isSelected;
    self.hidden = !asset.isEnabled;
}

@end
