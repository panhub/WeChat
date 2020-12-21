//
//  MNPayDialog.m
//  MNChat
//
//  Created by Vincent on 2019/6/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPayDialog.h"

@interface MNPayDialog ()
@property (nonatomic, strong) UIImageView *dotView;
@end

@implementation MNPayDialog
- (void)createView {
    [super createView];
    
    UIImage *image = [MNBundle imageForResource:@"loading_pay_logo" inDirectory:@"loading"];
    CGSize size = CGSizeMultiplyToWidth(image.size, 40.f);
    UIImageView *payView = [[UIImageView alloc] initWithImage:image];
    payView.frame = CGRectMake(0.f, 25.f, size.width, size.height);
    payView.contentMode = UIViewContentModeScaleAspectFill;
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, payView.bottom_mn + 10.f, 0.f, 17.f)];
    payLabel.font = [UIFont systemFontOfSizes:payLabel.height_mn weights:.2f];
    payLabel.textColor = UIColor.whiteColor;
    payLabel.textAlignment = NSTextAlignmentCenter;
    payLabel.text = @"微信支付";
    [payLabel sizeToFit];

    image = [MNBundle imageForResource:@"loading_pay_dot_0" inDirectory:@"loading"];
    size = CGSizeMultiplyToHeight(image.size, 6.f);
    UIImageView *dotView = [[UIImageView alloc] initWithImage:image];
    dotView.frame = CGRectMake(0.f, payLabel.bottom_mn + 13.f, size.width, size.height);
    dotView.contentMode = UIViewContentModeScaleAspectFill;
    self.dotView = dotView;
    
    self.contentView.frame = CGRectMake(0.f, 0.f, MAX(payView.width_mn, payLabel.width_mn) + 75.f, dotView.bottom_mn + 22.f);
    self.contentView.layer.cornerRadius = 5.f;
    self.contentView.clipsToBounds = YES;
    
    payView.centerX_mn = payLabel.centerX_mn = dotView.centerX_mn = self.contentView.width_mn/2.f;
    
    [self.contentView addSubview:payView];
    [self.contentView addSubview:payLabel];
    [self.contentView addSubview:dotView];
}

- (void)startAnimation {
    [super startAnimation];
    [self __startAnimation];
}

- (void)dismiss {
    [self.dotView.layer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)__startAnimation {
    NSArray <UIImage *>*imgs = @[[MNBundle imageForResource:@"loading_pay_dot_0" inDirectory:@"loading"], [MNBundle imageForResource:@"loading_pay_dot_1" inDirectory:@"loading"], [MNBundle imageForResource:@"loading_pay_dot_2" inDirectory:@"loading"]];
    [self.dotView.layer removeAllAnimations];
    [self.dotView startAnimationWithImages:imgs duration:1.2f repeat:0];
}

- (void)didEnterBackgroundNotification {
    [self.dotView.layer removeAllAnimations];
}

- (void)willEnterForegroundNotification {
    [self __startAnimation];
}

- (BOOL)updateMessage:(NSString *)message {
    return NO;
}

- (BOOL)interactionEnabled {
    return NO;
}

- (BOOL)allowedCreateEffect {
    return NO;
}

@end
