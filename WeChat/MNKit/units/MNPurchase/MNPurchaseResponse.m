//
//  MNPurchaseResponse.m
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseResponse.h"
#import "MNPurchaseRequest.h"
#import "MNPurchaseReceipt.h"

@interface MNPurchaseResponse ()
@property (nonatomic) MNPurchaseResponseCode code;
@property (nonatomic, strong) MNPurchaseRequest *request;
@property (nonatomic, strong) NSArray <MNPurchaseReceipt *>*receipts;
@end

@implementation MNPurchaseResponse

- (instancetype)initWithResponseCode:(MNPurchaseResponseCode)code {
    if (self = [super init]) {
        self.code = code;
    }
    return self;
}

+ (instancetype)responseWithCode:(MNPurchaseResponseCode)code {
    return [[self alloc] initWithResponseCode:code];
}

#pragma mark - Setter
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"⚠️⚠️⚠️⚠️ %@ undefined key:%@ ⚠️⚠️⚠️⚠️", NSStringFromClass(self.class), key);
}

#pragma mark - Getter
- (NSString *)message {
    NSString *msg = @"无法连接iTunesStore";
    switch (self.code) {
        case MNPurchaseResponseCodeFailed:
        {
            msg = self.receipts ? (self.receipts.firstObject.isLocal ? @"本地订单校验失败" : @"订单校验失败") : @"支付失败";
            if (self.request) {
                msg = self.request.isRestore ? @"恢复购买失败" : (self.request.isCheckout ? @"本地订单校验失败" : msg);
            }
        } break;
        case MNPurchaseResponseCodeSucceed:
        {
            msg = self.receipts ? (self.receipts.firstObject.isLocal ? @"本地订单校验成功" : @"订单校验成功") : @"支付成功";
            if (self.request) {
                msg = self.request.isRestore ? @"恢复购买成功" : (self.request.isCheckout ? @"本地订单校验成功" : @"支付成功");
            }
        } break;
        case MNPurchaseResponseCodeCancelled:
        {
            msg = @"支付已取消";
        } break;
        case MNPurchaseResponseCodeNotSupport:
        {
            msg = @"设备不支持应用内购买";
        } break;
        case MNPurchaseResponseCodeRestoreNotAllowed:
        {
            msg = @"消耗型商品购买后不可恢复";
        } break;
        case MNPurchaseResponseCodeRestoreNone:
        {
            msg = @"未发现可恢复购买项目";
        } break;
        case MNPurchaseResponseCodeRequestFailed:
        {
            msg = @"获取商品信息失败";
        } break;
        case MNPurchaseResponseCodeBusying:
        {
            msg = @"产品购买中 请勿重复购买";
        } break;
        case MNPurchaseResponseCodePermissionDenied:
        {
            msg = @"无法访问云服务项目";
        } break;
        case MNPurchaseResponseCodeNetworkError:
        {
            msg = @"网络错误 请检查后重试";
        } break;
        case MNPurchaseResponseCodePaymentInvalid:
        {
            msg = @"商品信息无效";
        } break;
        case MNPurchaseResponseCodeCheckoutNone:
        {
            msg = @"未发现本地订单";
        } break;
        case MNPurchaseResponseCodeNotLogin:
        {
            msg = @"未登录 无法校验订单";
        } break;
        case MNPurchaseResponseCodeReceiptInvalid:
        {
            msg = @"支付收据无效";
        } break;
        case MNPurchaseResponseCodeReceiptError:
        {
            msg = self.receipts ? @"收据内容不合法" : @"创建收据失败";
        } break;
        case MNPurchaseResponseCodeJSONError:
        case MNPurchaseResponseCodeDataError:
        {
            msg = @"收据内容不合法";
        } break;
        case MNPurchaseResponseCodeSecretKeyError:
        {
            msg = @"订阅密钥错误";
        } break;
        case MNPurchaseResponseCodeServerError:
        {
            msg = @"服务器繁忙 请稍后重试";
        } break;
        case MNPurchaseResponseCodeSandboxError:
        case MNPurchaseResponseCodeProductionError:
        {
            msg = @"验证环境错误";
        } break;
        case MNPurchaseResponseCodeSubscribeError:
        {
            msg = @"订阅已过期";
        } break;
        case MNPurchaseResponseCodeAuthorizationError:
        {
            msg = @"服务器验证失败";
        } break;
        case MNPurchaseResponseCodeInternalError:
        {
            msg = @"请求证书验证失败";
        } break;
        default:
            break;
    }
    return msg;
}

@end
