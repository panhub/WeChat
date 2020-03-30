//
//  MNPurchaseManager.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseManager.h"
#import "MNPurchaseReceipt.h"
#import "MNURLDataRequest.h"
#import <StoreKit/StoreKit.h>

#define MNReceiptVerifyItunes    @"https://buy.itunes.apple.com/verifyReceipt"
#define MNReceiptVerifySandbox    @"https://sandbox.itunes.apple.com/verifyReceipt"

@interface SKProductsRequest (MNHelper)
@property (nonatomic, copy) NSString *productIdentifier;
@end

@implementation SKProductsRequest (MNHelper)
- (void)setProductIdentifier:(NSString *)productIdentifier {
    objc_setAssociatedObject(self, "com.mn.product.request.identifier", productIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)productIdentifier {
    return objc_getAssociatedObject(self, "com.mn.product.request.identifier");
}
@end

@interface MNPurchaseManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
@property (nonatomic, strong) MNPurchaseRequest *request;
@end

static MNPurchaseManager *_manager;
@implementation MNPurchaseManager
+ (MNPurchaseManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[MNPurchaseManager alloc] init];
        }
    });
    return _manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
    });
    return _manager;
}

- (void)startTransactionObserve {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self verifyReceiptIfNeeded];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    });
}

- (void)startPurchaseProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler {
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)startSubscribeProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler {
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.subscribe = YES;
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)restoreCompletedPurchaseWithCompletionHandler:(MNPurchaseRequestHandler)completionHandler {
    // 开启监测
    [self startTransactionObserve];
    // 检查是否满足内购要求
    if (self.request) return;
    if (MNPurchaseReceipt.hasLocalReceipt) {
        if (completionHandler) {
            completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeExistReceipt]);
        }
        return;
    }
    if (self.canPayment == NO) {
        if (completionHandler) {
            completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCannotPayment]);
        }
        return;
    }
    // 保存请求
    MNPurchaseRequest *request = MNPurchaseRequest.new;
    request.completionHandler = completionHandler;
    request.restore = YES;
    self.request = request;
    // 开启恢复购买请求
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)startRequest:(MNPurchaseRequest *)request {
    // 开启检测
    [self startTransactionObserve];
    // 检查是否满足内购要求
    if (self.request || request.productIdentifier.length <= 0 || request.isRestore) return;
    if (MNPurchaseReceipt.hasLocalReceipt) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeExistReceipt]);
        }
        return;
    }
    if (self.canPayment == NO) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCannotPayment]);
        }
        return;
    }
    // 结束所有未完成内购
    [self finishUncompleteTransactions];
    // 保存请求
    self.request = request;
    // 开始请求
    [self startProductRequest];
}

- (void)startProductRequest {
    self.request.requestCount ++;
    NSSet *productIdentifiers = [NSSet setWithArray:@[self.request.productIdentifier]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    request.productIdentifier = self.request.productIdentifier;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    /// 检查产品信息
    NSArray<SKProduct *>*products = response.products;
    if (products.count <= 0) {
        [self productsRequest:request didFailWithError:nil];
        return;
    }
    /// 开启支付行为
    SKProduct *product = products.firstObject;
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (![request isKindOfClass:SKProductsRequest.class]) return;
    [self productsRequest:(SKProductsRequest *)request didFailWithError:error];
}

- (void)productsRequest:(SKProductsRequest *)reqs didFailWithError:(NSError *)error {
    if ([reqs.productIdentifier isEqualToString:self.request.productIdentifier]) {
        if (self.request.requestCount >= self.request.requestOutCount) {
            [self finishPurchaseWithCode:MNPurchaseResponseCodeRequestError];
        } else {
            [self startProductRequest];
        }
    }
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStateRestored:
                {
                    if (self.request && self.request.isRestore == NO) {
                        [self finishTransaction:transaction];
                    } else {
                        [self completeTransaction:transaction];
                    }
                } break;
                case SKPaymentTransactionStatePurchased:
                {
                    [self completeTransaction:transaction];
                } break;
                case SKPaymentTransactionStateFailed:
                {
                    [self finishTransaction:transaction];
                } break;
                default:
                    break;
            }
        }
    });
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if ([queue.transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.transactionState == %@", @(SKPaymentTransactionStateRestored)]].count <= 0 && self.request.isRestore) {
        [self finishPurchaseWithCode:MNPurchaseResponseCodeRestoreUnknown];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (self.request.isRestore) {
        [self finishPurchaseWithCode:MNPurchaseResponseCodeRestoreUnknown];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptWithData:receiptData];
    if (!receipt) {
        // 凭据错误, 结束此次购买
        if ([self.request.productIdentifier isEqualToString:productIdentifier]) {
            [self finishPurchaseWithCode:MNPurchaseResponseCodeReceiptError];
        }
        return;
    }
    receipt.identifier = productIdentifier;
    if (receipt.identifier <= 0) receipt.identifier = transaction.transactionIdentifier;
    if (transaction.originalTransaction || self.request.isSubscribe) receipt.subscribe = YES;
    if (transaction.transactionState == SKPaymentTransactionStateRestored) receipt.restore = YES;
    // 将凭证保存沙盒
    [receipt saveReceiptToLocal];
    // 无论验证是否通过都结束此次内购操作,否则会出现虚假凭证信息一直验证不通过,每次进入程序都得输入苹果账号;
    // 收据已保存,下次开启支付前会检查收据,再次验证
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    // 验证收据
    [self verifyReceiptIfNeeded];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    MNPurchaseResponseCode code = MNPurchaseResponseCodeFailed;
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        code = MNPurchaseResponseCodeRestored;
    } else if (transaction.error.code == SKErrorPaymentCancelled) {
        code = MNPurchaseResponseCodeCancelled;
    }
    // 结束前检查是否有本地凭证, 有则删除
    if ([MNPurchaseReceipt.localReceipt.identifier isEqualToString:transaction.payment.productIdentifier]) {
        [MNPurchaseReceipt removeLocalReceipt];
    }
    // 结束此次内购操作
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    // 回调结果
    [self finishPurchaseWithCode:code];
}

#pragma mark - 验证收据
- (void)verifyReceiptIfNeeded {
    MNPurchaseReceipt *receipt = MNPurchaseReceipt.localReceipt;
    if (!receipt) return;
    #if DEBUG
    // 默认先验证正式环境, 返回环境错误再验证沙箱环境
    [self verifyReceiptToItunes:receipt sandbox:NO];
    #else
    [self verifyReceiptToServer:receipt];
    #endif
}

- (void)verifyReceiptToItunes:(MNPurchaseReceipt *)receipt sandbox:(BOOL)isSandbox {
    NSString *url = isSandbox ? MNReceiptVerifySandbox : MNReceiptVerifyItunes;
    NSString *body = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"",receipt.receipt];
    body = receipt.isSubscribe ? [NSString stringWithFormat:@"%@,\"password\":\"%@\"}", body, self.sharedKey] : [NSString stringWithFormat:@"%@}",body];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.length <= 0 || error) {
            NSLog(@"验证请求失败");
            [self finishPurchaseWithCode:MNPurchaseResponseCodeVerifyError];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!json || error) {
            [self finishPurchaseWithCode:MNPurchaseResponseCodeVerifyError];
            return;
        }
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == MNPurchaseResponseCodeServerError || status == MNPurchaseResponseCodeSandboxError) {
            [self verifyReceiptToItunes:receipt sandbox:!isSandbox];
        } else {
            if (status == MNPurchaseResponseCodeSucceed) [MNPurchaseReceipt removeLocalReceipt];
            [self finishPurchaseWithCode:status];
        }
    }];
    [dataTask resume];
}

- (void)verifyReceiptToServer:(MNPurchaseReceipt *)receipt {
    // 向服务器验证凭证<地址, 参数自定>
    MNURLDataRequest *request = MNURLDataRequest.new;
    request.method = MNURLHTTPMethodPost;
    request.timeoutInterval = 15.f;
    request.cachePolicy = MNURLDataCacheNever;
    [request loadData:^{
        
    } completion:^(MNURLResponse *response) {
        if (response.code == MNURLResponseCodeSucceed) {
            
        } else if (response.code == 106 || response.code == 107) {
            // 交易失败, 不结束transaction, 下次打开后再次验证
            [self finishTransaction:nil];
        }
    }];
}

- (void)finishUncompleteTransactions {
    for (SKPaymentTransaction *transaction in SKPaymentQueue.defaultQueue.transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased ||
            transaction.transactionState == SKPaymentTransactionStateRestored) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

- (void)finishPurchaseWithCode:(MNPurchaseResponseCode)responseCode {
    MNPurchaseRequest *request = self.request;
    if (!request) return;
    MNPurchaseManager.defaultManager.request = nil;
    MNPurchaseResponse *response = [MNPurchaseResponse responseWithCode:responseCode];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.completionHandler) request.completionHandler(response);
        [self showAlertWithResponse:response];
    });
}

- (void)showAlertWithResponse:(MNPurchaseResponse *)response {
    if (self.isAllowsAlertIfNeeded == NO || response.code == MNPurchaseResponseCodeSucceed) return;
    [[[UIAlertView alloc] initWithTitle:nil message:response.message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

#pragma mark - Getter
- (BOOL)canPayment {
    if (UIDevice.isBreakDevice) return NO;
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - dealloc
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
