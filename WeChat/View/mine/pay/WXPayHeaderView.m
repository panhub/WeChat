//
//  WXPayHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPayHeaderView.h"

@interface WXPayHeaderView ()
@property (nonatomic, strong) UILabel *moneyLabel;
@end

@implementation WXPayHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGFloat x = self.width_mn*0.02f;
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(x, 0.f, self.width_mn - x*2.f, 0.f)];
        backgroundView.backgroundColor = MN_R_G_B(60.f, 179.f, 113.f);
        backgroundView.layer.cornerRadius = 10.f;
        backgroundView.clipsToBounds = YES;
        [self addSubview:backgroundView];
        
        NSArray <NSString *>*titles = @[@"收付款", @"钱包"];
        NSArray <NSString *>*imgs = @[@"wx_pay_icon-2", @"wx_pay_wallet"];
        CGFloat width = 35.f;
        CGFloat height = CGSizeMultiplyToWidth([UIImage imageNamed:@"wx_pay_wallet"].size, width).height;
        x = (backgroundView.width_mn - width*2.f)/4.f;
        __block CGFloat h = 0.f;
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithFrame:CGRectMake(x + (width + x*2.f)*idx, 40.f, width, height) image:[UIImage imageNamed:imgs[idx]] title:nil titleColor:nil titleFont:nil];
            button.tag = idx;
            button.touchInset = UIEdgeInsetsMake(0.f, 0.f, -37.f, 0.f);
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [backgroundView addSubview:button];
            
            UILabel *label = [UILabel labelWithFrame:CGRectMake(0.f, button.bottom_mn + 20.f, backgroundView.width_mn/2.f, 17.f) text:obj alignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:17.f]];
            [backgroundView addSubview:label];
            label.centerX_mn = button.centerX_mn;
            h = label.bottom_mn;
            
            if (idx <= 0) return;
            
            UILabel *moneyLabel = [UILabel labelWithFrame:CGRectMake(0.f, label.bottom_mn + 7.f, backgroundView.width_mn/2.f, 15.f) text:@"" alignment:NSTextAlignmentCenter textColor:[UIColor.whiteColor colorWithAlphaComponent:.51f] font:SansFontMedium(15.f)];
            moneyLabel.centerX_mn = button.centerX_mn;
            [backgroundView addSubview:moneyLabel];
            self.moneyLabel = moneyLabel;
        }];
        
        backgroundView.height_mn = h + 45.f;
        self.height_mn = backgroundView.bottom_mn;
        
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.frame = self.bounds;
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.colors = @[(id)[[UIColor whiteColor] CGColor], (id)[UIColorWithSingleRGB(247.f) CGColor]];
        layer.startPoint = CGPointMake(.5f, 0.f);
        layer.endPoint = CGPointMake(.5f, .7f);
        [self.layer insertSublayer:layer atIndex:0];
        
        [self needsUpdateMoney];
        
        @weakify(self);
        [self handNotification:WXChangeRefreshNotificationName eventHandler:^(id sender) {
            @strongify(self);
            [self needsUpdateMoney];
        }];
    }
    return self;
}

- (void)needsUpdateMoney {
    self.moneyLabel.text = [@"¥" stringByAppendingString:WXPreference.preference.money];
}

- (void)buttonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(headerView:didSelectButtonAtIndex:)]) {
        [self.delegate headerView:self didSelectButtonAtIndex:button.tag];
    }
}

@end
