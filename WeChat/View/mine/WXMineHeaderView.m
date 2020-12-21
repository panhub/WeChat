//
//  WXMineHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineHeaderView.h"

@interface WXMineHeaderView ()
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIImageView *headView;
@end

@implementation WXMineHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(self.contentView.width_mn - 37.f, MN_STATUS_BAR_HEIGHT + MEAN(MN_NAV_BAR_HEIGHT - 22.f), 22.f, 22.f);
    [rightButton setImage:UIImageNamed(@"wx_mine_camera_black") forState:UIControlStateNormal];
    rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    rightButton.touchInset = UIEdgeInsetWith(-10.f);
    [self.contentView addSubview:rightButton];
    self.rightButton = rightButton;
    
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(25.f, MN_TOP_BAR_HEIGHT + 30.f, 65.f, 65.f)
                                                      image:nil];
    headView.layer.cornerRadius = 6.f;
    headView.clipsToBounds = YES;
    headView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:headView];
    self.headView = headView;
    
    UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(headView.right_mn + 20.f, headView.top_mn + 3.f, self.contentView.width_mn - headView.right_mn - 40.f, 26.f)
                                            text:nil
                                       textColor:[UIColor blackColor]
                                            font:UIFontWithNameSize(MNFontNameMedium, 23.f)];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *idLabel = [UILabel labelWithFrame:CGRectMake(nameLabel.left_mn, headView.bottom_mn - 5.f - 17.f, 0.f, 17.f)
                                          text:nil
                                     textColor:UIColorWithAlpha([UIColor blackColor], .5f)
                                          font:[UIFont systemFontOfSize:17.f]];
    [self.contentView addSubview:idLabel];
    self.idLabel = idLabel;
    
    UIImage *image = UIImageNamed(@"wx_common_list_arrow");
    CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
    UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height)
                                                       image:image];
    arrowView.centerY_mn = idLabel.centerY_mn;
    [self.contentView addSubview:arrowView];
    
    UIImageView *qrcodeView = [UIImageView imageViewWithFrame:CGRectMake(arrowView.left_mn - 30.f, 0.f, 17.f, 17.f)
                                                       image:UIImageNamed(@"wx_mine_qrcode")];
    qrcodeView.centerY_mn = idLabel.centerY_mn;
    [self.contentView addSubview:qrcodeView];
    
    idLabel.width_mn = qrcodeView.left_mn - idLabel.left_mn - 8.f;
    
    self.height_mn = headView.bottom_mn + 40.f;
    
    @weakify(self);
    [self.headView handTapEventHandler:^(id sender) {
        @strongify(self);
        [MNAssetBrowser presentContainer:self.headView];
    }];
}

- (void)updateUserInfo {
    if (![WXUser isLogin]) return;
    WXUser *user = [WXUser shareInfo];
    self.headView.image = user.avatar;
    self.nameLabel.text = user.nickname;
    self.idLabel.text = NSStringWithFormat(@"微信号: %@", [NSString replacingEmptyCharacters:user.wechatId]);
}

@end
