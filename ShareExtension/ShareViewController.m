//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Vincent on 2019/4/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "ShareViewController.h"
#import "SENavigationBar.h"
#import "SECompletedDialog.h"
#import "SEIndicatorView.h"
#import "SEMainView.h"
#import "SESessionView.h"
#import "SEMomentView.h"
#import "UIView+MNLayout.h"
#import <WebKit/WebKit.h>

@interface ShareViewController () <WKNavigationDelegate, SENavigationBarDelegate, SEMainViewDelegate, SESessionViewDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SEMainView *mainView;
@property (nonatomic, strong) SESessionView *sessionView;
@property (nonatomic, strong) SEMomentView *momentView;
@property (nonatomic, strong) SENavigationBar *navigationBar;
@property (nonatomic, strong) SEIndicatorView *indicatorView;
@end

@implementation ShareViewController
- (void)loadView {
    UIView *view = UIView.new;
    view.bounds = UIScreen.mainScreen.bounds;
    view.backgroundColor = UIColor.whiteColor;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = UIColor.whiteColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollEnabled = NO;
    scrollView.contentSize = scrollView.bounds.size;
    scrollView.contentSize = CGSizeMake(scrollView.width_mn*2.f, scrollView.height_mn);
    #ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        if ([scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    #endif
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 导航
    SENavigationBar *navigationBar = [[SENavigationBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width_mn, 60.f)];
    navigationBar.delegate = self;
    [self.view addSubview:navigationBar];
    self.navigationBar = navigationBar;
    
    // 主视图
    SEMainView *mainView = [[SEMainView alloc] initWithFrame:CGRectMake(0.f, navigationBar.bottom_mn, scrollView.width_mn, scrollView.height_mn - navigationBar.bottom_mn)];
    mainView.delegate = self;
    [scrollView addSubview:mainView];
    self.mainView = mainView;
    
    // 分享朋友圈视图
    SEMomentView *momentView = [[SEMomentView alloc] initWithFrame:mainView.frame];
    momentView.left_mn = mainView.right_mn;
    [scrollView addSubview:momentView];
    self.momentView = momentView;
    
    // 加载指示器
    SEIndicatorView *indicatorView = SEIndicatorView.new;
    [self.view addSubview:indicatorView];
    self.indicatorView = indicatorView;

    // 加载数据
    [self loadData];
}

#pragma mark - LoadData
- (void)loadData {
    if (self.extensionContext.inputItems.count <= 0) {
        [self fail];
        return;
    }
    NSExtensionItem *item = [self.extensionContext.inputItems firstObject];
    if (item.attachments.count <= 0) {
        [self fail];
        return;
    }
    NSItemProvider *provider = [item.attachments firstObject];
    if ([provider hasItemConformingToTypeIdentifier:@"public.url"] == NO) {
        [self fail];
        return;
    }
    /// 开启加载视图
    [self.indicatorView startAnimating];
    /// 缩略图
    [provider loadPreviewImageWithOptions:nil completionHandler:^(id<NSSecureCoding>  _Nullable obj, NSError * _Null_unspecified error) {
        if (obj && [(NSObject *)obj isKindOfClass:UIImage.class]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mainView.image = (UIImage *)obj;
                self.momentView.image = (UIImage *)obj;
            });
        }
    }];
    /// 链接
    [provider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(id<NSSecureCoding>  _Nullable obj, NSError * _Null_unspecified error) {
        if ([(NSObject *)obj isKindOfClass:NSURL.class]) {
            NSURL *URL = (NSURL *)obj;
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示url
                self.mainView.url = URL.absoluteString;
                // 获取标题
                [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
            });
        }
    }];
}

#pragma mark - SEMainViewDelegate
- (void)mainViewButtonTouchUpInside:(SEButton *)button {
    if (self.indicatorView.isAnimating) return;
    if (button.type == SEButtonTagSession) {
        self.sessionView.hidden = NO;
        self.momentView.hidden = YES;
        [self.navigationBar setNavigationType:SENavigationTypeSession animated:YES];
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0.f);
        } completion:^(BOOL finished) {
            self.scrollView.scrollEnabled = NO;
        }];
    } else if (button.type == SEButtonTagMoment) {
        self.sessionView.hidden = YES;
        self.momentView.hidden = NO;
        [self.navigationBar setNavigationType:SENavigationTypeMoment animated:YES];
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0.f);
        } completion:^(BOOL finished) {
            self.scrollView.scrollEnabled = NO;
        }];
    } else {
        __weak typeof(self) weakself = self;
        [self.indicatorView startAnimatingDelay:1.f eventHandler:^{
            NSDictionary *webpage = weakself.mainView.jsonValue;
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mn.chat.share"];
            NSMutableArray *items = ([userDefaults arrayForKey:@"com.ext.share.favorites"] ? : @[]).mutableCopy;
            [items addObject:webpage];
            [userDefaults setObject:items.copy forKey:@"com.ext.share.favorites"];
            [userDefaults synchronize];
        } completionHandler:^{
            [SECompletedDialog.new showInView:weakself.view message:@"已添加至收藏夹" delay:1.f completionHandler:^{
                [weakself dismiss];
            }];
        }];
    }
}

#pragma mark - SENavigationBarDelegate
- (void)navigationBarLeftBarButtonClicked:(SENavigationBar *)navigationBar {
    if (navigationBar.type == SENavigationTypeMain) {
        [self.indicatorView stopAnimating];
        [self dismiss];
    } else {
        [self.momentView resignFirstResponder];
        [self.navigationBar setNavigationType:SENavigationTypeMain animated:YES];
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointZero;
        } completion:^(BOOL finished) {
            self.momentView.text = @"";
        }];
    }
}

- (void)navigationBarRightBarButtonClicked:(SENavigationBar *)navigationBar {
    __weak typeof(self) weakself = self;
    [self.momentView resignFirstResponder];
    [self.indicatorView startAnimatingDelay:1.f eventHandler:^{
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mn.chat.share"];
        NSMutableArray *items = ([userDefaults arrayForKey:@"com.ext.share.to.moment"] ? : @[]).mutableCopy;
        NSMutableDictionary *dic = @{}.mutableCopy;
        [dic setObject:weakself.mainView.jsonValue forKey:@"com.ext.share.to.moment.webpage"];
        [dic setObject:weakself.momentView.text forKey:@"com.ext.share.to.moment.text"];
        [items addObject:dic];
        [userDefaults setObject:items.copy forKey:@"com.ext.share.to.moment"];
        [userDefaults synchronize];
    } completionHandler:^{
        [SECompletedDialog.new showInView:weakself.view message:@"已分享朋友圈" delay:1.f completionHandler:^{
            [weakself dismiss];
        }];
    }];
}

#pragma mark - SESessionViewDelegate
- (void)sessionViewDidSelectSession:(SESession *)session {
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认发送给:" message:session.name preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself.indicatorView startAnimatingDelay:1.f eventHandler:^{
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mn.chat.share"];
            NSMutableArray *items = ([userDefaults arrayForKey:@"com.ext.share.to.session"] ? : @[]).mutableCopy;
            NSMutableDictionary *dic = @{}.mutableCopy;
            [dic setObject:weakself.mainView.jsonValue forKey:@"com.ext.share.to.session.webpage"];
            [dic setObject:session.identifier forKey:@"com.ext.share.session.identifier"];
            [items addObject:dic];
            [userDefaults setObject:items.copy forKey:@"com.ext.share.to.session"];
            [userDefaults synchronize];
        } completionHandler:^{
            [SECompletedDialog.new showInView:weakself.view message:@"已分享给好友" delay:1.f completionHandler:^{
                [weakself dismiss];
            }];
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled || (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])) return;
    [self.indicatorView stopAnimating];
    if (self.mainView.title.length <= 0) [self fail];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *js = @"function image_export(){ \
    var href=document.getElementsByTagName('img'); \
    var arr = []; \
    for(var i=0;i<href.length;i++){ \
    if(href[i].src.indexOf('https://') != 0 && href[i].src.indexOf('http://') != 0){ \
      continue; \
    } \
    arr.push({url: href[i].src, width: href[i].width, height: href[i].height}) \
    } \
    return JSON.stringify(arr); \
    } \
    image_export()";
    __weak typeof(self) weakself = self;
    [self.webView evaluateJavaScript:js completionHandler:^(NSString *_Nullable result, NSError * _Nullable error) {
        if (error || !result || result.length <= 0) return;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
            if (!data || data.length <= 0) return;
            NSArray <NSDictionary *>*imgs = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (!imgs || imgs.count <= 0) return;
            NSDictionary *dic = imgs.count > 1 ? imgs[1] : imgs.firstObject;
            NSString *url = dic[@"url"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    weakself.mainView.image = image;
                    weakself.momentView.image = image;
                }
            });
        });
    }];
}
/*
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    // 再次获取网页内图片
    static NSString * const images_script =
    @"function get_document_ims(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgs = Array();\
    for(var i=0;i<objs.length;i++){\
    imgs.push(objs[i].src);\
    };\
    return imgs;\
    };";
    __weak typeof(self) weakself = self;
    __weak typeof(webView) weakWebView = webView;
    [webView evaluateJavaScript:images_script completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        if (error) return;
        [weakWebView evaluateJavaScript:@"get_document_ims()" completionHandler:^(NSArray *_Nullable imgs, NSError * _Nullable e) {
            if (e || imgs.count <= 0) return;
            [weakself updateImages:imgs.copy];
        }];
    }];
}

- (void)updateImages:(NSArray <NSString *>*)imgs {
    __block NSString *img = @"";
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj hasPrefix:@"http"] || [obj.pathExtension.lowercaseString isEqualToString:@"gif"]) return;
        img = obj.copy;
        *stop = YES;
    }];
    if (img.length <= 0) return;
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:img]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                weakself.mainView.image = image;
                weakself.momentView.image = image;
            }
        });
    });
}
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        self.mainView.title = self.webView.title;
        self.momentView.title = self.webView.title;
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - dismiss & cancel & fail
- (void)dismiss {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (void)cancel {
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{NSLocalizedDescriptionKey:@"取消"}]];
}

- (void)fail {
    __weak typeof(self) weakself = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取网页数据失败" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakself dismiss];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Getter
- (WKWebView *)webView {
    if (!_webView) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:WKWebViewConfiguration.new];
        webView.navigationDelegate = self;
        [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        _webView = webView;
    }
    return _webView;
}

- (SESessionView *)sessionView {
    if (!_sessionView) {
        SESessionView *sessionView = [[SESessionView alloc] initWithFrame:self.momentView.frame];
        sessionView.delegate = self;
        [self.scrollView addSubview:sessionView];
        _sessionView = sessionView;
    }
    return _sessionView;
}

- (void)dealloc {
    if (_webView) [_webView removeObserver:self forKeyPath:@"title"];
}

@end

