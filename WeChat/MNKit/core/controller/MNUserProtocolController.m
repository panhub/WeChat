//
//  MNUserProtocolController.m
//  MNKit
//
//  Created by Vicent on 2020/10/18.
//

#import "MNUserProtocolController.h"

#ifdef MN_THEME_COLOR
#define MNUserProtocolColor  MN_THEME_COLOR
#else
#define MNUserProtocolColor  UIColor.redColor
#endif

@interface MNUserProtocolController ()
/**本地保存标记Key*/
@property (nonatomic, copy) NSString *userKey;
/**用户协议*/
@property (nonatomic, copy) NSURL *userProtocolURL;
/**隐私政策*/
@property (nonatomic, copy) NSURL *privacyProtocolURL;
@end

@implementation MNUserProtocolController
- (void)initialized {
    [super initialized];
    self.modalPresentationStyle = UIModalPresentationCustom;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    NSString *userProtocol = @"《用户协议》";
    NSString *userProtocolString = [NSString stringWithFormat:@"您也可以查看%@",userProtocol];
    NSMutableAttributedString *userProtocolAttributedString = [[NSMutableAttributedString alloc] initWithString:userProtocolString];
    [userProtocolAttributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} range:userProtocolString.rangeOfAll];
    [userProtocolAttributedString addAttributes:@{NSForegroundColorAttributeName:UIColor.darkTextColor} range:userProtocolString.rangeOfAll];
    [userProtocolAttributedString addAttributes:@{NSForegroundColorAttributeName:MNUserProtocolColor} range:[userProtocolString rangeOfString:userProtocol]];
    
    NSString *privacyProtocol = @"《隐私政策》";
    NSString *privacyProtocolString = [NSString stringWithFormat:@"您也可以查看%@",privacyProtocol];
    NSMutableAttributedString *privacyProtocolAttributedString = [[NSMutableAttributedString alloc] initWithString:privacyProtocolString];
    [privacyProtocolAttributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} range:privacyProtocolString.rangeOfAll];
    [privacyProtocolAttributedString addAttributes:@{NSForegroundColorAttributeName:UIColor.darkTextColor} range:privacyProtocolString.rangeOfAll];
    [privacyProtocolAttributedString addAttributes:@{NSForegroundColorAttributeName:MNUserProtocolColor} range:[privacyProtocolString rangeOfString:privacyProtocol]];
    
    UIButton *checkButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 48.f) image:nil title:nil titleColor:nil titleFont:nil];
    checkButton.selected = YES;
    checkButton.backgroundColor = UIColor.whiteColor;
    [checkButton setAttributedTitle:userProtocolAttributedString.copy forState:UIControlStateNormal];
    [checkButton setAttributedTitle:privacyProtocolAttributedString.copy forState:UIControlStateSelected];
    [checkButton addTarget:self action:@selector(checkButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:checkButton];
    
    UIView *checkButtonLine = [[UIView alloc]initWithFrame:checkButton.bounds];
    checkButtonLine.height_mn = MN_SEPARATOR_HEIGHT;
    checkButtonLine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    checkButtonLine.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:.15f];
    [checkButton addSubview:checkButtonLine];
    
    UIButton *confirmButton = [UIButton buttonWithFrame:checkButton.frame image:nil title:@"我知道了" titleColor:MNUserProtocolColor titleFont:[UIFont systemFontOfSize:16.f]];
    confirmButton.backgroundColor = UIColor.whiteColor;
    [confirmButton addTarget:self action:@selector(confirmButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:confirmButton];
    
    UIView *confirmButtonLine = [[UIView alloc]initWithFrame:confirmButton.bounds];
    confirmButtonLine.height_mn = MN_SEPARATOR_HEIGHT;
    confirmButtonLine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    confirmButtonLine.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:.15f];
    [confirmButton addSubview:confirmButtonLine];
    
    BOOL allowsSwitch = (self.userProtocolURL && self.privacyProtocolURL);
    
    self.webView.autoresizingMask = UIViewAutoresizingNone;
    self.webView.height_mn = self.contentView.height_mn - confirmButton.height_mn - (allowsSwitch ? checkButton.height_mn : 0.f);
    confirmButton.bottom_mn = self.contentView.height_mn;
    checkButton.bottom_mn = confirmButton.top_mn;
    checkButton.hidden = !allowsSwitch;
    
    self.view.layer.cornerRadius = 10.f;
    self.view.clipsToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (void)presentWithUserProtocolURL:(NSURL *)userProtocolURL privacyProtocolURL:(NSURL *)privacyProtocolURL forKey:(NSString *)saveForKey {
    [self presentInController:nil userProtocolURL:userProtocolURL privacyProtocolURL:privacyProtocolURL forKey:saveForKey];
}

+ (void)presentInController:(UIViewController *)viewControllerToPresent userProtocolURL:(NSURL *)userProtocolURL privacyProtocolURL:(NSURL *)privacyProtocolURL forKey:(NSString *)saveForKey {
    if (!userProtocolURL && !privacyProtocolURL) return;
    if (saveForKey && [NSUserDefaults.standardUserDefaults boolForKey:saveForKey]) return;
    if (!viewControllerToPresent) viewControllerToPresent = UIApplication.sharedApplication.delegate.window.rootViewController;
    if (viewControllerToPresent.presentedViewController) viewControllerToPresent = viewControllerToPresent.presentedViewController;
    if (!viewControllerToPresent) return;
    MNUserProtocolController *vc = [[MNUserProtocolController alloc] initWithFrame:CGRectMake(0.f, 0.f, MN_SCREEN_WIDTH*.75f, MN_SCREEN_HEIGHT*.6f)];
    vc.userKey = saveForKey;
    vc.userProtocolURL = userProtocolURL;
    vc.privacyProtocolURL = privacyProtocolURL;
    NSURL *URL = userProtocolURL ? : privacyProtocolURL;
    vc.url = URL.isFileURL ? URL.path : URL.absoluteString;
    [viewControllerToPresent presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Event
- (void)checkButtonTouchUpInside:(UIButton *)sender {
    if (sender.isSelected) {
        [self loadRequest:self.privacyProtocolURL];
    } else {
        [self loadRequest:self.userProtocolURL];
    }
    sender.selected = !sender.isSelected;
}

- (void)confirmButtonTouchUpInside:(UIButton *)sender {
    if (self.userKey) {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:self.userKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Super
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleModal;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeAlertModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeAlertModal];
}

- (void)showEmptyViewNeed:(BOOL)isNeed image:(UIImage *)image message:(NSString *)message title:(NSString *)title type:(MNEmptyEventType)type {
    [super showEmptyViewNeed:isNeed image:nil message:message title:title type:type];
}

@end
