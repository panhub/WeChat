//
//  WXPhotoTipButton.m
//  WeChat
//
//  Created by Vicent on 2021/4/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXPhotoTipButton.h"

@interface WXPhotoTipButton ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXPhotoTipButton
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:15.f]];
        titleLabel.numberOfLines = 1;
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)sizeToFit {
    
    [self.titleLabel sizeToFit];
    
    self.titleLabel.left_mn = self.imageView.right_mn + (self.titleLabel.text.length ? self.margin : 0.f);
    self.titleLabel.centerY_mn = self.imageView.centerY_mn;
    
    self.height_mn = self.imageView.bottom_mn + self.imageView.top_mn;
    self.width_mn = self.titleLabel.right_mn + self.imageView.left_mn;
}

@end
