//
//  MNLoginViewController.m
//  MNChat
//
//  Created by Vincent on 2019/3/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLoginViewController.h"
#import "MNRegistViewController.h"
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
#import <AuthenticationServices/AuthenticationServices.h>
@interface MNLoginViewController ()<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, UITextFieldDelegate>
#else
@interface MNLoginViewController ()<UITextFieldDelegate>
#endif
@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

#define MNLoginUsernameKey  @"com.wx.login.Username.key"
#define MNLoginPasswordKey  @"com.wx.login.password.key"

@implementation MNLoginViewController
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
    
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(0.f, self.navigationBar.bottom_mn + 45.f, 70.f, 70.f)
                                                      image:UIImageNamed(@"common_head_placeholder")];
    headView.alpha = 0.f;
    headView.centerX_mn = scrollView.bounds_center.x;
    UIViewSetBorderRadius(headView, 5.f, .8f, UIColorWithAlpha([UIColor grayColor], .1f));
    [scrollView addSubview:headView];
    self.headView = headView;
    
    UIView *loginView = [[UIView alloc] initWithFrame:CGRectMake(0.f, headView.top_mn, scrollView.width_mn, 0.f)];
    loginView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:loginView];
    self.loginView = loginView;
    
    NSArray <NSString *>*titleArray = @[@"账号", @"密码"];
    NSArray <NSString *>*placeArray = @[@"建议使用手机号码", @"请输入密码"];
    __block CGFloat y = 7.f;
    CGFloat x = self.navigationBar.leftBarItem.right_mn;
    [titleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(x, y, 0.f, 0.f) text:title textColor:[UIColor darkTextColor] font:UIFontWithNameSize(MNFontNameMedium, 20.f)];
        [titleLabel sizeToFit];
        titleLabel.height_mn = 20.f;
        titleLabel.width_mn += 10.f;
        [loginView addSubview:titleLabel];
        
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(titleLabel.right_mn, titleLabel.top_mn, loginView.width_mn - titleLabel.right_mn - titleLabel.left_mn, titleLabel.height_mn)
                                                            font:UIFontRegular(18.f)
                                                     placeholder:placeArray[idx]
                                                        delegate:self];
        textField.tintColor = THEME_COLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.placeholderColor = UIColorWithAlpha([UIColor grayColor], .4f);
        textField.placeholderFont = UIFontRegular(16.f);
        [loginView addSubview:textField];
        
        UIImageView *shadow = [UIImageView imageViewWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 5.f, loginView.width_mn - titleLabel.left_mn*2.f, MN_SEPARATOR_HEIGHT)
                                                        image:[UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .2f)]];
        shadow.contentMode = UIViewContentModeScaleAspectFill;
        shadow.clipsToBounds = YES;
        [loginView addSubview:shadow];
        
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
    
    UIButton *loginButton = [UIButton buttonWithFrame:CGRectMake(x, self.passwordField.bottom_mn + 40.f, loginView.width_mn - x*2.f, 45.f)
                                                 image:[UIImage imageWithColor:THEME_COLOR]
                                                 title:@"登录"
                                            titleColor:[UIColor whiteColor]
                                                  titleFont:UIFontRegular(16.5f)];
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
    
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDButton *button = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeDefault style:ASAuthorizationAppleIDButtonStyleWhiteOutline];
        button.frame = CGRectMake(0.f, 0.f, self.contentView.width_mn/2.f, 48.f);
        button.bottom_mn = self.contentView.height_mn - UITabSafeHeight() - 30.f;
        button.centerX_mn = self.contentView.width_mn/2.f;
        [button addTarget:self action:@selector(handAuthorizationAppleIDButtonClicked) forControlEvents:UIControlEventTouchUpInside];
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
}

- (void)loadData {
    NSString *username = [MNKeyChain stringForKey:MNLoginUsernameKey];
    NSString *password = [MNKeyChain stringForKey:MNLoginPasswordKey];
    if (username.length <= 0) return;
    NSArray <WXUser *>*rows = [[MNDatabase sharedInstance] selectRowsModelFromTable:WXUsersTableName where:@{@"username":username}.componentString limit:NSRangeZero class:WXUser.class];
    if (rows.count > 0) {
        self.usernameField.text = username;
        self.passwordField.text = password;
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
    [self.view showWeChatDialogDelay:.5f eventHandler:^{
        NSArray <WXUser *>*rows = [[MNDatabase sharedInstance] selectRowsModelFromTable:WXUsersTableName where:@{@"username":username}.componentString limit:NSRangeZero class:WXUser.class];
        if (rows.count > 0) user = rows.firstObject;
    } completionHandler:^{
        @strongify(self);
        if (user && [user.password isEqualToString:password]) {
            // 登录成功
            WXPreference.preference.loginType = WXLoginTypeWeChat;
            [MNKeyChain setString:username forKey:MNLoginUsernameKey];
            [MNKeyChain setString:password forKey:MNLoginPasswordKey];
            [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
                [userDefaults removeObjectForKey:AppleUserIdentifier];
            }];
            self.headView.image = user.avatar;
            [UIView animateWithDuration:.35f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.headView.alpha = 1.f;
                self.loginView.top_mn = self.headView.bottom_mn + 35.f;
            } completion:^(BOOL finished) {
                [WXUser updateUserInfo:user.JsonValue];
                [AppDelegate makeKeyAndVisible];
            }];
        } else {
            [self.view showInfoDialog:(user ? @"密码错误" : @"用户未注册")];
        }
    }];
}

- (void)regist {
    MNRegistViewController *vc = [MNRegistViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

MNKIT_CLANG_AVAILABLE_PUSH
#if __has_include(<AuthenticationServices/ASAuthorizationAppleIDProvider.h>)
#pragma mark - Sign In with Apple
- (void)handAuthorizationAppleIDButtonClicked API_AVAILABLE(ios(13.0)) {
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
    [self.view showWeChatDialogDelay:.5f eventHandler:^{
        NSArray <WXUser *>*rows = [[MNDatabase sharedInstance] selectRowsModelFromTable:WXUsersTableName where:@{@"username":userIdentifier}.componentString limit:NSRangeZero class:WXUser.class];
        if (rows.count > 0) {
            user = rows.firstObject;
        } else {
            WXUser *u = MNChatHelper.generateRandomUser;
            u.username = userIdentifier;
            NSMutableString *nickName = @"".mutableCopy;
            [nickName appendString:[NSString replacingBlankCharacter:familyName]];
            [nickName appendString:[NSString replacingBlankCharacter:givenName]];
            if (nickName.length > 0) u.nickname = nickName.copy;
            if ([MNDatabase.sharedInstance insertIntoTable:WXUsersTableName model:u]) user = u;
        }
    } completionHandler:^{
        @strongify(self);
        if (user) {
            WXPreference.preference.loginType = WXLoginTypeApple;
            [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
                [userDefaults setObject:userIdentifier forKey:AppleUserIdentifier];
            }];
            [WXUser updateUserInfo:user.JsonValue];
            [AppDelegate makeKeyAndVisible];
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

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeFlip];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeFlip];
}

- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

@end
