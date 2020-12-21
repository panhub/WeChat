//
//  WXMomentProfileView.m
//  MNChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentProfileView.h"
#import "WXMomentRemindView.h"
#import "WXMomentProfileViewModel.h"

@interface WXMomentProfileView ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) WXMomentRemindView *remindView;
@property (nonatomic, strong) WXMomentProfileViewModel *viewModel;
@end

#define WXMomentHeaderBackgroundViewKey @"com.wx.moment.header.background.view.key"

@implementation WXMomentProfileView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /// 黑色背景
        self.imageView.image = UIImageWithColor(UIColorWithSingleRGB(51.f));
        
        /// 主题图
        UIImageView *coverView = [UIImageView imageViewWithFrame:CGRectMake(0.f, -100.f, self.contentView.width_mn, 420.f)
                                                                image:nil];
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        coverView.clipsToBounds = YES;
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        
        _offsetY = coverView.bottom_mn;
        
        /// 头像
        UIButton *headButton = [UIButton buttonWithFrame:CGRectMake(self.contentView.width_mn - 78.f, coverView.bottom_mn - 47.f, 67.f, 67.f)
                                                 image:nil
                                                   title:nil
                                              titleColor:nil
                                               titleFont:nil];
        UIViewSetCornerRadius(headButton, 8.f);
        [self.contentView addSubview:headButton];
        self.headButton = headButton;
        
        /// 昵称
        UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(15.f, MEAN(coverView.bottom_mn - headButton.top_mn - 20.f) + headButton.top_mn, headButton.left_mn - 40.f, 20.f)
                                                text:nil
                                       alignment:NSTextAlignmentRight
                                           textColor:[UIColor whiteColor]
                                                font:[UIFont systemFontOfSizes:20.f weights:.2f]];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        self.height_mn = headButton.bottom_mn + 30.f;
        
        /// 白色遮罩为了遮挡黑色背景
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0.f, coverView.bottom_mn, self.contentView.width_mn, self.contentView.height_mn - coverView.bottom_mn)];
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.contentView insertSubview:maskView belowSubview:headButton];
        
        [self handEvents];
    }
    return self;
}

#pragma mark - 事件处理
- (void)handEvents {
    @weakify(self);
    /// 修改用户信息
    [self.headButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        UIViewController *vc = [NSClassFromString(@"WXMineInfoController") new];
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }];
    /// 修改封面
    [self.coverView handTapConfiguration:nil eventHandler:^(id sender) {
        [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            MNAssetPicker *picker = [MNAssetPicker picker];
            picker.configuration.allowsPickingGif = NO;
            picker.configuration.allowsPickingVideo = NO;
            picker.configuration.allowsPickingLivePhoto = NO;
            picker.configuration.cropScale = 1.f;
            picker.configuration.allowsEditing = YES;
            [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
                if (assets.count <= 0) return;
                @strongify(self);
                UIImage *image = assets.firstObject.content;
                image = [image resizingToPix:500.f];
                if (image) {
                    [[NSUserDefaults standardUserDefaults] setImage:image forKey:WXMomentHeaderBackgroundViewKey];
                    self.coverView.image = image;
                } else {
                    [self.viewController.view showInfoDialog:@"图片资源错误"];
                }
            } cancelHandler:nil];
        } otherButtonTitles:@"更换相册封面", nil] show];
    }];
}

#pragma mark - 绑定视图模型
- (void)bindViewModel:(WXMomentProfileViewModel *)viewModel {
    self.viewModel = viewModel;
    @weakify(self);
    viewModel.reloadRemindHandler = ^{
        @PostNotify(WXMomentRemindReloadNotificationName, nil);
        @strongify(self);
        if (self.viewModel.reminds.count) {
            WXMomentRemind *remind = self.viewModel.reminds.lastObject;
            self.remindView.uid = remind.from_uid;
            self.remindView.desc = NSStringWithFormat(@"%@条新消息", @(self.viewModel.reminds.count));
            if (!self.remindView.superview) {
                self.height_mn = self.remindView.bottom_mn + 15.f;
                [self addSubview:self.remindView];
                [self addSubview:self.separator];
                if (self.viewModel.reloadProfileHandler) {
                    self.viewModel.reloadProfileHandler();
                }
            }
        } else {
            if (_remindView.superview) {
                [_remindView removeFromSuperview];
                [_separator removeFromSuperview];
                self.height_mn = _remindView.top_mn - 10.f;
                if (self.viewModel.reloadProfileHandler) {
                    self.viewModel.reloadProfileHandler();
                }
            }
        }
    };
}

#pragma mark - 更新用户数据
- (void)updateUserInfo {
    self.nameLabel.text = [[WXUser shareInfo] nickname];
    self.coverView.image = [[NSUserDefaults standardUserDefaults] imageForKey:WXMomentHeaderBackgroundViewKey def:UIImageNamed(@"wx_moment_header")];
    [self.headButton setBackgroundImage:[[WXUser shareInfo] avatar] forState:UIControlStateNormal];
}

#pragma mark - 更新提醒数据
- (void)updateRemind {
    
}

#pragma mark - Getter
- (UIImageView *)separator {
    if (!_separator) {
        UIImageView *separator = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        [self addSubview:separator];
        separator.sd_layout
        .leftEqualToView(self)
        .rightEqualToView(self)
        .bottomEqualToView(self)
        .heightIs(WXMomentSeparatorHeight);
        _separator = separator;
    }
    return _separator;
}

- (WXMomentRemindView *)remindView {
    if (!_remindView) {
        _remindView = [WXMomentRemindView new];
        _remindView.top_mn = self.height_mn + 10.f;
        _remindView.centerX_mn = self.width_mn/2.f;
        @weakify(self);
        [_remindView handTapConfiguration:nil eventHandler:^(id sender) {
            @strongify(self);
            if (self.viewModel.remindViewEventHandler) {
                self.viewModel.remindViewEventHandler();
            }
        }];
    }
    return _remindView;
}

@end
