//
//  MNPurchaseCheckout.m
//  MNKit
//
//  Created by Vicent on 2020/9/26.
//

#import "MNPurchaseCheckout.h"
#import "MNPurchaseReceipt.h"

@implementation MNPurchaseCheckout

+ (void)checkoutReceiptToItunes:(MNPurchaseReceipt *)receipt secretKey:(NSString *)secretKey resultHandler:(void(^)(MNPurchaseResponseCode))resultHandler {
    [self checkoutReceiptToItunes:receipt secretKey:secretKey sandbox:NO resultHandler:resultHandler];
}

+ (void)checkoutReceiptToItunes:(MNPurchaseReceipt *)receipt secretKey:(NSString *)secretKey sandbox:(BOOL)isSandbox resultHandler:(void(^)(MNPurchaseResponseCode))resultHandler {
    if (!receipt || receipt.content.length <= 0) {
        if (resultHandler) resultHandler(MNPurchaseResponseCodeReceiptError);
        return;
    }
    NSString *url = isSandbox ? @"https://sandbox.itunes.apple.com/verifyReceipt" : @"https://buy.itunes.apple.com/verifyReceipt";
    NSString *body = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"",receipt.content];
    body = secretKey ? [NSString stringWithFormat:@"%@,\"password\":\"%@\"}", body, secretKey ? : @""] : [NSString stringWithFormat:@"%@}",body];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (resultHandler) resultHandler([self responseCodeWithStatus:error.code]);
            return;
        }
        if (!data) {
            if (resultHandler) resultHandler(MNPurchaseResponseCodeFailed);
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!json || error) {
            if (resultHandler) resultHandler(MNPurchaseResponseCodeFailed);
            return;
        }
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == 21007 || status == 21008) {
            [self checkoutReceiptToItunes:receipt secretKey:secretKey sandbox:!isSandbox resultHandler:resultHandler];
            return;
        }
        MNPurchaseResponseCode responseCode = [self responseCodeWithStatus:status];
        /*
        if (responseCode == MNPurchaseResponseCodeSucceed) {
            // 分析数据
            NSDictionary *product = [self seekProductInContainer:[json objectForKey:@"latest_receipt_info"] receipt:receipt];
            if (!product) product = [self seekProductInContainer:[(NSDictionary *)[json objectForKey:@"receipt"] objectForKey:@"in_app"] receipt:receipt];
            if (!product) responseCode = MNPurchaseResponseCodeFailed;
        }
        */
        if (resultHandler) resultHandler(responseCode);
    }] resume];
}

+ (NSDictionary *)seekProductInContainer:(NSArray <NSDictionary *>*)container receipt:(MNPurchaseReceipt *)receipt {
    if (!container || ![container isKindOfClass:NSArray.class] || container.count <= 0) return nil;
    NSDictionary *product = nil;
    NSString *transactionIdentifier = receipt.transactionIdentifier;
    for (NSDictionary *dic in container) {
        NSString *transaction_id = [dic objectForKey:@"transaction_id"];
        if ([transaction_id isEqualToString:transactionIdentifier]) {
            product = dic;
            break;
        }
    }
    return product;
}

+ (MNPurchaseResponseCode)responseCodeWithStatus:(NSInteger)code {
    MNPurchaseResponseCode responseCode = MNPurchaseResponseCodeFailed;
    switch (code) {
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorNotConnectedToInternet:
        {
            responseCode = MNPurchaseResponseCodeNetworkError;
        } break;
        case 0:
        {
            responseCode = MNPurchaseResponseCodeSucceed;
        } break;
        case 21000:
        {
            responseCode = MNPurchaseResponseCodeJSONError;
        } break;
        case 21002:
        {
            responseCode = MNPurchaseResponseCodeDataError;
        }
        break;
        case 21003:
        {
            responseCode = MNPurchaseResponseCodeReceiptError;
        }
        break;
        case 21004:
        {
            responseCode = MNPurchaseResponseCodeSecretKeyError;
        }
        break;
        case 21005:
        {
            responseCode = MNPurchaseResponseCodeServerError;
        }
        break;
        case 21006:
        {
            responseCode = MNPurchaseResponseCodeSubscribeError;
        }
        break;
        case 21007:
        {
            responseCode = MNPurchaseResponseCodeSandboxError;
        }
        break;
        case 21008:
        {
            responseCode = MNPurchaseResponseCodeProductionError;
        }
        break;
        case 21010:
        {
            responseCode = MNPurchaseResponseCodeAuthorizationError;
        }
        break;
        case 21100:
        {
            responseCode = MNPurchaseResponseCodeInternalError;
        }
        break;
        default:
        {
            responseCode = MNPurchaseResponseCodeFailed;
        } break;
    }
    return responseCode;
}

@end
