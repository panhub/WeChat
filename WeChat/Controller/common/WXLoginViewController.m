//
//  WXLoginViewController.m
//  WeChat
//
//  Created by Vincent on 2019/3/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLoginViewController.h"
#import "WXRegistViewController.h"
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
#import <AuthenticationServices/AuthenticationServices.h>
@interface WXLoginViewController ()<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, UITextFieldDelegate>
#else
@interface WXLoginViewController ()<UITextFieldDelegate>
#endif
@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation WXLoginViewController
- (void)createView {
    [super createView];
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.userInteractionEnabled = YES;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *avatarView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 70.f, 70.f)
                                                      image:UIImageNamed(@"common_head_placeholder")];
    avatarView.alpha = 0.f;
    avatarView.centerX_mn = scrollView.bounds_center.x;
    UIViewSetBorderRadius(avatarView, 5.f, .8f, UIColorWithAlpha([UIColor grayColor], .1f));
    [scrollView addSubview:avatarView];
    self.avatarView = avatarView;
    
    UIView *loginView = [[UIView alloc] initWithFrame:CGRectMake(0.f, avatarView.top_mn, scrollView.width_mn - 80.f, 0.f)];
    loginView.centerX_mn = self.contentView.width_mn/2.f;
    loginView.backgroundColor = self.contentView.backgroundColor;
    [scrollView addSubview:loginView];
    self.loginView = loginView;
    
    __block CGFloat y = 35.f;
    NSArray <NSString *>*titleArray = @[@"账号", @"密码"];
    NSArray <NSString *>*placeArray = @[@"建议使用手机号码", @"请输入密码"];
    [titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(0.f, y, loginView.width_mn, 30.f)
                                                            font:UIFontRegular(17.f)
                                                     placeholder:placeArray[idx]
                                                        delegate:self];
        textField.tintColor = THEME_COLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholderColor = UIColorWithAlpha([UIColor grayColor], .4f);
        textField.placeholderFont = UIFontRegular(17.f);
        [loginView addSubview:textField];
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:title textColor:UIColor.darkTextColor font:UIFontWithNameSize(MNFontNameMedium, 19.f)];
        titleLabel.numberOfLines = 1;
        [titleLabel sizeToFit];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, titleLabel.width_mn + 13.f, textField.height_mn)];
        titleLabel.centerY_mn = leftView.height_mn/2.f;
        [leftView addSubview:titleLabel];
        
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.leftView = leftView;
        
        UIImageView *separator = [UIImageView imageViewWithFrame:CGRectMake(0.f, textField.bottom_mn, loginView.width_mn, MN_SEPARATOR_HEIGHT)
                                                        image:[UIImage imageWithColor:UIColorWithAlpha([UIColor grayColor], .33f)]];
        separator.contentMode = UIViewContentModeScaleAspectFill;
        separator.clipsToBounds = YES;
        [loginView addSubview:separator];
        
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
    
    UIButton *loginButton = [UIButton buttonWithFrame:CGRectMake(0.f, self.passwordField.bottom_mn + 40.f, loginView.width_mn, 44.f)
                                                 image:[UIImage imageWithColor:THEME_COLOR]
                                                 title:@"登录"
                                            titleColor:[UIColor whiteColor]
                                                  titleFont:UIFontMedium(17.f)];
    UIViewSetCornerRadius(loginButton, 5.f);
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:loginButton];
    
    UIButton *registButton = [UIButton buttonWithFrame:CGRectMake(0.f, loginButton.bottom_mn + 13.f, 150.f, 15.f)
                                                image:nil
                                                title:@"没有账号? 立即注册"
                                           titleColor:THEME_COLOR
                                                 titleFont:UIFontRegular(14.f)];
    registButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    registButton.right_mn = loginButton.right_mn;
    registButton.touchInset = UIEdgeInsetWith(-5.f);
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:registButton];
    
    loginView.height_mn = registButton.bottom_mn;
    
    
    avatarView.top_mn = self.contentView.height_mn/2.f - (avatarView.height_mn + loginView.height_mn)/2.f;
    loginView.top_mn = avatarView.top_mn;
    
    
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDButton *button = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhiteOutline];
        button.frame = CGRectMake(0.f, 0.f, self.contentView.width_mn/2.f, 44.f);
        button.bottom_mn = self.contentView.height_mn - MAX(MN_TAB_SAFE_HEIGHT + 15.f, 30.f);
        button.centerX_mn = self.contentView.width_mn/2.f;
        [button addTarget:self action:@selector(appleIDAuthorizationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
    }
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self.scrollView handTapEventHandler:^(id sender) {
        @strongify(self);
        [self.view endEditing:YES];
    }];
    [self handNotification:UITextFieldTextDidChangeNotification eventHandler:^(NSNotification *_Nonnull notify) {
        @strongify(self);
        UITextField *textField = notify.object;
        if (textField != self.usernameField) return;
        if (textField.text.length <= 0 && self.avatarView.alpha) {
            self.avatarView.alpha = 0.f;
            self.loginView.top_mn = self.avatarView.top_mn;
        }
    }];
}

- (void)loadData {
    NSString *username = [NSUserDefaults.standardUserDefaults stringForKey:kLoginLastUsername];
    if (!username) return;
    NSDictionary *userInfo = [WXUser userInfoWithUsername:username];
    if (!userInfo) return;
    WXUser *user = [WXUser userWithInfo:userInfo];
    if (user) {
        self.usernameField.text = user.username;
        self.passwordField.text = user.password;
        self.avatarView.alpha = 1.f;
        self.avatarView.image = user.avatar;
        self.loginView.top_mn = self.avatarView.bottom_mn;
    }
}

- (void)login {
    [self.view endEditing:YES];
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
    [self.view showWechatDialogDelay:1.f eventHandler:^{
        user = [WXUser userWithInfo:[WXUser userInfoWithUsername:username]];
    } completionHandler:^{
        @strongify(self);
        if (user && [user.password isEqualToString:password]) {
            // 登录成功
            // 保存登录用户名
            WXPreference.preference.loginPolicy = WXLoginPolicyAccount;
            [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
                [userDefaults removeObjectForKey:AppleUserIdentifier];
                [userDefaults setObject:username forKey:kLoginLastUsername];
            }];
            // 更新用户信息
            [WXUser.shareInfo updateUserInfo:user.JsonValue];
            // 动画登录状态
            self.avatarView.image = user.avatar;
            [UIView animateWithDuration:.35f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.avatarView.alpha = 1.f;
                self.loginView.top_mn = self.avatarView.bottom_mn;
            } completion:^(BOOL finished) {
                [NSNotificationCenter.defaultCenter postNotificationName:LOGIN_NOTIFY_NAME object:nil];
            }];
        } else {
            [self.view showInfoDialog:(user ? @"密码错误" : @"用户未注册")];
        }
    }];
}

- (void)regist {
    WXRegistViewController *vc = [WXRegistViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

MNKIT_CLANG_AVAILABLE_PUSH
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
#pragma mark - Sign In with Apple
- (void)appleIDAuthorizationButtonClicked API_AVAILABLE(ios(13.0)) {
    // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
    ASAuthorizationAppleIDProvider *provider = [[ASAuthorizationAppleIDProvider alloc] init];
    // 创建新的AppleID 授权请求
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    // 在用户授权期间请求的联系信息
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
    ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    // 设置授权控制器通知授权请求的成功与失败的代理
    authorizationController.delegate = self;
    // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
    authorizationController.presentationContextProvider = self;
    // 在控制器初始化期间启动授权流
    [authorizationController performRequests];
}

#pragma mark - ASAuthorizationControllerDelegate
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *credential = authorization.credential;
        [self loginWithAppleCredential:credential];
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        // Sign in using an existing iCloud Keychain credential.
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *credential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString *user = credential.user;
        NSString *password = credential.password;
        NSLog(@"user===%@\npassword===%@", user, password);
    } else {
        [self.view showInfoDialog:@"授权信息出错"];
    }
}

- (void)loginWithAppleCredential:(ASAuthorizationAppleIDCredential *)credential {
    NSString *userIdentifier = credential.user;
    NSString *familyName = credential.fullName.familyName;
    NSString *givenName = credential.fullName.givenName;
    @weakify(self);
    __block WXUser *user = nil;
    [self.view showWechatDialogDelay:1.f eventHandler:^{
        user = [WXUser userWithInfo:[WXUser userInfoWithUsername:userIdentifier]];
        if (!user) {
            WXUser *u = WechatHelper.user;
            u.username = userIdentifier;
            NSMutableString *nickName = @"".mutableCopy;
            [nickName appendString:[NSString replacingEmptyCharacters:familyName]];
            [nickName appendString:[NSString replacingEmptyCharacters:givenName]];
            if (nickName.length > 0) u.nickname = nickName.copy;
            u.avatarString = WechatHelper.avatar.PNGBase64Encoding;
            if ([WXUser setUserInfoToKeychain:u.JsonValue]) user = u;
        }
    } completionHandler:^{
        @strongify(self);
        if (user) {
            WXPreference.preference.loginPolicy = WXLoginPolicyApple;
            [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
                [userDefaults setObject:userIdentifier forKey:AppleUserIdentifier];
            }];
            [WXUser.shareInfo updateUserInfo:user.JsonValue];
            [NSNotificationCenter.defaultCenter postNotificationName:LOGIN_NOTIFY_NAME object:nil];
        } else {
            [self.view showInfoDialog:@"Apple登录失败"];
        }
    }];
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
    NSString *message = MN_UNKNOWN_ERROR;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            message = @"已取消授权请求";
            break;
        case ASAuthorizationErrorFailed:
            message = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            message = @"授权请求无响应";
            break;
        case ASAuthorizationErrorNotHandled:
            message = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            message = @"授权请求失败";
            break;
        default:
            break;
    }
    [self.view showInfoDialog:message];
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    // 返回window
    return self.view.window;
}
#endif
MNKIT_CLANG_POP

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

@end
