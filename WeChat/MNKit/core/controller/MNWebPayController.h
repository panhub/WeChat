//
//  MNWebPayController.h
//  MNKit
//
//  Created by Vicent on 2020/4/24.
//  Copyright © 2020 Vincent. All rights reserved.
//  网页支付集成

#import "MNWebViewController.h"
@class MNWebPayController;

NS_ASSUME_NONNULL_BEGIN

@protocol MNWebPayDelegate <NSObject>
@optional
- (void)webPayControllerDidFinishPayment:(MNWebPayController *)payController;
@end

@interface MNWebPayController : MNWebViewController

/**记录支付信息*/
@property (nonatomic, strong, nullable) id payInfo;

/**支付结果回调*/
@property (nonatomic, weak, nullable) id<MNWebPayDelegate> payDelegate;

/**支付结束 检查订单并回调结果*/
@property (nonatomic, copy, nullable) void(^didFinishPayHandler)(MNWebPayController *);

/**
 支付结果回调
 @param URL 打开的链接
 @return 是否处理
 */
+ (BOOL)handOpenURL:(NSURL *)URL;

/**
 设置微信支付时回调我方域名
 @param domain 回调域名
 */
+ (void)setDomain:(NSString *)domain;

/**
 设置支付宝支付时回调我方应用标识
 @param scheme 应用标识
 */
+ (void)setScheme:(NSString *)scheme;

@end

NS_ASSUME_NONNULL_END
