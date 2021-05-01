//
//  WXMusicLyricLabel.m
//  WeChat
//
//  Created by Vincent on 2020/2/10.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicLyricLabel.h"
#import "WXLyricViewModel.h"

@implementation WXMusicLyricLabel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfLines = 0;
    }
    return self;
}

- (void)setViewModel:(WXLyricViewModel *)viewModel {
    _viewModel = viewModel;
    if (!CGRectEqualToRect(viewModel.contentRect, self.frame)) {
        self.frame = viewModel.contentRect;
    }
    self.attributedText = viewModel.content;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [THEME_COLOR set];
    if (self.viewModel.lineRatio < 1.f) {
        // 多行
        if (self.viewModel.progress >= self.viewModel.lineRatio) {
            CGRect fillRect = CGRectMake(0.f, 0.f, self.bounds.size.width, self.bounds.size.height/2.f);
            UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
            fillRect = CGRectMake(0.f, self.bounds.size.height/2.f, self.bounds.size.width*(self.viewModel.progress - self.viewModel.lineRatio), self.bounds.size.height/2.f);
            UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
        } else {
            CGRect fillRect = CGRectMake(0.f, 0.f, self.bounds.size.width*self.viewModel.progress, self.bounds.size.height/2.f);
            UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
        }
    } else {
        // 单行
        CGRect fillRect = CGRectMake(0.f, 0.f, self.bounds.size.width*self.viewModel.progress, self.bounds.size.height);
        UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
    }
}

@end
