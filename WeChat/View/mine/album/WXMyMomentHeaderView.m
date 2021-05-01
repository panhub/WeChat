//
//  WXMyMomentHeaderView.m
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyMomentHeaderView.h"

@interface WXMyMomentHeaderView ()
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *signatureLabel;
@end

#define WXMomentCoverPath   [WechatHelper.helper.momentPath stringByAppendingPathComponent:@"moment_cover.jpg"]

@implementation WXMyMomentHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /// 黑色背景
        self.imageView.image = [UIImage imageNamed:@"album_list_bkg"];
        
        /// 主题图
        UIImageView *coverView = [UIImageView imageViewWithFrame:CGRectMake(0.f, -100.f, self.contentView.width_mn, 420.f) image:nil];
        coverView.clipsToBounds = YES;
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        
        /// 白色遮罩为了遮挡黑色背景
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0.f, coverView.bottom_mn, self.contentView.width_mn, 0.f)];
        maskView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:maskView];
        
        /// 头像
        UIButton *avatarButton = [UIButton buttonWithFrame:CGRectMake(self.contentView.width_mn - 78.f, coverView.bottom_mn - 47.f, 67.f, 67.f) image:nil title:nil titleColor:nil titleFont:nil];
        UIViewSetCornerRadius(avatarButton, 8.f);
        [self.contentView addSubview:avatarButton];
        self.avatarButton = avatarButton;
        
        /// 昵称
        UILabel *nickLabel = [UILabel labelWithFrame:CGRectMake(0.f, (coverView.bottom_mn - avatarButton.top_mn)/2.f + avatarButton.top_mn, 0.f, 0.f)
                                                text:nil
                                       alignment:NSTextAlignmentRight
                                           textColor:UIColor.whiteColor
                                                font:[UIFont systemFontOfSizes:18.f weights:MNFontWeightMedium]];
        nickLabel.numberOfLines = 1;
        [self.contentView addSubview:nickLabel];
        self.nickLabel = nickLabel;
        
        /// 签名
        UILabel *signatureLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:[UIColor.darkGrayColor colorWithAlphaComponent:.85f] font:[UIFont systemFontOfSize:15.f]];
        signatureLabel.width_mn = self.contentView.width_mn - 22.f;
        signatureLabel.left_mn = 11.f;
        signatureLabel.top_mn = avatarButton.bottom_mn + 15.f;
        signatureLabel.numberOfLines = 1;
        [self.contentView addSubview:signatureLabel];
        self.signatureLabel = signatureLabel;
        
        maskView.height_mn = signatureLabel.centerY_mn + 35.f - coverView.bottom_mn;
        
        self.height_mn = maskView.bottom_mn;
        
        self.offsetY = avatarButton.bottom_mn - MN_TOP_BAR_HEIGHT;
    }
    return self;
}

- (void)handEvents {
    @weakify(self);
    /// 修改用户信息
    [self.avatarButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        UIViewController *vc = [NSClassFromString(@"WXMineInfoController") new];
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }];
    /// 修改封面
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

#pragma mark - Setter
- (void)setUser:(WXUser *)user {
    
    _user = user;
    
    CGFloat y = self.nickLabel.centerY_mn;
    self.nickLabel.text = user.nickname;
    [self.nickLabel sizeToFit];
    self.nickLabel.width_mn = MIN(self.nickLabel.width_mn, self.avatarButton.left_mn - 40.f);
    self.nickLabel.right_mn = self.avatarButton.left_mn - 25.f;
    self.nickLabel.centerY_mn = y;
    
    CGFloat x = self.contentView.width_mn - self.avatarButton.right_mn;
    self.signatureLabel.text = user.signature;
    [self.signatureLabel sizeToFit];
    self.signatureLabel.width_mn = MIN(self.signatureLabel.width_mn, self.contentView.width_mn - x*2.f);
    self.signatureLabel.right_mn = self.avatarButton.right_mn;
    
    [self.avatarButton setBackgroundImage:user.avatar forState:UIControlStateNormal];
    
    self.coverView.image = [UIImage imageWithContentsOfFile:WXMomentCoverPath] ? : [UIImage imageNamed:@"album_moment_profile"];
}

@end
