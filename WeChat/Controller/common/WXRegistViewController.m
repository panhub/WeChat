//
//  WXRegistViewController.m
//  MNChat
//
//  Created by Vincent on 2019/3/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRegistViewController.h"

@interface WXRegistViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation WXRegistViewController

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = self.contentView.backgroundColor;
    self.navigationBar.shadowView.hidden = YES;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.userInteractionEnabled = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *registView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, scrollView.width_mn - 80.f, 0.f)];
    registView.centerX_mn = self.contentView.width_mn/2.f;
    registView.backgroundColor = self.contentView.backgroundColor;
    [scrollView addSubview:registView];
    
    UIButton *avatarButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 70.f, 70.f)
                                               image:UIImageNamed(@"select_avatar")
                                               title:nil
                                          titleColor:nil
                                                titleFont:nil];
    avatarButton.centerX_mn = registView.width_mn/2.f;
    [avatarButton addTarget:self action:@selector(selectAvatar) forControlEvents:UIControlEventTouchUpInside];
    [registView addSubview:avatarButton];
    self.avatarButton = avatarButton;
    
    __block CGFloat y = avatarButton.bottom_mn + 35.f;
    NSArray <NSString *>*titleArray = @[@"账号", @"密码"];
    NSArray <NSString *>*placeArray = @[@"建议使用手机号码", @"请输入密码"];
    [titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(0.f, y, registView.width_mn, 30.f)
                                                            font:UIFontRegular(17.f)
                                                     placeholder:placeArray[idx]
                                                        delegate:self];
        textField.tintColor = THEME_COLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholderColor = UIColorWithAlpha([UIColor grayColor], .4f);
        textField.placeholderFont = UIFontRegular(17.f);
        [registView addSubview:textField];
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:title textColor:UIColor.darkTextColor font:UIFontWithNameSize(MNFontNameMedium, 19.f)];
        titleLabel.numberOfLines = 1;
        [titleLabel sizeToFit];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, titleLabel.width_mn + 13.f, textField.height_mn)];
        titleLabel.centerY_mn = leftView.height_mn/2.f;
        [leftView addSubview:titleLabel];
        
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.leftView = leftView;
        
        UIImageView *separator = [UIImageView imageViewWithFrame:CGRectMake(0.f, textField.bottom_mn, registView.width_mn, MN_SEPARATOR_HEIGHT)
                                                        image:[UIImage imageWithColor:UIColorWithAlpha([UIColor grayColor], .33f)]];
        separator.contentMode = UIViewContentModeScaleAspectFill;
        separator.clipsToBounds = YES;
        [registView addSubview:separator];
        
        y = separator.bottom_mn + 28.f;
        
        if (idx == 0) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            self.usernameField = textField;
        } else {
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeNamePhonePad;
            self.passwordField = textField;
        }
    }];
    
    registView.height_mn = self.passwordField.bottom_mn + 1.f;
    registView.bottom_mn = self.contentView.height_mn/2.f;
    
    UIButton *registButton = [UIButton buttonWithFrame:CGRectMake(registView.left_mn, registView.bottom_mn + 35.f, registView.width_mn, 44.f)
                                                 image:[UIImage imageWithColor:THEME_COLOR]
                                                 title:@"注册"
                                            titleColor:[UIColor whiteColor]
                                                  titleFont:UIFontMedium(17.f)];
    UIViewSetCornerRadius(registButton, 5.f);
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:registButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self.scrollView handTapEventHandler:^(id sender) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
}

- (void)regist {
    [self.view endEditing:YES];
    UIImage *avatar = [self.avatarButton backgroundImageForState:UIControlStateSelected];
    if (!avatar || !self.avatarButton.isSelected) {
        [self.view showInfoDialog:@"请设置头像"];
        return;
    }
    NSString *username = self.usernameField.text;
    if (username.length < 5) {
        [self.view showInfoDialog:@"用户名不低于5位字符"];
        return;
    }
    NSString *password = self.passwordField.text;
    if (password.length < 5) {
        [self.view showInfoDialog:@"密码不低于5位字符"];
        return;
    }
    @weakify(self);
    __block WXUser *user = nil;
    __block BOOL isExist = NO;
    [self.view showWechatDialogDelay:1.f eventHandler:^{
        // 查找用户是否存在
        user = [WXUser userWithInfo:[WXUser userInfoWithUsername:username]];
        if (user) {
            isExist = YES;
            return;
        }
        // 创建新用户
        WXUser *u = WechatHelper.user;
        u.username = username;
        u.password = password;
        u.nickname = username;
        u.avatarString = avatar.PNGBase64Encoding;
        if ([WXUser setUserInfoToKeychain:u.JsonValue]) user = u;
    } completionHandler:^{
        @strongify(self);
        if (isExist) {
            [self.view showInfoDialog:@"用户已存在"];
        } else if (!user) {
            [self.view showInfoDialog:@"注册失败"];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)selectAvatar {
    @weakify(self);
    [self.view endEditing:YES];
    [[MNActionSheet actionSheetWithTitle:@"设置头像" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        MNAssetPicker *picker = [MNAssetPicker picker];
        picker.configuration.cropScale = 1.f;
        picker.configuration.maxPickingCount = 1;
        picker.configuration.maxExportPixel = 40000;
        picker.configuration.allowsTakeAsset = NO;
        picker.configuration.allowsPreviewing = NO;
        picker.configuration.allowsOriginalExporting = NO;
        picker.configuration.allowsEditing = YES;
        picker.configuration.allowsPickingGif = YES;
        picker.configuration.allowsPickingVideo = NO;
        picker.configuration.allowsPickingPhoto = YES;
        picker.configuration.allowsPickingLivePhoto = YES;
        picker.configuration.requestGifUseingPhotoPolicy = YES;
        picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
        [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
            @strongify(self);
            UIImage *image = assets.firstObject.content;
            self.avatarButton.selected = YES;
            [self.avatarButton setBackgroundImage:image forState:UIControlStateSelected];
        } cancelHandler:nil];
    } otherButtonTitles:@"打开相册", nil] showInView:self.view];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string rangeOfString:@" "].location != NSNotFound || [string rangeOfString:@"\n"].location != NSNotFound) return NO;
    if (textField == self.usernameField) {
        return range.location + string.length <= 11;
    }
    return range.location + string.length <= 15;
}

#pragma mark - Overwrite
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
