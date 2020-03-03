//
//  SECompletedDialog.m
//  ShareExtension
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "SECompletedDialog.h"
#import "UIView+SEFrame.h"

@interface SECompletedDialog ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation SECompletedDialog
- (void)setFrame:(CGRect)frame {
    frame.size = CGSizeMake(120.f, 120.f);
    [super setFrame:frame];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5.f;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.51f];
        
        // 优化视图效果 /3
        CGFloat y = (self.height_mn - 35.f - 25.f)/3.f;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, y, 47.f, 47.f)];
        imageView.centerX_mn = self.width_mn/2.f;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"ext_share_succeed"];
        [self addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, imageView.bottom_mn + 11.f, self.width_mn, 14.f)];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"分享成功";
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)showInView:(UIView *)superview delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler {
    [self showInView:superview message:nil delay:delay completionHandler:completionHandler];
}

- (void)showInView:(UIView *)superview message:(NSString *)message delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler {
    if (!superview || self.superview) return;
    if (message.length) self.titleLabel.text = message;
    self.center_mn = superview.bounds_center;
    [superview addSubview:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.25f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.f;
            self.transform = CGAffineTransformMakeScale(.96f, .96f);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (completionHandler) completionHandler();
        }];
    });
}

@end
