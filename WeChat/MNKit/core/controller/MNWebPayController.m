//
//  MNWebPayController.m
//  MNKit
//
//  Created by Vicent on 2020/4/24.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNWebPayController.h"
#import "UIApplication+MNHelper.h"
#import "NSObject+MNHelper.h"
#import "UIView+MNLoadDialog.h"

static NSString *MNWebPayScheme = @"MNKit";
static NSString *MNWebPayDomain = @"MNWebPayDomain://";
NSNotificationName const MNWebPayFinishNotificationName = @"com.mn.web.pay.finish.notification.name";

#define MNWebPayBase64Decoding(string) [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters] encoding:NSUTF8StringEncoding]

void MNWebPaySetDomain (NSString *domain) {
    if (!domain || domain.length <= 0) return;
    MNWebPayDomain = domain.copy;
}

void MNWebPaySetScheme (NSString *scheme) {
    if (!scheme || scheme.length <= 0) return;
    MNWebPayScheme = scheme.copy;
}

@interface MNWebPayController ()
// 标记是否允许打开URL
@property (nonatomic, getter=isAllowsOpenURL) BOOL allowsOpenURL;
@end

@implementation MNWebPayController
- (void)initialized {
    [super initialized];
    self.allowsOpenURL = YES;
    self.allowsReloadWhenAppear = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 添加支付结果检查通知
    self.webView.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finish:)
                                                 name:MNWebPayFinishNotificationName
                                               object:nil];
}

#pragma mark - Rewrite
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURLRequest *request = navigationAction.request;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated &&
        [request.URL.host.lowercaseString containsString:MNWebPayBase64Decoding(@"5oiR55qE6Leo5Z+f5qCH6K+G56ym")]) {
        // 对于跨域，需要手动跳转
        __weak typeof(self) weakself = self;
        [UIApplication handOpenUrl:request.URL completion:^(BOOL succeed) {
            if (succeed == NO) {
                [weakself.view showErrorDialog:MNWebPayBase64Decoding(@"5omT5byA5a6i5oi356uv5aSx6LSl") completionHandler:^{
                    [weakself popViewControllerAnimated:NO];
                }];
            }
        }];
        // 不允许web内跳转
        if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        NSString *url = request.URL.absoluteString;
        if ([url containsString:MNWebPayBase64Decoding(@"d2VpeGluOi8vd2FwL3BheQ==")]) {
            self.allowsOpenURL = NO;
            __weak typeof(self) weakself = self;
            [UIApplication handOpenUrl:request.URL completion:^(BOOL succeed) {
                if (succeed == NO) {
                    [weakself.view showErrorDialog:MNWebPayBase64Decoding(@"5omT5byA5b6u5L+h5aSx6LSl") completionHandler:^{
                        [weakself popViewControllerAnimated:NO];
                    }];
                }
            }];
            if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
        } else if ([url containsString:MNWebPayBase64Decoding(@"aHR0cHM6Ly93eC50ZW5wYXkuY29tL2NnaS1iaW4vbW1wYXl3ZWItYmluL2NoZWNrbXdlYj8=")] && self.isAllowsOpenURL) {
            self.allowsOpenURL = NO;
            NSRange range = [url rangeOfString:MNWebPayBase64Decoding(@"JnJlZGlyZWN0X3VybD0=")];
            if (range.location != NSNotFound) url = [url substringToIndex:range.location];
            NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] init];
            mutableRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
            //[mutableRequest setValue:MNWebPayDomain forHTTPHeaderField:MNWebPayBase64Decoding(@"UmVmZXJlcg==")];
            mutableRequest.URL = [NSURL URLWithString:url];
            [self loadRequest:mutableRequest.copy];
            if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
        } else if ([url containsString:MNWebPayBase64Decoding(@"YWxpcGF5Oi8v")]) {
            //先解码
            url = [url stringByRemovingPercentEncoding];
            //取出域名后面的参数  用“？”分割的
            NSArray *components = [url componentsSeparatedByString:@"?"];
            //工具类将json字符串转成字典(自行替换)
            NSDictionary *value = ((NSString *)(components.lastObject)).JsonValue;
            NSMutableDictionary *dic = value.mutableCopy;
            [dic setObject:MNWebPayScheme forKey:MNWebPayBase64Decoding(@"ZnJvbUFwcFVybFNjaGVtZQ==")];
            //拼接前面的域名并编码
            NSString *aliUrl = [[NSString stringWithFormat:@"%@?%@",components.firstObject, dic.JsonString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            __weak typeof(self) weakself = self;
            [UIApplication handOpenUrl:aliUrl completion:^(BOOL succeed) {
                if (succeed == NO) {
                    [weakself.view showErrorDialog:MNWebPayBase64Decoding(@"5omT5byA5pSv5LuY5a6d5aSx6LSl") completionHandler:^{
                        [weakself popViewControllerAnimated:NO];
                    }];
                }
            }];
            if (decisionHandler) decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            if (decisionHandler) decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

- (NSURLRequest *)shouldLoadRequest:(id)req {
    NSURLRequest *request = [super shouldLoadRequest:req];
    if (request) {
        NSMutableURLRequest *mutableRequest = request.mutableCopy;
        [mutableRequest setValue:MNWebPayDomain forHTTPHeaderField:MNWebPayBase64Decoding(@"UmVmZXJlcg==")];
        request = mutableRequest.copy;
    }
    return request;
}

#pragma mark - 支付回调处理
+ (BOOL)handOpenURL:(NSURL *)URL {
    NSString *url = URL.absoluteString;
    if ([url containsString:MNWebPayDomain] || [url containsString:MNWebPayBase64Decoding(@"c2FmZXBheQ==")]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MNWebPayFinishNotificationName object:url];
        return YES;
    }
    return NO;
}

- (void)finish:(NSNotification *)notify {
    // 代理回调
    if ([self.payDelegate respondsToSelector:@selector(webPayControllerDidFinishPayment:)]) {
        [self.payDelegate webPayControllerDidFinishPayment:self];
    }
    // block回调
    if (self.didFinishPayHandler) {
        self.didFinishPayHandler(self);
    }
}

#pragma mark - Navigation
- (BOOL)navigationBarShouldDrawBackBarItem {
    return YES;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    return nil;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    return nil;
}

- (BOOL)shouldInteractivePopTransition {
    return NO;
}

- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    [self popViewControllerAnimated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = self.parentViewController ? : self;
    if (vc.presentingViewController) {
        [vc dismissViewControllerAnimated:animated completion:nil];
    } else if (vc.navigationController) {
        [vc.navigationController popViewControllerAnimated:animated];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
