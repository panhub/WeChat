//
//  SENavigationBar.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SENavigationBar.h"
#import "UIView+SEFrame.h"

#define SENavigationBarTitleFontSize    17.f

@interface SENavigationBar ()
@property (nonatomic) SENavigationType type;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIControl *backButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *ensureButton;
@end

@implementation SENavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, .5f)];
        separator.bottom_mn = self.height_mn;
        separator.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:.25f];
        [self addSubview:separator];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.closeButton];
        self.backButton.alpha = 0.f;
        [self addSubview:self.backButton];
        self.ensureButton.alpha = 0.f;
        [self addSubview:self.ensureButton];
    }
    return self;
}

#pragma mark - Event
- (void)leftBarButtonClicked:(UIButton *)leftBarButton {
    if ([self.delegate respondsToSelector:@selector(navigationBarLeftBarButtonClicked:)]) {
        [self.delegate navigationBarLeftBarButtonClicked:self];
    }
}

- (void)rightBarButtonClicked:(UIButton *)rightBarButton {
    if ([self.delegate respondsToSelector:@selector(navigationBarRightBarButtonClicked:)]) {
        [self.delegate navigationBarRightBarButtonClicked:self];
    }
}

- (void)setNavigationType:(SENavigationType)type animated:(BOOL)animated {
    if (type == self.type) return;
    [UIView animateWithDuration:(animated ? .3f : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (type == SENavigationTypeSession) {
            self.titleLabel.text = @"发送给朋友";
            self.backButton.alpha = 1.f;
            self.closeButton.alpha = self.ensureButton.alpha = 0.f;
        } else if (type == SENavigationTypeMoment) {
            self.titleLabel.text = @"分享到朋友圈";
            self.closeButton.alpha = 0.f;
            self.backButton.alpha = self.ensureButton.alpha = 1.f;
        } else {
            self.titleLabel.text = @"微信";
            self.closeButton.alpha = 1.f;
            self.backButton.alpha = self.ensureButton.alpha = 0.f;
        }
    } completion:^(BOOL finished) {
        self.type = type;
    }];
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:SENavigationBarTitleFontSize];
        titleLabel.textColor = UIColor.blackColor;
        titleLabel.text = @"微信";
        titleLabel.width_mn = 150.f;
        titleLabel.height_mn = SENavigationBarTitleFontSize;
        titleLabel.centerX_mn = self.width_mn/2.f;
        titleLabel.centerY_mn = self.height_mn/2.f + 5.f;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:SENavigationBarTitleFontSize];
        [closeButton sizeToFit];
        closeButton.left_mn = 13.f;
        closeButton.width_mn += 10.f;
        closeButton.height_mn = 30.f;
        closeButton.centerY_mn = self.titleLabel.centerY_mn;
        closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [closeButton setTitleColor:[UIColor.darkTextColor colorWithAlphaComponent:.9f] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton = closeButton;
    }
    return _closeButton;
}

- (UIControl *)backButton {
    if (!_backButton) {
        UIControl *backButton = [[UIControl alloc] init];
        backButton.height_mn = self.closeButton.height_mn;
        UIImageView *backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ext_share_back"]];
        backView.size_mn = CGSizeMultiplyToHeight(backView.image.size, SENavigationBarTitleFontSize);
        backView.centerY_mn = backButton.height_mn/2.f;
        backView.userInteractionEnabled = NO;
        [backButton addSubview:backView];
        UILabel *backLabel = [[UILabel alloc] init];
        backLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:SENavigationBarTitleFontSize];
        backLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.9f];
        backLabel.text = @"返回";
        [backLabel sizeToFit];
        backLabel.left_mn = backView.right_mn + 3.f;
        backLabel.height_mn = SENavigationBarTitleFontSize;
        backLabel.centerY_mn = backButton.height_mn/2.f;
        [backButton addSubview:backLabel];
        backButton.width_mn = backLabel.right_mn;
        backButton.left_mn = self.closeButton.left_mn;
        backButton.centerY_mn = self.closeButton.centerY_mn;
        self.closeButton.left_mn = backButton.left_mn + backLabel.left_mn;
        [backButton addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _backButton = backButton;
    }
    return _backButton;
}

- (UIButton *)ensureButton {
    if (!_ensureButton) {
        UIButton *ensureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ensureButton setTitle:@"确定" forState:UIControlStateNormal];
        ensureButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:SENavigationBarTitleFontSize];
        [ensureButton sizeToFit];
        ensureButton.right_mn = self.width_mn - self.closeButton.left_mn;
        ensureButton.width_mn += 10.f;
        ensureButton.height_mn = 30.f;
        ensureButton.centerY_mn = self.titleLabel.centerY_mn;
        ensureButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        ensureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [ensureButton setTitleColor:[UIColor colorWithRed:7.f/255.f green:192.f/255.f blue:96.f/255.f alpha:1.f] forState:UIControlStateNormal];
        [ensureButton addTarget:self action:@selector(rightBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _ensureButton = ensureButton;
    }
    return _ensureButton;
}

@end
