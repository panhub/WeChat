//
//  MNActivityDialog.m
//  MNKit
//
//  Created by Vincent on 2018/7/31.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNActivityDialog.h"

@interface MNActivityDialog ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation MNActivityDialog
- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(37.f, 37.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = MNLoadDialogContentColor();
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center_mn = self.containerView.layer.position;
    [self.containerView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    [self layoutSubviewIfNeeded];
}

- (void)startAnimation {
    [_indicatorView startAnimating];
}

- (void)dismiss {
    [_indicatorView stopAnimating];
    [self removeFromSuperview];
}

@end
