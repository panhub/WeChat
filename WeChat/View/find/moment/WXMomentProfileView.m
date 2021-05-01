//
//  WXMomentProfileView.m
//  WeChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentProfileView.h"
#import "WXTimelineViewModel.h"
#import "WXTimeline.h"
#import "WXNotifyView.h"

@interface WXMomentProfileView ()
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) WXNotifyView *notifyView;
@property (nonatomic, strong) WXTimelineViewModel *viewModel;
@end

#define WXMomentCoverPath [WechatHelper.helper.momentPath stringByAppendingPathComponent:@"moment_cover.jpg"]

@implementation WXMomentProfileView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /// 黑色背景
        self.imageView.image = [UIImage imageWithColor:MN_RGB(51.f)];
        
        /// 主题图
        UIImageView *coverView = [UIImageView imageViewWithFrame:CGRectMake(0.f, -100.f, self.contentView.width_mn, 420.f) image:nil];
        coverView.clipsToBounds = YES;
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        
        self.offsetY = coverView.bottom_mn;
        
        /// 头像
        UIButton *avatarButton = [UIButton buttonWithFrame:CGRectMake(self.contentView.width_mn - 78.f, coverView.bottom_mn - 47.f, 67.f, 67.f) image:nil title:nil titleColor:nil titleFont:nil];
        UIViewSetCornerRadius(avatarButton, 8.f);
        [self.contentView addSubview:avatarButton];
        self.avatarButton = avatarButton;
        
        /// 昵称
        UILabel *nickLabel = [UILabel labelWithFrame:CGRectMake(17.f, (coverView.bottom_mn - avatarButton.top_mn)/2.f + avatarButton.top_mn, 0.f, 0.f)
                                                text:nil
                                       alignment:NSTextAlignmentRight
                                           textColor:[UIColor whiteColor]
                                                font:[UIFont systemFontOfSizes:18.f weights:MNFontWeightMedium]];
        nickLabel.numberOfLines = 1;
        [self.contentView addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        self.height_mn = avatarButton.bottom_mn + 30.f;
        
        /// 白色遮罩为了遮挡黑色背景
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0.f, coverView.bottom_mn, self.contentView.width_mn, self.contentView.height_mn - coverView.bottom_mn)];
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.contentView insertSubview:maskView belowSubview:avatarButton];
        
        WXNotifyView *notifyView = [WXNotifyView new];
        notifyView.hidden = YES;
        notifyView.top_mn = self.contentView.height_mn + 10.f;
        notifyView.centerX_mn = self.contentView.width_mn/2.f;
        [self.contentView addSubview:notifyView];
        self.notifyView = notifyView;
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_more_line"]];
        separator.hidden = YES;
        separator.height_mn = WXMomentSeparatorHeight;
        separator.width_mn = self.contentView.width_mn;
        separator.bottom_mn = self.contentView.height_mn;
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:separator];
        self.separator = separator;
        
        [self handEvents];
    }
    return self;
}

#pragma mark - 事件处理
- (void)handEvents {
    @weakify(self);
    // 头像点击事件
    [self.avatarButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        UIViewController *vc = [NSClassFromString(@"WXMineInfoController") new];
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }];
    // 通知视图
    [self.notifyView handTapEventHandler:^(id  _Nonnull sender) {
        @strongify(self);
        if (self.viewModel.notifyViewEventHandler) {
            self.viewModel.notifyViewEventHandler();
        }
    }];
    // 修改封面
    [self.coverView handTapConfiguration:nil eventHandler:^(id sender) {
        [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            MNAssetPicker *picker = [MNAssetPicker picker];
            picker.configuration.cropScale = 1.f;
            picker.configuration.allowsEditing = YES;
            picker.configuration.allowsPickingGif = YES;
            picker.configuration.allowsPickingVideo = NO;
            picker.configuration.allowsPickingPhoto = YES;
            picker.configuration.allowsPickingLivePhoto = YES;
            picker.configuration.allowsOptimizeExporting = YES;
            picker.configuration.requestGifUseingPhotoPolicy = YES;
            picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
            [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
                @strongify(self);
                UIImage *image = assets.firstObject.content;
                if (image) {
                    self.coverView.image = image;
                    [MNFileHandle writeImage:image toFile:WXMomentCoverPath error:nil];
                } else {
                    [self.viewController.view showInfoDialog:@"图片资源错误"];
                }
            } cancelHandler:nil];
        } otherButtonTitles:@"更换相册封面", nil] show];
    }];
}

#pragma mark - 绑定视图模型
- (void)bindViewModel:(WXTimelineViewModel *)viewModel {
    self.viewModel = viewModel;
    @weakify(self);
    viewModel.reloadNotifyHandler = ^{
        @strongify(self);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY timestamp DESC;", WXMomentNotifyTableName];
        NSArray <WXNotify *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentNotifyTableName sql:sql class:WXNotify.class];
        if (rows.count) {
            self.notifyView.title = NSStringWithFormat(@"%@条新消息", @(rows.count));
            self.notifyView.avatar = [[WechatHelper.helper userForUid:rows.firstObject.from_uid] avatar];
            if (self.notifyView.isHidden) {
                self.height_mn = self.notifyView.bottom_mn + 15.f;
                self.separator.hidden = self.notifyView.hidden = NO;
                if (self.viewModel.reloadProfileHandler) {
                    self.viewModel.reloadProfileHandler();
                }
            }
        } else {
            if (!self.notifyView.isHidden) {
                self.height_mn = self.notifyView.top_mn - 10.f;
                self.separator.hidden = self.notifyView.hidden = YES;
                if (self.viewModel.reloadProfileHandler) {
                    self.viewModel.reloadProfileHandler();
                }
            }
        }
        @PostNotify(WXMomentNotifyReloadNotificationName, nil);
    };
}

#pragma mark - 更新用户数据
- (void)updateUserInfo {
    
    CGFloat y = self.nickLabel.centerY_mn;
    self.nickLabel.text = WXUser.shareInfo.nickname;
    [self.nickLabel sizeToFit];
    self.nickLabel.width_mn = MIN(self.nickLabel.width_mn, self.avatarButton.left_mn - 40.f);
    self.nickLabel.right_mn = self.avatarButton.left_mn - 25.f;
    self.nickLabel.centerY_mn = y;

    self.coverView.image = [UIImage imageWithContentsOfFile:WXMomentCoverPath] ? : [UIImage imageNamed:@"wx_moment_header"];
    
    [self.avatarButton setBackgroundImage:WXUser.shareInfo.avatar forState:UIControlStateNormal];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.separator.bottom_mn = self.contentView.height_mn;
}

@end
