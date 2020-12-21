//
//  MNRefreshNormalFooter.m
//  MNKit
//
//  Created by Vincent on 2020/2/11.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNRefreshNormalFooter.h"
#import "MNIndicatorView.h"

@interface MNRefreshNormalFooter ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) MNIndicatorView *indicatorView;
@end

@implementation MNRefreshNormalFooter
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

- (UILabel *)noDataLabel {
    if (!_noDataLabel) {
        UILabel *noDataLabel = [[UILabel alloc] init];
        noDataLabel.hidden = YES;
        noDataLabel.text = @"暂无更多数据";
        noDataLabel.font = [UIFont systemFontOfSize:13.f];
        noDataLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.6f];
        _noDataLabel = noDataLabel;
    }
    return _noDataLabel;
}

#pragma mark - Overwrite
- (void)placeSubviews {
    [super placeSubviews];
    [self.noDataLabel sizeToFit];
    self.noDataLabel.center_mn = self.bounds_center;
    [self.textLabel sizeToFit];
    CGFloat m = 11.f;
    CGFloat x = (self.width_mn - self.indicatorView.width_mn - m - self.textLabel.width_mn)/2.f;
    self.indicatorView.left_mn = x;
    self.textLabel.left_mn = self.indicatorView.right_mn + m;
    self.indicatorView.centerY_mn = self.textLabel.centerY_mn = self.height_mn/2.f;
    self.noDataLabel.hidden = self.state != MJRefreshStateNoMoreData;
    self.textLabel.hidden = self.indicatorView.hidden = !self.noDataLabel.hidden;
    [self addSubview:self.textLabel];
    [self addSubview:self.noDataLabel];
    [self addSubview:self.indicatorView];
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    if (state == MJRefreshStateRefreshing) {
        [self.indicatorView startAnimating];
    }
    self.noDataLabel.hidden = state != MJRefreshStateNoMoreData;
    self.textLabel.hidden = self.indicatorView.hidden = !self.noDataLabel.hidden;
}

@end
