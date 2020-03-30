//
//  MNPurchaseManager.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseManager.h"
#import "MNPurchaseRequest.h"
#import <StoreKit/StoreKit.h>

#define Lock()       dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()    dispatch_semaphore_signal(_semaphore)

@interface SKProductsRequest (MNHelper)
@property (nonatomic, copy) NSSet *productIdentifiers;
@end

@implementation SKProductsRequest (MNHelper)
- (void)setProductIdentifiers:(NSSet *)productIdentifiers {
    objc_setAssociatedObject(self, "com.mn.product.request.identifiers", productIdentifiers, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSSet *)productIdentifiers {
    return objc_getAssociatedObject(self, "com.mn.product.request.identifiers");
}
@end

@interface MNPurchaseManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
    NSMutableDictionary <NSString *, MNPurchaseRequest *>*_requestDic;
}
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
        if (_manager) {
            _semaphore = dispatch_semaphore_create(1);
            _queue = dispatch_queue_create("com.mn.reachability.queue", DISPATCH_QUEUE_SERIAL);
            _requestDic = [NSMutableDictionary dictionary];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:_manager];
        }
    });
    return _manager;
}

- (void)startRequest:(MNPurchaseRequest *)request {
    /// 检查该产品是否在支付处理中
    if ([self purchaseRequestForProduct:request.productIdentifier]) {
        [request finishRequestWithResponseCode:MNPurchaseResponseCodeRepeated];
        return;
    }
    /// 判断是否支持内购
    if (self.canPayment == NO) {
        [request finishRequestWithResponseCode:MNPurchaseResponseCodeCannotPayment];
        return;
    }
    /// 添加支付请求
    [self addRequest:request];
    /// 开启支付
    [self startRequestPayment:request.productIdentifier];
}

- (void)startRequestPayment:(NSString *)productId {
    MNPurchaseRequest *re = [self purchaseRequestForProduct:productId];
    re.requestCount ++;
    NSSet *productIdentifiers = [NSSet setWithArray:@[productId]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    request.productIdentifiers = productIdentifiers;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    /// 检查产品信息
    NSArray<SKProduct *>*products = response.products;
    if (products.count <= 0) {
        NSSet *productIdentifiers = request.productIdentifiers;
        NSString *productId = productIdentifiers.anyObject;
        if (productId.length > 0) {
            MNPurchaseRequest *request = [self purchaseRequestForProduct:productId];
            if (request.requestCount >= request.requestOutCount) {
                [self didFinishPayment:productId withCode:MNPurchaseResponseCodeProductError];
            } else {
                [self startRequestPayment:productId];
            }
        }
        return;
    }
    /// 开启支付行为
    SKProduct *p = products.firstObject;
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:p];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)request:(SKRequest *)re didFailWithError:(NSError *)error {
    if (![re isKindOfClass:SKProductsRequest.class]) return;
    SKProductsRequest *request = (SKProductsRequest *)re;
    [self didFinishPayment:request.productIdentifiers.anyObject
                              withCode:MNPurchaseResponseCodeNetworkError];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions { //SKPaymentTransactionStatePurchased
    dispatch_async(_queue, ^{
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchasing:
                {
                    /// 添加到支付行列
                } break;
                case SKPaymentTransactionStatePurchased:
                {
                    /// 购买成功
                    
                } break;
                    
                default:
                    break;
            }
        }
    });
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
    
}

#pragma mark - Updated Transaction
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.originalTransaction) {
        // 订阅处理
    } else {
        // 第一次购买或订阅
    }
    // Your application should implement these two methods.
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
    }

    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

#pragma mark - Private
- (void)addRequest:(MNPurchaseRequest *)request {
    Lock();
    [_requestDic setObject:request forKey:request.productIdentifier];
    Unlock();
}

- (MNPurchaseRequest *)purchaseRequestForProduct:(NSString *)productId {
    if (productId.length <= 0) return nil;
    Lock();
    MNPurchaseRequest *request = [_requestDic objectForKey:productId];
    Unlock();
    return request;
}

- (void)removePurchaseRequestForProduct:(NSString *)productId {
    if (productId.length <= 0) return;
    Lock();
    [_requestDic removeObjectForKey:productId];
    Unlock();
}

- (void)didFinishPayment:(NSString *)productId withCode:(MNPurchaseResponseCode)responseCode {
    MNPurchaseRequest *request = [self purchaseRequestForProduct:productId];
    [self removePurchaseRequestForProduct:productId];
    [request finishRequestWithResponseCode:responseCode];
}

- (BOOL)canPayment {
    return [SKPaymentQueue canMakePayments];
}

- (void)showErrorAlertViewMessage:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

#pragma mark - dealloc
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
