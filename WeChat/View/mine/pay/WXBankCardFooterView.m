//
//  WXBankCardFooterView.m
//  MNChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardFooterView.h"

@implementation WXBankCardFooterView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColorWithSingleRGB(51.f);
        
        UIView *top_line = [[UIView alloc] initWithFrame:CGRectMake(0.f, 10.f, self.width_mn, .3f)];
        top_line.backgroundColor = UIColorWithSingleRGB(38.f);
        [self addSubview:top_line];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, top_line.bottom_mn, self.width_mn, 50.f)];
        contentView.backgroundColor = UIColorWithSingleRGB(59.f);
        [self addSubview:contentView];
        
        UIView *bottom_line = [[UIView alloc] initWithFrame:CGRectMake(0.f, contentView.bottom_mn, self.width_mn, .3f)];
        bottom_line.backgroundColor = top_line.backgroundColor;
        [self addSubview:bottom_line];
        
        UIImageView *addView = [UIImageView imageViewWithFrame:CGRectMake(13.f, MEAN(contentView.height_mn - 18.f), 18.f, 18.f) image:UIImageWithUnicode(@"\U0000e62c", UIColorWithAlpha([UIColor whiteColor], .35f), 18.f)];
        [contentView addSubview:addView];
        
        UILabel *addLabel = [UILabel labelWithFrame:CGRectMake(addView.right_mn + 10.f, 0.f, 0.f, 16.f) text:@"添加银行卡" textColor:UIColorWithAlpha([UIColor whiteColor], .35f) font:[UIFont systemFontOfSize:16.f]];
        addLabel.centerY_mn = addView.centerY_mn - 2.f;
        [addLabel sizeToFit];
        [contentView addSubview:addLabel];
        
        UIImage *image = UIImageWithUnicode(@"\U0000e63e", UIColorWithAlpha([UIColor whiteColor], .35f), 20.f);
        CGSize size = CGSizeMultiplyToHeight(image.size, 20.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height) image:image];
        arrowView.centerY_mn = addView.centerY_mn;
        [contentView addSubview:arrowView];
        
        UIButton *applyButton = [UIButton buttonWithFrame:CGRectMake(0.f, contentView.bottom_mn + 25.f, 100.f, 15.f) image:nil title:@"  申请信用卡" titleColor:UIColorWithRGB(115.f, 135.f, 179.f) titleFont:[UIFont systemFontOfSize:15.f]];
        applyButton.touchInset = UIEdgeInsetWith(-5.f);
        [applyButton setImage:[UIImage imageNamed:@"wx_pay_card"] forState:UIControlStateNormal];
        [applyButton setImage:[UIImage imageNamed:@"wx_pay_card"] forState:UIControlStateSelected];
        applyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:applyButton];
        
        image = UIImageWithUnicode(@"\U0000e63e", UIColorWithRGB(115.f, 135.f, 179.f), 20.f);
        size = CGSizeMultiplyToHeight(image.size, 13.f);
        arrowView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:image];
        arrowView.centerY_mn = applyButton.centerY_mn;
        [self addSubview:arrowView];
        
        applyButton.left_mn = (self.width_mn - applyButton.width_mn - arrowView.width_mn)/2.f;
        arrowView.left_mn = applyButton.right_mn;
        
        UILabel *helpLabel = [UILabel labelWithFrame:CGRectMake(0.f, applyButton.bottom_mn + 33.f, 0.f, 14.f) text:@"常见问题" alignment:NSTextAlignmentCenter textColor:UIColorWithRGB(115.f, 135.f, 179.f) font:UIFontLight(13.f)];
        [helpLabel sizeToFit];
        helpLabel.centerX_mn = self.width_mn/2.f;
        [self addSubview:helpLabel];
        
        self.height_mn = helpLabel.bottom_mn + 20.f;
        
        @weakify(self);
        [contentView handTapConfiguration:nil eventHandler:^(id sender) {
            @strongify(self);
            if (self.didClickedHandler) {
                self.didClickedHandler(0);
            }
        }];
        
        [applyButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
            @strongify(self);
            if (self.didClickedHandler) {
                self.didClickedHandler(1);
            }
        }];
    }
    return self;
}

@end
