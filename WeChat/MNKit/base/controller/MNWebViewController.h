//
//  MNWebViewController.h
//  MNKit
//
//  Created by Vincent on 2018/11/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNExtendViewController.h"
#import "MNWebProgressView.h"
#import "MNWebUserContentController.h"
@class WKWebView;

UIKIT_EXTERN const CGFloat MNWebViewBackViewTag;
UIKIT_EXTERN NSString * const MNWebViewExitScriptMessageName;
UIKIT_EXTERN NSString * const MNWebViewBackScriptMessageName;
UIKIT_EXTERN NSString * const MNWebViewReloadScriptMessageName;

@interface MNWebViewController : MNExtendViewController<WKUIDelegate,WKNavigationDelegate,MNScriptMessageHandler>

/**
 链接
 */
@property (nonatomic, copy) NSString *url;
/**
 交互信息名
 */
@property (nonatomic, strong) NSArray <NSString *>*scriptMessages;
/**
 是否在加载
 */
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
/**
 内部使用的webView
 */
@property (nonatomic, weak, readonly) WKWebView *webView;
/**
 进度条
 */
@property (nonatomic, weak, readonly) MNWebProgressView *progressView;
/**
 JS交互代理
 */
@property (nonatomic, strong, readonly) MNWebUserContentController *contentController;


- (instancetype)initWithUrl:(NSString *)url;

- (instancetype)initWithURL:(NSURL *)URL;

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title;

- (void)loadRequest:(id)req;

- (void)reload;

- (void)stopLoading;

@end

