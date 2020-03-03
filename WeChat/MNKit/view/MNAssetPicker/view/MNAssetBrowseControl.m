//
//  MNAssetBrowseControl.m
//  MNFoundation
//
//  Created by Vincent on 2019/9/9.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetBrowseControl.h"
#import "MNAsset.h"

@interface MNAssetBrowseControl ()
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *imageButton;
@end

@implementation MNAssetBrowseControl
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.height_mn/2.f;
        self.backgroundColor = UIColorWithSingleRGB(52.f);
        
        UIButton *titleButton = [UIButton buttonWithFrame:CGRectMake(15.f, 0.f, 0.f, self.height_mn) image:nil title:@"选择" titleColor:UIColorWithSingleRGB(224.f) titleFont:[UIFont systemFontOfSize:15.f]];
        [titleButton sizeToFit];
        [titleButton setTitle:@"取消" forState:UIControlStateSelected];
        titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        titleButton.centerY_mn = self.height_mn/2.f;
        titleButton.userInteractionEnabled = NO;
        [self addSubview:titleButton];
        self.titleButton = titleButton;
        
        UIButton *imageButton = [UIButton buttonWithFrame:CGRectMake(titleButton.right_mn + 5.f, 0.f, 18.f, 18.f) image:[MNBundle imageForResource:@"icon_checkbox"] title:nil titleColor:nil titleFont:nil];
        imageButton.centerY_mn = self.height_mn/2.f;
        imageButton.userInteractionEnabled = NO;
        [imageButton setBackgroundImage:[MNBundle imageForResource:@"icon_checkboxHL"] forState:UIControlStateSelected];
        [self addSubview:imageButton];
        self.imageButton = imageButton;
        
        self.width_mn = imageButton.right_mn + 13.f;
    }
    return self;
}

- (void)updateAsset:(MNAsset *)asset {
    self.titleButton.selected = asset.isSelected;
    self.imageButton.selected = asset.isSelected;
    self.hidden = !asset.isEnabled;
}

@end
