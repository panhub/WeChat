//
//  WXQRCodeViewController.m
//  MNChat
//
//  Created by Vincent on 2019/4/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXQRCodeViewController.h"
#import "WXJHRequest.h"

NSString * const WXQRCodeMetadataPrefix = @"com.wx.qrcode.metadata.prefix";

@interface WXQRCodeViewController ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSDictionary *dataSource;
@end

@implementation WXQRCodeViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"我的二维码";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = VIEW_COLOR;
    self.navigationBar.rightItemImage = [UIImage imageNamed:@"wx_common_more_black"];
    self.navigationBar.rightBarItem.touchInset = UIEdgeInsetWith(-5.f);
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(20.f, 55.f, self.contentView.width_mn - 40.f, self.contentView.height_mn - 165.f)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 8.f;
    backgroundView.clipsToBounds = YES;
    [self.contentView addSubview:backgroundView];
    
    
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(20.f, 20.f, 65.f, 65.f)
                                                      image:[[WXUser shareInfo] avatar]];
    headView.layer.cornerRadius = 6.f;
    headView.clipsToBounds = YES;
    [backgroundView addSubview:headView];
    
    UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(headView.right_mn + 10.f, headView.top_mn + 10.f, 0.f, 20.f)
                                            text:[[WXUser shareInfo] nickname]
                                       textColor:[UIColor blackColor]
                                            font:UIFontWithNameSize(MNFontNameMedium, MNFontSizeTitle)];
    [nameLabel sizeToFit];
    [backgroundView addSubview:nameLabel];
    
    UIImageView *genderView = [UIImageView imageViewWithFrame:CGRectMake(nameLabel.right_mn + 5.f, 0.f, 0.f, 18.f)
                                                        image:nil];
    genderView.centerY_mn = nameLabel.centerY_mn;
    genderView.clipsToBounds = YES;
    [backgroundView addSubview:genderView];
    if ([WXUser shareInfo].gender == WechatGenderUnknown) {
        genderView.width_mn = 0.f;
    } else {
        genderView.width_mn = genderView.height_mn;
        genderView.image = [UIImage imageNamed:([WXUser shareInfo].gender == WechatGenderMale ? @"wx_contacts_gender_male" : @"wx_contacts_gender_female")];
    }
    
    UILabel *locationLabel = [UILabel labelWithFrame:CGRectMake(nameLabel.left_mn, nameLabel.bottom_mn + 5.f, 0.f, 13.f)
                                                text:[[WXUser shareInfo] location]
                                           textColor:UIColorWithAlpha([UIColor darkGrayColor], .65f)
                                                font:UIFontRegular(13.f)];
    [locationLabel sizeToFit];
    [backgroundView addSubview:locationLabel];
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(headView.left_mn, headView.bottom_mn + 10.f, backgroundView.width_mn - headView.left_mn*2.f, backgroundView.width_mn - headView.left_mn*2.f)
                                                       image:nil];
    [imageView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
    [backgroundView addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(0.f, imageView.bottom_mn - 5.f, backgroundView.width_mn, backgroundView.height_mn - imageView.bottom_mn)
                                            text:@"扫一扫上面的二维码, 加我为好友"
                                   alignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor darkGrayColor], .65f)
                                            font:UIFontRegular(13.f)];
    [backgroundView addSubview:hintLabel];
}

- (void)loadData {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSString replacingEmptyCharacters:[[WXUser shareInfo] uid]] forKey:@"uid"];
    [dic setObject:[NSString replacingEmptyCharacters:[[WXUser shareInfo] phone]] forKey:@"phone"];
    [dic setObject:[NSString replacingEmptyCharacters:[[WXUser shareInfo] location]] forKey:@"location"];
    [dic setObject:[NSString replacingEmptyCharacters:[[WXUser shareInfo] wechatId]] forKey:@"wechatId"];
    [dic setObject:[NSString replacingEmptyCharacters:[[WXUser shareInfo] nickname]] forKey:@"nickname"];
    self.dataSource = dic.copy;
    [self createQRCodeWithColor:[UIColor blackColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Event
- (void)handTap:(UIGestureRecognizer *)recognizer {
    MNAsset *asset = [MNAsset assetWithContent:self.imageView.image];
    asset.containerView = self.imageView;
    MNAssetBrowser *browser = [MNAssetBrowser new];
    browser.assets = @[asset];
    browser.backgroundColor = [UIColor blackColor];
    [browser presentInView:self.view fromIndex:0 animated:YES completion:nil];
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        @strongify(self);
        if (buttonIndex == 0) {
            [self createQRCodeWithColor:UIColorRandom()];
        } else {
            [MNAssetHelper writeImageToAlbum:self.imageView.image completionHandler:^(NSString * _Nullable identifier, NSError * _Nullable error) {
                if (error || identifier.length <= 0) {
                    [self.view showInfoDialog:@"保存失败"];
                } else {
                    MNAlertView *alertView = [MNAlertView alertViewWithTitle:@"提示" image:self.imageView.image message:@"已成功保存二维码" handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView resizingImageToHeight:100.f];
                    [alertView show];
                }
            }];
        }
    } otherButtonTitles:@"换个颜色", @"保存图片", nil] show];
}

- (void)createQRCodeWithColor:(UIColor *)color {
    [MNQRGenerator generateCodeWithMetadata:[self.dataSource.JsonString stringByInsertString:WXQRCodeMetadataPrefix atIndex:0].JsonData pixel:400.f completion:^(UIImage * _Nonnull image) {
        self.imageView.image = image;
    }];
}

@end
