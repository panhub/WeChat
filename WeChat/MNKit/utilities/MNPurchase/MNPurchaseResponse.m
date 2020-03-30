//
//  MNPurchaseResponse.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseResponse.h"

@interface MNPurchaseResponse ()

@property (nonatomic, copy) NSString *message;

@property (nonatomic) MNPurchaseResponseCode code;

@end

@implementation MNPurchaseResponse

- (instancetype)initWithResponseCode:(MNPurchaseResponseCode)code {
    if (self = [super init]) {
        self.code = code;
        self.message = [self responseMessageWithCode:code];
    }
    return self;
}

+ (instancetype)responseWithCode:(MNPurchaseResponseCode)code {
    return [[self alloc] initWithResponseCode:code];
}

- (NSString *)responseMessageWithCode:(MNPurchaseResponseCode)code {
    NSString *msg = @"发生未知错误";
    switch (code) {
        case MNPurchaseResponseCodeFailed:
        {
            msg = @"购买失败, 请检查网络后重试";
        } break;
        case MNPurchaseResponseCodeSucceed:
        {
            msg = @"购买成功";
        } break;
        case MNPurchaseResponseCodeCancelled:
        {
            msg = @"已取消";
        } break;
        case MNPurchaseResponseCodeExistReceipt:
        {
            msg = @"本地有未验证完成的收据";
        } break;
        case MNPurchaseResponseCodeCannotPayment:
        {
            msg = @"设备不支持应用内购买";
        } break;
        case MNPurchaseResponseCodeRestored:
        {
            msg = @"已有产品购买中,请耐心等待";
        } break;
        case MNPurchaseResponseCodeRestoreUnknown:
        {
            msg = @"未发现购买记录";
        } break;
        case MNPurchaseResponseCodeVerifyError:
        {
            msg = @"验证收据失败\n下次打开应用后将重新验证";
        } break;
        case MNPurchaseResponseCodeRequestError:
        {
            msg = @"获取商品信息失败\n请检查网络状态后重试";
        } break;
        case MNPurchaseResponseCodeJSONError:
        case MNPurchaseResponseCodeReceiptError:
        case MNPurchaseResponseCodeDataError:
        {
            msg = @"收据内容不合法";
        } break;
        case MNPurchaseResponseCodeSecretKeyError:
        {
            msg = @"SecretKey错误";
        } break;
        case MNPurchaseResponseCodeServerError:
        case MNPurchaseResponseCodeSandboxError:
        {
            msg = @"验证环境错误,请检查后重试";
        } break;
        case MNPurchaseResponseCodeSubscribeError:
        {
            msg = @"订阅失败";
        } break;
        case MNPurchaseResponseCodeProduceError:
        {
            msg = @"商品信息不合法";
        } break;
        case MNPurchaseResponseCodeAuthorizationError:
        {
            msg = @"服务器验证失败";
        } break;
        case MNPurchaseResponseCodeInternalError:
        {
            msg = @"请求证书错误";
        } break;
        default:
            break;
    }
    return msg;
}

@end
