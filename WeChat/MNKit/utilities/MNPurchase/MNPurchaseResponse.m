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
    NSString *msg = @"无法连接iTunesStore";
    switch (code) {
        case MNPurchaseResponseCodeSucceed:
        {
            msg = @"操作成功";
        } break;
        case MNPurchaseResponseCodeCancelled:
        {
            msg = @"已取消";
        } break;
        case MNPurchaseResponseCodeCannotPayment:
        {
            msg = @"设备不支持应用内购买";
        } break;
        case MNPurchaseResponseCodeRestored:
        {
            msg = @"消耗型商品购买后不可恢复";
        } break;
        case MNPurchaseResponseCodeRestoreError:
        {
            msg = @"恢复购买失败";
        } break;
        case MNPurchaseResponseCodeRestoreNone:
        {
            msg = @"未发现可恢复购买产品";
        } break;
        case MNPurchaseResponseCodeVerifyError:
        {
            msg = @"验证收据失败";
        } break;
        case MNPurchaseResponseCodeRequestError:
        {
            msg = @"获取商品信息失败";
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
            msg = @"验证环境错误";
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
