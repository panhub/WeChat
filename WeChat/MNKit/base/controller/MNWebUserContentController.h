//
//  MNWebUserContentController.h
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/14.
//  Copyright © 2019年 AiZhe. All rights reserved.
//  用于处理WKWebView JS 与 OC交互
//  直接使用"WKUserContentController"有时不会释放, 所以用代理饶了一圈, 本质一样

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol MNScriptMessageHandler <NSObject>

@required

/**
 JS交互代理
 @param userContentController 交互控制者
 @param message 交互信息
 @return 是否需要处理交互, 返回是为了子类便于判断父类是否已处理该信息
 */
- (BOOL)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface MNWebUserContentController : NSObject<WKScriptMessageHandler>

/**
 回调代理
 */
@property (nonatomic, weak) id<MNScriptMessageHandler> delegate;

/**
 方法名列表缓存
 */
@property (nonatomic, strong, readonly)  NSMutableArray <NSString *>*messageNames;

/**
 添加消息
 @param controller 交互控制者
 @param name 消息名
 */
- (void)addScriptMessageToController:(WKUserContentController *)controller name:(NSString *)name;

/**
 删除消息
 @param controller 交互控制者
 @param name 消息名
 */
- (void)removeScriptMessageInController:(WKUserContentController *)controller name:(NSString *)name;

/**
 删除所有消息
 @param controller 交互控制者
 */
- (void)removeAllScriptMessageInController:(WKUserContentController *)controller;

@end

