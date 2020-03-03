//
//  MNRegistViewController.m
//  MNChat
//
//  Created by Vincent on 2019/3/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNRegistViewController.h"

@interface MNRegistViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation MNRegistViewController

- (void)createView {
    [super createView];
    self.navigationBar.shadowColor = [UIColor clearColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.userInteractionEnabled = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIButton *headButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 70.f, 70.f)
                                               image:UIImageNamed(@"wx_mine_select_avatar")
                                               title:nil
                                          titleColor:nil
                                                titleFont:nil];
    headButton.centerX_mn = scrollView.bounds_center.x;
    headButton.bottom_mn = MEAN_3(scrollView.height_mn);
    @weakify(self);
    [headButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        [self.contentView endEditing:YES];
        [self selectHeadImage];
    }];
    [scrollView addSubview:headButton];
    self.headButton = headButton;
    
    NSArray <NSString *>*titleArray = @[@"账号", @"密码"];
    NSArray <NSString *>*placeArray = @[@"建议使用手机号码", @"请输入密码"];
    __block CGFloat y = headButton.bottom_mn + 40.f;
    CGFloat x = self.navigationBar.leftBarItem.right_mn;
    [titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(x, y, 48.f, 20.f) text:title textColor:[UIColor darkTextColor] font:UIFontWithNameSize(MNFontNameMedium, 20.f)];
        [scrollView addSubview:titleLabel];
        
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(titleLabel.right_mn, titleLabel.top_mn, scrollView.width_mn - titleLabel.right_mn - titleLabel.left_mn, titleLabel.height_mn)
                                                            font:UIFontRegular(18.f)
                                                     placeholder:placeArray[idx]
                                                        delegate:self];
        textField.tintColor = THEME_COLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholderColor = UIColorWithAlpha([UIColor grayColor], .4f);
        textField.placeholderFont = UIFontRegular(16.f);
        [scrollView addSubview:textField];
        
        UIImageView *shadow = [UIImageView imageViewWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 5.f, scrollView.width_mn - titleLabel.left_mn*2.f, MN_SEPARATOR_HEIGHT) image:[UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .2f)]];
        shadow.contentMode = UIViewContentModeScaleAspectFill;
        shadow.clipsToBounds = YES;
        [scrollView addSubview:shadow];
        
        y = shadow.bottom_mn + 30.f;
        
        if (idx == 0) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            self.usernameField = textField;
        } else {
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeNamePhonePad;
            self.passwordField = textField;
        }
    }];
    
    UIButton *registButton = [UIButton buttonWithFrame:CGRectMake(x, self.passwordField.bottom_mn + 40.f, scrollView.width_mn - x*2.f, 45.f)
                                                 image:[UIImage imageWithColor:THEME_COLOR]
                                                 title:@"注册"
                                            titleColor:[UIColor whiteColor]
                                                  titleFont:UIFontRegular(16.5f)];
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
    UIImage *avatar = [self.headButton backgroundImageForState:UIControlStateSelected];
    if (!avatar || !self.headButton.isSelected) {
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
    [self.view showWeChatDialogDelay:.5f eventHandler:^{
        NSArray <WXUser *>*rows = [[MNDatabase sharedInstance] selectRowsModelFromTable:WXUsersTableName where:@{@"username":username}.componentString limit:NSRangeZero class:WXUser.class];
        if (rows.count > 0) {
            isExist = YES;
            return;
        }
        WXUser *u = MNChatHelper.generateRandomUser;
        u.username = username;
        u.password = password;
        u.nickname = username;
        [u setValue:avatar.PNGData forKey:kPath(u.avatarData)];
        if ([MNDatabase.sharedInstance insertIntoTable:WXUsersTableName model:u]) user = u;
    } completionHandler:^{
        @strongify(self);
        if (user) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.view showInfoDialog:(isExist ? @"改用户已存在" : @"注册失败")];
        }
    }];
}

- (void)selectHeadImage {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:@"设置头像" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        MNAssetPicker *picker = [[MNAssetPicker alloc] initWithType:buttonIndex];
        picker.configuration.cropScale = 1.f;
        picker.configuration.exportPixel = 300.f;
        picker.configuration.allowsCapturing = NO;
        picker.configuration.allowsEditing = YES;
        picker.configuration.allowsPickingGif = NO;
        picker.configuration.allowsPickingVideo = NO;
        picker.configuration.allowsPickingLivePhoto = NO;
        [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
            @strongify(self);
            if (assets.count) {
                UIImage *image = assets.firstObject.content;
                self.headButton.selected = YES;
                [self.headButton setBackgroundImage:image forState:UIControlStateSelected];
            } else {
                [self.view showInfoDialog:@"获取图片出错"];
            }
        } cancelHandler:nil];
    } otherButtonTitles:@"打开相册", @"打开相机", nil] show];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.usernameField) {
        return range.location + string.length <= 11;
    }
    return range.location + string.length <= 15;
}

#pragma mark - Overwrite
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
