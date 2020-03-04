//
//  SEIndicatorView.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SEIndicatorView.h"
#import "UIView+SEFrame.h"

@interface SEIndicatorView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation SEIndicatorView
- (void)setFrame:(CGRect)frame {
    frame.size = CGSizeMake(120.f, 120.f);
    [super setFrame:frame];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.hidden = YES;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5.f;
        self.backgroundColor = UIColor.clearColor;
        //self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.51f];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = self.bounds;
        effectView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:effectView];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.center_mn = self.bounds_center;
        indicatorView.hidesWhenStopped = YES;
        [indicatorView stopAnimating];
        [self addSubview:indicatorView];
        self.indicatorView = indicatorView;
        
        CGFloat y = (self.height_mn - indicatorView.height_mn - 30.f)/2.f;
        indicatorView.top_mn = y;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, indicatorView.bottom_mn + 16.f, self.width_mn, 14.f)];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"加载中...";
        [self addSubview:titleLabel];
    }
    return self;
}

#pragma mark - Animating
- (void)startAnimating {
    self.hidden = NO;
    [self.indicatorView startAnimating];
    if (self.superview) self.center_mn = self.superview.bounds_center;
}

- (void)stopAnimating {
    self.hidden = YES;
    [self.indicatorView stopAnimating];
}

- (void)startAnimatingDelay:(NSTimeInterval)delay eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler {
    [self startAnimating];
    if (eventHandler) eventHandler();
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself stopAnimating];
        if (completionHandler) completionHandler();
    });
}

#pragma mark - Getter
- (BOOL)isAnimating {
    return self.indicatorView.isAnimating;
}

@end
