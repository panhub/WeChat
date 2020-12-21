//
//  MNRefreshNormalHeader.m
//  MNKit
//
//  Created by Vincent on 2019/4/20.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNRefreshNormalHeader.h"
#import "MNIndicatorView.h"

@interface MNRefreshNormalHeader ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) MNIndicatorView *indicatorView;
@end

@implementation MNRefreshNormalHeader
- (instancetype)init {
    if (self = [super init]) {
        @weakify(self);
        self.didEndRefreshingCallback = ^{
            @strongify(self);
            [self.indicatorView stopAnimating];
        };
    }
    return self;
}

#pragma mark - Getter
- (MNIndicatorView *)indicatorView {
    if (!_indicatorView) {
        MNIndicatorView *indicatorView = [[MNIndicatorView alloc] initWithFrame:CGRectMake(0.f, 0.f, 15.f, 15.f)];
        indicatorView.lineWidth = .8f;
        indicatorView.color = [self.textLabel.textColor colorWithAlphaComponent:.2f];
        indicatorView.lineColor = self.textLabel.textColor;
        _indicatorView = indicatorView;
    }
    return _indicatorView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = @"加载中...";
        textLabel.font = [UIFont systemFontOfSize:12.f];
        textLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.6f];
        [self addSubview:textLabel];
        _textLabel = textLabel;
    }
    return _textLabel;
}

#pragma mark - Overwrite
- (void)placeSubviews {
    [super placeSubviews];
    [self.textLabel sizeToFit];
    CGFloat m = 11.f;
    CGFloat x = (self.width_mn - self.indicatorView.width_mn - m - self.textLabel.width_mn)/2.f;
    self.indicatorView.left_mn = x;
    self.textLabel.left_mn = self.indicatorView.right_mn + m;
    self.indicatorView.centerY_mn = self.textLabel.centerY_mn = self.height_mn/2.f;
    [self addSubview:self.textLabel];
    [self addSubview:self.indicatorView];
}

#pragma mark - Setter
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    if (state == MJRefreshStateRefreshing) {
        [self.indicatorView startAnimating];
    }
}

@end
