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

/**
 WX回调我方域名<example:// 或 example>
*/
UIKIT_EXTERN void MNWebPaySetDomain (NSString *);
/**
 ZFB回调我方APP标识<URL type 标识>
*/
UIKIT_EXTERN void MNWebPaySetScheme (NSString *);

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

@end

NS_ASSUME_NONNULL_END
