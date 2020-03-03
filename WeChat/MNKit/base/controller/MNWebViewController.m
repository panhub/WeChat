//
//  MNWebViewController.m
//  MNKit
//
//  Created by Vincent on 2018/11/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNWebViewController.h"
#import <WebKit/WebKit.h>

@interface MNWebViewController ()
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, weak) MNWebProgressView *progressView;
@property (nonatomic, strong) MNWebUserContentController *contentController;
@end

const CGFloat MNWebViewBackViewTag = 101010;
NSString * const MNWebViewExitScriptMessageName = @"exit";
NSString * const MNWebViewBackScriptMessageName = @"back";
NSString * const MNWebViewReloadScriptMessageName = @"reload";

@implementation MNWebViewController
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    return self;
}

- (instancetype)initWithUrl:(NSString *)url {
    self = [self init];
    if (!self) return nil;
    self.url = url;
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithUrl:[URL absoluteString]];
}

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title {
    self = [self initWithUrl:url];
    if (!self) return nil;
    self.title = title;
    return self;
}

- (void)createView {
    [super createView];
    /*
     //js 与 webview 交互
     //该对象提供了通过js向webview发送消息的途径
     WKUserContentController *userContentController = [WKUserContentController new];
     //添加在js中操作的对象名称,通过该对象来向webview发送消息
     [userContentController addScriptMessageHandler:self name:@"jsToWebviewTest"];
     
     WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
     [configuration setUserContentController:userContentController];
     */
    /// 交互支持
    WKUserContentController *userContentController = [WKUserContentController new];
    /// 配置
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContentController;
    /// 代理
    MNWebUserContentController *contentController = [[MNWebUserContentController alloc]init];
    contentController.delegate = self;
    [contentController addScriptMessageToController:userContentController name:MNWebViewExitScriptMessageName];
    [contentController addScriptMessageToController:userContentController name:MNWebViewBackScriptMessageName];
    [contentController addScriptMessageToController:userContentController name:MNWebViewReloadScriptMessageName];
    [self.scriptMessages enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        [contentController addScriptMessageToController:userContentController name:name];
    }];
    self.contentController = contentController;
    
    MNWebProgressView *progressView = [[MNWebProgressView alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn - 2.5f, self.navigationBar.width_mn, 2.5f)];
    progressView.tintColor = THEME_COLOR;
    [self.navigationBar addSubview:progressView];
    self.progressView = progressView;
    
    WKWebView *webView = [[WKWebView alloc]initWithFrame:self.contentView.bounds configuration:configuration];
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [webView setBackgroundColor:self.contentView.backgroundColor];
    [webView.scrollView adjustContentInset];
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];
    /**观察进度, 也可观察标题@"title"*/
    [webView addObserver:self
              forKeyPath:@"estimatedProgress"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    if (self.title.length <= 0) {
        [webView addObserver:self
                  forKeyPath:@"title"
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
    }
    [self.contentView addSubview:webView];
    self.webView = webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - viewWillAppear
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reload];
}

#pragma mark - viewDidDisappear
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopLoading];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIView *leftItemView = [UIView new];
    leftItemView.size_mn = CGSizeMake(65.f, 30.f);
    /// 确保返回按钮响应
    leftItemView.touchInset = UIEdgeInsetsMake(0.f, -7.f, 0.f, 0.f);
    /// 返回
    UIButton *backButton = [UIButton buttonWithFrame:CGRectMake(-7.f, 0.f, leftItemView.height_mn, leftItemView.height_mn)
                                             image:UIImageWithUnicode(MNFontUnicodeBack, [UIColor darkTextColor], leftItemView.height_mn)
                                               title:@""
                                          titleColor:nil
                                           titleFont:nil];
    [backButton setTag:MNWebViewBackViewTag];
    [backButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [leftItemView addSubview:backButton];
    //关闭
    CGFloat margin = 2.f;
    UIButton *closeButton = [UIButton buttonWithFrame:CGRectMake(leftItemView.width_mn - backButton.width_mn - margin, MEAN(leftItemView.height_mn - (backButton.height_mn - margin)), backButton.width_mn - margin, backButton.height_mn - margin)
                                              image:UIImageWithUnicode(MNFontUnicodeClose, [UIColor darkTextColor], leftItemView.height_mn)
                                                title:@""
                                           titleColor:nil
                                            titleFont:nil];
    [closeButton setTag:(MNWebViewBackViewTag + 1)];
    [closeButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setHidden:YES];
    _closeButton = closeButton;
    [leftItemView addSubview:closeButton];
    return leftItemView;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    if (!_reloadButton) {
        UIButton *reloadButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 35.f, 35.f)
                                                   image:UIImageWithUnicode(MNFontUnicodeReload, [UIColor darkTextColor], 35.f)
                                                     title:nil
                                                titleColor:nil
                                                 titleFont:nil];
        [reloadButton.layer addAnimation:[CAAnimation animationWithRotation:M_PI*2.f duration:1.f] forKey:nil];
        [reloadButton.layer pauseAnimation];
        [reloadButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton = reloadButton;
    }
    return _reloadButton;
}

- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    if (leftBarItem.tag == MNWebViewBackViewTag) {
        if (_webView.canGoBack) {
            [self stopLoading];
            [_webView goBack];
            [_closeButton setHidden:NO];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        self.title = _webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [_progressView setProgress:_webView.estimatedProgress animated:YES];
    }
}

#pragma mark - 加载与重载
/**加载指定网页*/
- (void)loadRequest:(id)req {
    if (!req) return;
    NSURLRequest *request;
    if ([req isKindOfClass:[NSString class]]) {
        self.url = req;
        request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:req]];
    } else if ([req isKindOfClass:[NSURL class]]) {
        self.url = ((NSURL *)req).absoluteString;
        request = [[NSURLRequest alloc] initWithURL:req];
    } else if ([req isKindOfClass:[NSURLRequest class]]) {
        request = (NSURLRequest *)req;
        self.url = request.URL.absoluteString;
    }
    if (request) {
        [_webView stopLoading];
        [_webView loadRequest:request];
        [_reloadButton.layer resumeAnimation];
    }
}

- (void)reload {
    [self stopLoading];
    [self dismissEmptyView];
    [_closeButton setHidden:YES];
    [_reloadButton.layer resumeAnimation];
    [self loadRequest:self.url];
}

- (void)stopLoading {
    if (_webView.isLoading) {
        [_webView stopLoading];
        [_reloadButton.layer pauseAnimation];
    }
}

#pragma mark - WKNavigatonDelegate
/*开始加载*/
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {}
/*当内容开始到达主帧时被调用(即将完成)*/
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {}
/*加载完成(并非真正的完成, 比如重定向)*/
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [_reloadButton.layer pauseAnimation];
    [self dismissEmptyView];
}
/*加载失败*/
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled || (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])) {
        if (error.code == NSURLErrorCancelled) [_reloadButton.layer pauseAnimation];
        return;
    }
    [_reloadButton.layer pauseAnimation];
    [self showEmptyViewNeed:YES
                      image:[MNBundle imageForResource:@"empty_data_jd"]
                    message:@"加载失败, 请稍后重试"
                      title:@"刷新"
                       type:MNEmptyEventTypeReload];
}
/*在提交的主帧中发生错误时调用*/
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled || (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])) {
        if (error.code == NSURLErrorCancelled) [_reloadButton.layer pauseAnimation];
        return;
    }
    [_reloadButton.layer pauseAnimation];
    [self showEmptyViewNeed:YES
                      image:[MNBundle imageForResource:@"empty_data_jd"]
                    message:@"加载失败, 请稍后重试"
                      title:@"刷新"
                       type:MNEmptyEventTypeReload];
}
/**接收到服务器重定向时调用*/
/*
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{}
 */
/**在请求开始加载之前调用 -- 跳转操作*/
/*
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *urlString = [URL absoluteString];
    NSString *scheme = [URL scheme];
    MNLog(@"Action----%@----%@",urlString, scheme);
    if ([urlString hasPrefix:@"http"] || [urlString hasPrefix:@"https"]) {
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    } else {
        if (decisionHandler) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
}
*/
/*开始加载后调用(可处理一些简单交互)*/
/*
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSURL *URL = navigationResponse.response.URL;
    NSString *scheme = [URL scheme];
    NSString *urlString = [URL absoluteString];
    MNLog(@"Response----%@----%@",urlString, scheme);
    decisionHandler(WKNavigationResponsePolicyAllow);
}
 */
/**当webView接受SSL认证挑战*/
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        /**需要应战*/
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
            /**挑战证书创建成功就用证书应战*/
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - WKUIDelegate
/**js脚本需要新webview加载网页*/
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
/**输入框 在js中调用prompt函数时,会调用该方法*/
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:prompt
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = UIFontRegular(16.f);
        textField.placeholder = prompt;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
        if (completionHandler) {
            completionHandler(@"");
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
        if (completionHandler) {
            completionHandler([[alertController.textFields firstObject] text]);
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**确认框 在js中调用confirm函数时,会调用该方法*/
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
        if (completionHandler) {
            completionHandler(NO);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
        if (completionHandler) {
            completionHandler(YES);
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**警告框 在js中调用alert函数时,会调用该方法*/
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
        if (completionHandler) {
            completionHandler();
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - MNScriptMessageHandler
- (BOOL)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (message.name.length <= 0) return NO;
    if ([message.name isEqualToString:MNWebViewExitScriptMessageName]) {
        /// 退出
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    } else if ([message.name isEqualToString:MNWebViewBackScriptMessageName]) {
        /// 返回
        if (_webView.canGoBack) {
            [self stopLoading];
            [_webView goBack];
            [_closeButton setHidden:NO];
        } else {
            [self reload];
        }
        return NO;
    } else if ([message.name isEqualToString:MNWebViewReloadScriptMessageName]) {
        /// 重载
        [self reload];
        return NO;
    }
    return YES;
}

#pragma mark - DataEmptyViewDelegate
- (void)dataEmptyViewButtonClicked:(MNEmptyView *)emptyView {
    [self reload];
}

#pragma mark - Setter
- (void)setUrl:(NSString *)url {
    if (url.length <= 0) return;
    _url = [url copy];
}

#pragma mark - Getter
- (BOOL)isLoading {
    return (_webView && _webView.isLoading);
}

#pragma mark - dealloc
- (void)dealloc {
    [_contentController removeAllScriptMessageInController:_webView.configuration.userContentController];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_reloadButton.layer resetAnimation];
    [_reloadButton.layer removeAllAnimations];
}

@end
