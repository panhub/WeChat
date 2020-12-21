//
//  MNWebViewController.h
//  MNKit
//
//  Created by Vincent on 2018/11/29.
//  Copyright © 2018年 小斯. All rights reserved.
//  网页控制器基类

#import "MNExtendViewController.h"
#import "MNWebProgressView.h"
#import "MNWebUserContentController.h"
@class WKWebView, MNWebViewController;
@protocol WKUIDelegate, WKNavigationDelegate, MNScriptMessageHandler;

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN const CGFloat MNWebBackButtonTag;
UIKIT_EXTERN const CGFloat MNWebCloseButtonTag;
UIKIT_EXTERN NSString *const MNWebViewExitScriptMessageName;
UIKIT_EXTERN NSString *const MNWebViewBackScriptMessageName;
UIKIT_EXTERN NSString *const MNWebViewReloadScriptMessageName;

@protocol MNWebControllerDelegate <NSObject>
@optional
- (void)webViewControllerDidStartLoad:(MNWebViewController *)webViewController;
- (void)webViewControllerWillFinishLoad:(MNWebViewController *)webViewController;
- (void)webViewControllerDidFinishLoad:(MNWebViewController *)webViewController;
- (void)webViewController:(MNWebViewController *)webViewController didFailLoadWithError:(NSError *_Nullable)error;
@end

@interface MNWebViewController : MNExtendViewController<WKUIDelegate,WKNavigationDelegate,MNScriptMessageHandler>
/**
 链接
 */
@property (nonatomic, copy) NSString *url;
/**
 链接
 */
@property (nonatomic, strong, null_unspecified) NSURL *URL;
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
@property (nonatomic, strong, readonly) WKWebView *webView;
/**
 外部回调代理
 */
@property (nonatomic, weak, nullable) id<MNWebControllerDelegate> delegate;
/**
 进度条
 */
@property (nonatomic, strong, readonly) MNWebProgressView *progressView;
/**
 JS交互代理
 */
@property (nonatomic, strong, readonly) MNWebUserContentController *contentController;
/**
 控制器显现时, 重载页面<第一次加载时必然重载, 不受此属性控制>
*/
@property (nonatomic, getter=isAllowsReloadWhenAppear) BOOL allowsReloadWhenAppear;
/**
 是否根据网页刷新标题
 */
@property (nonatomic, getter=isAllowsReloadTitle) BOOL allowsReloadTitle;

/**
 实例化网页控制器
 @param url 网址
 @return 网页控制器
 */
- (instancetype)initWithUrl:(NSString *_Nullable)url;

/**
 实例化网页控制器
 @param url 网址
 @param title 标题
 @return 网页控制器
 */
- (instancetype)initWithUrl:(NSString *_Nullable)url title:(NSString *_Nullable)title;

/**
 实例化网页控制器
 @param URL 网址
 @return 网页控制器
 */
- (instancetype)initWithURL:(NSURL *_Nullable)URL;

/**
 实例化网页控制器
 @param URL 网址
 @param title 标题
 @return 网页控制器
 */
- (instancetype)initWithURL:(NSURL *_Nullable)URL title:(NSString *_Nullable)title;

/**
 实例化网页控制器
 @param html 网页数据
 @return 网页控制器
 */
- (instancetype)initWithHTML:(NSString *)html;

/**
 实例化网页控制器
 @param html 网页数据
 @param baseURL 网页数据
 @return 网页控制器
 */
- (instancetype)initWithHTML:(NSString *)html baseURL:(NSURL *_Nullable)baseURL;

/**
 实例化网页控制器
 @param html 网页数据
 @param baseURL 网页数据
 @param title 标题
 @return 网页控制器
 */
- (instancetype)initWithHTML:(NSString *)html baseURL:(NSURL *_Nullable)baseURL title:(NSString *_Nullable)title;

/**
 实例化网页子控制器
 @param frame 位置
 @param url 网址
 @return 网页子控制器
 */
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *_Nullable)url;

/**
 实例化网页子控制器
 @param frame 位置
 @param html 网页数据
 @param baseURL 网页数据
 @return 网页子控制器
 */
- (instancetype)initWithFrame:(CGRect)frame html:(NSString *)html baseURL:(NSURL *_Nullable)baseURL;

/**
 加载网页请求
 @param req NSURLRequest/NSURL/NSString
 */
- (void)loadRequest:(id)req;

/**
 处理网页请求 子类可定制
 @param req NSURLRequest/NSURL/NSString
 @return 加载的请求
 */
- (NSURLRequest *_Nullable)shouldLoadRequest:(id)req;

/**
 重载网页
 */
- (void)reload;

/**
 返回
 @return 是否返回
 */
- (BOOL)goBack;

/**
 停止加载
 */
- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
