//
//  WXVideoPlayTopBar.m
//  MNKit
//
//  Created by Vincent on 2018/3/22.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "WXVideoPlayTopBar.h"

@interface WXVideoPlayTopBar()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *lockButton;
@end
@implementation WXVideoPlayTopBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;

        UIImageView *maskView = [UIImageView imageViewWithFrame:self.bounds image:[MNBundle imageForResource:@"mask_top"]];
        maskView.contentMode = UIViewContentModeScaleAspectFill;
        maskView.clipsToBounds = YES;
        maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:maskView];
        
        /**返回*/
        UIButton *backButton = [UIButton buttonWithFrame:CGRectMake(10.f, MEAN(self.height_mn - 30.f - MN_STATUS_BAR_HEIGHT) + MN_STATUS_BAR_HEIGHT, 30.f, 30.f)
                                                   image:[UIImage imageNamed:@"wx_common_back_white"]
                                                   title:nil
                                              titleColor:nil
                                                    titleFont:nil];
        backButton.touchInset = UIEdgeInsetWith(-7.f);
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        /**锁定*/
        UIButton *lockButton = [UIButton buttonWithFrame:backButton.frame
                                                   image:nil
                                                   title:nil
                                              titleColor:nil
                                                    titleFont:nil];
        lockButton.right_mn = self.width_mn - backButton.left_mn;
        lockButton.touchInset = backButton.touchInset;
        lockButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        ///[lockButton setImage:[UIImage imageNamed:@"mnkit_player_video_play"] forState:UIControlStateNormal];
        ///[lockButton setImage:[UIImage imageNamed:@"mnkit_player_video_pause"] forState:UIControlStateSelected];
        ///[lockButton addTarget:self action:@selector(lockButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lockButton];
        self.lockButton = lockButton;
        
        /**标题*/
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(backButton.right_mn + 7.f, MN_STATUS_BAR_HEIGHT, lockButton.left_mn - backButton.right_mn - 14.f, self.height_mn - MN_STATUS_BAR_HEIGHT)
                                                 text:@""
                                            textColor:[UIColor whiteColor]
                                                 font:[UIFont systemFontOfSize:16.f]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

#pragma mark - 返回事件
- (void)backButtonClicked:(UIButton *)backButton {
    if ([_delegate respondsToSelector:@selector(playTopBarBackButtonClicked:)]) {
        [_delegate playTopBarBackButtonClicked:self];
    }
}

#pragma mark - 设置标题
- (void)setTitle:(NSString *)title {
    NSStringReplacingEmpty(&title);
    _title = title.copy;
    _titleLabel.text = title;
}

@end
