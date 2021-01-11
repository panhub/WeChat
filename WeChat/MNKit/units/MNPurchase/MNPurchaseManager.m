//
//  MNPurchaseManager.m
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseManager.h"
#if __has_include(<StoreKit/StoreKit.h>)
#import <StoreKit/StoreKit.h>
#import <objc/runtime.h>
#import "MNPurchaseCheckout.h"

NSNotificationName const MNPurchaseFinishNotificationName = @"com.mn.purchase.finish.notification.name";

@interface SKRequest (MNProductContent)
@property (nonatomic, copy) NSString *identifier;
@end

@implementation SKRequest (MNProductContent)

- (void)setIdentifier:(NSString *)identifier {
    objc_setAssociatedObject(self, "com.mn.purchase.request.identifier", identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)identifier {
    return objc_getAssociatedObject(self, "com.mn.purchase.request.identifier");
}

@end

@interface SKPaymentTransaction (MNProductContent)
@property (nonatomic, copy) NSString *identifier;
@end

@implementation SKPaymentTransaction (MNProductContent)

- (void)setIdentifier:(NSString *)identifier {
    objc_setAssociatedObject(self, "com.mn.purchase.transaction.identifier", identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)identifier {
    return objc_getAssociatedObject(self, "com.mn.purchase.transaction.identifier");
}

@end

@interface MNPurchaseManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    @private
    dispatch_queue_t _purchase_serial_queue;
    SKPaymentQueue *_purchase_payment_queue;
}
/**恢复购买/本地订单验证数量*/
@property (nonatomic) NSInteger count;
/**恢复购买/本地订单验证索引*/
@property (nonatomic) NSInteger index;
/**恢复购买/本地订单验证结果*/
@property (nonatomic) MNPurchaseResponseCode code;
/**当前请求*/
@property (nonatomic, strong) MNPurchaseRequest *request;
/**恢复购买/本地收据集合*/
@property (nonatomic, strong) NSMutableArray <MNPurchaseReceipt *>*receipts;
@end

static MNPurchaseManager *_manager;
#define MN_PURCHASE_SERIAL_QUEUE        _purchase_serial_queue
#define MN_PURCHASE_PAYMENT_QUEUE    _purchase_payment_queue

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
        _manager.maxFailCount = 3;
        _manager.maxRequestCount = 2;
        _manager.maxCheckoutCount = 2;
        _manager.checkoutToItunes = NO;
        _manager.receipts = @[].mutableCopy;
        _purchase_serial_queue = dispatch_queue_create("com.mn.purchase.serial.queue", DISPATCH_QUEUE_SERIAL);
        _purchase_payment_queue = SKPaymentQueue.defaultQueue;
    });
    return _manager;
}

- (void)becomeTransactionObserver {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [MN_PURCHASE_PAYMENT_QUEUE addTransactionObserver:self];
    });
}

- (void)startPurchasing:(NSString *)productId
           startHandler:(MNPurchaseStatusHandler)statusHandler
      completionHandler:(MNPurchaseCompletionHandler)completionHandler
{
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    [self startRequest:request statusHandler:statusHandler completionHandler:completionHandler];
}

- (void)startRestore:(MNPurchaseStatusHandler)statusHandler
        completionHandler:(MNPurchaseCompletionHandler)completionHandler
{
    MNPurchaseRequest *request = MNPurchaseRequest.new;
    [request makeRestoreUsable];
    [self startRequest:request statusHandler:statusHandler completionHandler:completionHandler];
}

- (void)startCheckout:(MNPurchaseStatusHandler)statusHandler completionHandler:(MNPurchaseCompletionHandler)completionHandler {
    MNPurchaseRequest *request = MNPurchaseRequest.new;
    [request makeCheckoutUsable];
    [self startRequest:request statusHandler:statusHandler completionHandler:completionHandler];
}

- (void)resumePurchasing:(MNPurchaseStatusHandler)statusHandler
     completionHandler:(MNPurchaseCompletionHandler)completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MNPurchaseRequest *request = self.request;
        if (!request || request.isLoading == NO) return;
        [request setValue:[statusHandler copy] forKey:@"statusHandler"];
        [request setValue:[completionHandler copy] forKey:@"completionHandler"];
        [request signal];
    });
}

- (void)startRequest:(MNPurchaseRequest *)request
       statusHandler:(MNPurchaseStatusHandler)statusHandler
   completionHandler:(MNPurchaseCompletionHandler)completionHandler
{
    // 检查是否支持内购<含有主线程操作>
    if (self.canPayment == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeNotSupport]);
            }
        });
        return;
    }
    // 开启分线程
    dispatch_async(MN_PURCHASE_SERIAL_QUEUE, ^{
        // 产品购买中, 返回繁忙
        if (self.request) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeBusying]);
                }
            });
            return;
        }
        // 开启交易会话监听
        [self becomeTransactionObserver];
        // 检查是否有本地订单未验证 有则关联并检验
        if (MNPurchaseReceipt.localCount > 0) {
            [request makeCheckoutUsable];
            if (statusHandler) [request setValue:[statusHandler copy] forKey:@"statusHandler"];
            if (completionHandler) [request setValue:[completionHandler copy] forKey:@"completionHandler"];
            request.status = MNPurchaseStatusCheckout;
            self.request = request;
            [self checkoutReceipts];
            return;
        }
        // 判断是否是校验本地订单请求
        if (request.isCheckout) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCheckoutNone]);
                }
            });
            return;
        }
        // 检查产品id是否完整
        if (request.isValid == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodePaymentInvalid]);
                }
            });
            return;
        }
        // 保存请求并开始
        if (statusHandler) [request setValue:[statusHandler copy] forKey:@"statusHandler"];
        if (completionHandler) [request setValue:[completionHandler copy] forKey:@"completionHandler"];
        request.status = MNPurchaseStatusGetting;
        self.request = request;
        [self.receipts removeAllObjects];
        if (request.isRestore) {
            [MN_PURCHASE_PAYMENT_QUEUE restoreCompletedTransactionsWithApplicationUsername:self.applicationUsername];
        } else {
            [self startProductRequest];
        }
    });
}

- (void)startProductRequest {
    self.request.requestCount ++;
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.request.productIdentifier]];
    request.delegate = self;
    request.identifier = self.request.identifier;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // 检查产品信息
    NSArray<SKProduct *>*products = response.products;
    if (products.count <= 0) {
        [self productsRequestDidFail:request error:[NSError errorWithDomain:SKErrorDomain code:SKErrorPaymentInvalid userInfo:nil]];
        return;
    }
    // 添加至支付队列
    SKProduct *product = products.firstObject;
    self.request.price = product.price.doubleValue;
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    payment.applicationUsername = self.applicationUsername;
    [MN_PURCHASE_PAYMENT_QUEUE addPayment:payment];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self productsRequestDidFail:request error:error];
}

- (void)productsRequestDidFail:(SKRequest *)reqs error:(NSError *)error {
    if ([reqs.identifier isEqualToString:self.request.identifier] && self.request.requestCount < self.maxRequestCount) {
        [self startProductRequest];
    } else {
        [self finishPurchase:nil responseCode:[self responseCodeWithError:error def:MNPurchaseResponseCodeRequestFailed]];
    }
}

- (MNPurchaseResponseCode)responseCodeWithError:(NSError *)error def:(MNPurchaseResponseCode)def {
    SKErrorCode errorCode = error.code;
    MNPurchaseResponseCode code = def;
    if (errorCode == SKErrorClientInvalid) {
        code = MNPurchaseResponseCodeNetworkError;
    } else if (errorCode == SKErrorPaymentCancelled || errorCode == NSURLErrorCancelled) {
        code = MNPurchaseResponseCodeCancelled;
    } else if (errorCode == SKErrorPaymentNotAllowed) {
        code = MNPurchaseResponseCodeNotSupport;
    } else if (errorCode == SKErrorStoreProductNotAvailable || errorCode == SKErrorPaymentInvalid) {
        code = MNPurchaseResponseCodePaymentInvalid;
    } else if (errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorNetworkConnectionLost || errorCode == NSURLErrorCannotConnectToHost || errorCode == NSURLErrorCannotFindHost) {
        code = MNPurchaseResponseCodeNetworkError;
    }
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90300
    if (@available(iOS 9.3, *)) {
        if (errorCode == SKErrorCloudServicePermissionDenied) {
            code = MNPurchaseResponseCodePermissionDenied;
        } else if (errorCode == SKErrorCloudServiceNetworkConnectionFailed) {
            code = MNPurchaseResponseCodeNetworkError;
        }
    }
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120200
    if (@available(iOS 12.2, *)) {
        if (errorCode == SKErrorInvalidOfferIdentifier) {
            code = MNPurchaseResponseCodeSecretKeyError;
        } else if (errorCode == SKErrorOverlayCancelled) {
            code = MNPurchaseResponseCodeCancelled;
        }
    }
#endif
#endif
    return code;
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchasing:
                {
                    if (self.request && self.request.productIdentifier.length) {
                        transaction.identifier = self.request.identifier;
                        self.request.status = MNPurchaseStatusPurchasing;
                    }
                } break;
                case SKPaymentTransactionStateRestored:
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
    NSArray<SKPaymentTransaction *> *transactions = [queue.transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.transactionState == %@", @(SKPaymentTransactionStateRestored)]];
    // 记录恢复购买的个数并重置结果
    self.index = 0;
    self.count = transactions.count;
    self.code = MNPurchaseResponseCodeFailed;
    // 未发现可恢复项目 回调错误
    if (self.request.isRestore && transactions.count <= 0) [self finishPurchase:nil responseCode:MNPurchaseResponseCodeRestoreNone];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    // 恢复购买失败
    if (self.request && self.request.isRestore) {
        self.index = 0;
        self.count = 0;
        self.code = [self responseCodeWithError:error def:MNPurchaseResponseCodeRestoreNone];
        [self finishPurchase:nil responseCode:MNPurchaseResponseCodeFailed];
    }
}

#pragma mark - Payment Transaction
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    dispatch_async(MN_PURCHASE_SERIAL_QUEUE, ^{
        NSString *identifier = transaction.identifier;
        NSString *transactionIdentifier = transaction.transactionIdentifier;
        NSString *productIdentifier = transaction.payment.productIdentifier;
        NSString *applicationUsername = transaction.payment.applicationUsername;
        long long transactionDate = transaction.transactionDate ? (long long)(transaction.transactionDate.timeIntervalSince1970*1000) : 0;
        SKPaymentTransaction *originalTransaction = transaction.originalTransaction;
        NSString *originalTransactionIdentifier = originalTransaction ? originalTransaction.transactionIdentifier : nil;
        long long originalTransactionDate = originalTransaction ? (long long)(originalTransaction.transactionDate.timeIntervalSince1970*1000) : 0;
        SKPaymentTransactionState transactionState = transaction.transactionState;
        NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
        // NSData *receiptData = transaction.transactionReceipt;
        // 结束恢复购买的事务队列
        if (transactionState == SKPaymentTransactionStateRestored) {
            [MN_PURCHASE_PAYMENT_QUEUE finishTransaction:transaction];
            if (!self.request || !self.request.isRestore) return;
            self.request.status = MNPurchaseStatusCheckout;
        }
        // 创建购买收据
        MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptWithData:receiptData];
        if (!receipt) {
            // 收据错误 回调失败
            NSLog(@"⚠️⚠️⚠️⚠️⚠️ 创建收据失败 ⚠️⚠️⚠️⚠️⚠️");
            [self finishPurchase:nil responseCode:MNPurchaseResponseCodeReceiptError];
            return;
        }
        // 关联内购收据
        MNPurchaseRequest *request = self.request;
        receipt.productIdentifier = productIdentifier;
        receipt.transactionIdentifier = transactionIdentifier;
        receipt.applicationUsername = applicationUsername;
        receipt.originalTransactionIdentifier = originalTransactionIdentifier;
        receipt.restore = transactionState == SKPaymentTransactionStateRestored;
        if (!receipt.isRestore) receipt.subscribe = originalTransaction != nil;
        receipt.transactionDate = [[NSNumber numberWithLongLong:transactionDate] stringValue];
        receipt.originalTransactionDate = [[NSNumber numberWithLongLong:originalTransactionDate] stringValue];
        // 判断若是正在请求的购买收据就绑定信息并缓存
        if (request && identifier && [identifier isEqualToString:request.identifier]) {
            receipt.price = request.price;
            receipt.identifier = identifier;
            receipt.userInfo = self.userInfo;
            // 这里直接调用收据保存 避免死锁
            [MNPurchaseReceipt insertReceipt:receipt];
            request.status = MNPurchaseStatusCheckout;
        }
        // 验证收据
        [self checkoutReceipt:receipt];
    });
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    // 结束失败内购队列并响应失败
    NSError *error = transaction.error;
    [MN_PURCHASE_PAYMENT_QUEUE finishTransaction:transaction];
    MNPurchaseResponseCode responseCode = [self responseCodeWithError:error def:MNPurchaseResponseCodeFailed];
    [self finishPurchase:nil responseCode:responseCode];
}

- (void)finishTransactionWithIdentifier:(NSString *)identifier {
    if (!identifier || identifier.length <= 0) return;
    dispatch_sync(MN_PURCHASE_SERIAL_QUEUE, ^{
        for (SKPaymentTransaction *transaction in MN_PURCHASE_PAYMENT_QUEUE.transactions) {
            NSString *transactionIdentifier = transaction.transactionIdentifier;
            SKPaymentTransactionState transactionState = transaction.transactionState;
            if ((transactionState == SKPaymentTransactionStatePurchased || transactionState == SKPaymentTransactionStateRestored) && [transactionIdentifier isEqualToString:identifier]) {
                [MN_PURCHASE_PAYMENT_QUEUE finishTransaction:transaction];
            }
        }
    });
}

- (void)finishUncompleteTransactions {
    dispatch_sync(MN_PURCHASE_SERIAL_QUEUE, ^{
        for (SKPaymentTransaction *transaction in MN_PURCHASE_PAYMENT_QUEUE.transactions) {
            SKPaymentTransactionState transactionState = transaction.transactionState;
            if (transactionState == SKPaymentTransactionStatePurchased ||
                transactionState == SKPaymentTransactionStateRestored) {
                [MN_PURCHASE_PAYMENT_QUEUE finishTransaction:transaction];
            }
        }
    });
}

#pragma mark - 验证收据
- (void)checkoutReceipts {
    // 本地收据通常只会存在一个
    self.index = 0;
    self.count = MNPurchaseReceipt.localCount;
    self.code = MNPurchaseResponseCodeFailed;
    [self.receipts removeAllObjects];
    [MNPurchaseReceipt enumerateReceiptsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.local = YES;
        [self checkoutReceipt:obj];
    }];
}

- (void)checkoutReceipt:(MNPurchaseReceipt *)receipt {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        receipt.checkoutCount ++;
        __weak typeof(self) weakself = self;
        void(^checkoutResultHandler)(MNPurchaseResponseCode) = ^(MNPurchaseResponseCode responseCode) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [weakself finishCheckout:receipt responseCode:responseCode];
            });
        };
        if (self.isCheckoutToItunes) {
            // 向Itunes验证支付收据
            [MNPurchaseCheckout checkoutReceiptToItunes:receipt secretKey:self.secretKey resultHandler:[checkoutResultHandler copy]];
        } else if ([self.delegate respondsToSelector:@selector(purchaseManagerNeedCheckoutReceipt:resultHandler:)]) {
            // 向服务端验证支付收据
            [self.delegate purchaseManagerNeedCheckoutReceipt:receipt.copy resultHandler:[checkoutResultHandler copy]];
        } else {
            // 设置向服务端验证收据却没实现代理
            NSLog(@"⚠️⚠️⚠️⚠️⚠️ %@ please responds selector \"purchaseManagerNeedCheckoutReceipt:resultHandler:\" ⚠️⚠️⚠️⚠️⚠️", NSStringFromClass(self.delegate.class));
            receipt.checkoutCount = self.maxCheckoutCount;
            [self finishCheckout:receipt responseCode:MNPurchaseResponseCodeFailed];
        }
    });
}

- (void)finishCheckout:(MNPurchaseReceipt *)receipt responseCode:(MNPurchaseResponseCode)code {
    // 判断是否继续校验
    if (code == MNPurchaseResponseCodeSucceed) {
        // 校验成功, 是不是本地都要查找删除, 避免自动校验成功后存在本地收据
        if (!receipt.isRestore) {
            [self removeReceipt:receipt];
            [self finishTransactionWithIdentifier:receipt.transactionIdentifier];
        }
        [self finishPurchase:receipt responseCode:MNPurchaseResponseCodeSucceed];
    } else if (receipt.checkoutCount >= self.maxCheckoutCount) {
        // 校验失败, 回调失败结果
        if (code != MNPurchaseResponseCodeNetworkError && code != MNPurchaseResponseCodeNotLogin && self.request && ([receipt.identifier isEqualToString:self.request.identifier] || receipt.isLocal)) {
            if ((self.maxFailCount > 0 && (receipt.failCount + 1) >= self.maxFailCount) || code == MNPurchaseResponseCodeReceiptInvalid) {
                // 失败次数超过最大限制或者指定凭据无效
                [self removeReceipt:receipt];
                [self finishTransactionWithIdentifier:receipt.transactionIdentifier];
            } else {
                // 标记失败次数
                receipt.failCount ++;
                [self updateReceipt:receipt];
            }
        }
        NSLog(@"⚠️⚠️⚠️⚠️⚠️ 订单验证失败 ⚠️⚠️⚠️⚠️⚠️");
        [self finishPurchase:receipt responseCode:code];
    } else {
        // 再次提交校验
        [self checkoutReceipt:receipt];
    }
}

#pragma mark - Finish Purchase
- (void)finishPurchase:(MNPurchaseReceipt *)receipt responseCode:(MNPurchaseResponseCode)responseCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MNPurchaseResponse *response = nil;
        MNPurchaseRequest *request = self.request;
        MNPurchaseResponseCode code = responseCode;
        if (request && (!receipt || (receipt.isRestore && request.isRestore) || (receipt.isLocal && request.isCheckout) || [receipt.identifier isEqualToString:request.identifier])) {
            // 暂存收据 判断是否需要等待校验全部结束
            if (receipt) {
                [self.receipts addObject:receipt];
                if (receipt.isLocal || receipt.isRestore) {
                    if ((self.index + 1) < self.count) {
                        self.index ++;
                        if (code == MNPurchaseResponseCodeSucceed) self.code = code;
                        return;
                    }
                    if (code != MNPurchaseResponseCodeSucceed && code != MNPurchaseResponseCodeRestoreNone) code = self.code;
                    self.index = 0;
                    self.count = 0;
                    self.code = MNPurchaseResponseCodeFailed;
                }
            }
            // 恢复请求状态 回调内购结果
            self.request = nil;
            // 响应结果
            response = [MNPurchaseResponse responseWithCode:code];
            [response setValue:request forKey:@"request"];
            if (self.receipts.count) [response setValue:self.receipts.copy forKey:@"receipts"];
            [self.receipts removeAllObjects];
            [request didFinishWithResponse:response];
        } else {
            // 没有购买请求或收据与请求不匹配<自动订阅或未结束收据>
            response = [MNPurchaseResponse responseWithCode:code];
            if (receipt) [response setValue:@[receipt] forKey:@"receipts"];
        }
        if ([self.delegate respondsToSelector:@selector(purchaseManagerDidFinishPurchasing:)]) {
            [self.delegate purchaseManagerDidFinishPurchasing:response];
        }
        [NSNotificationCenter.defaultCenter postNotificationName:MNPurchaseFinishNotificationName object:response];
    });
}

#pragma mark - 删除收据
- (BOOL)removeReceipt:(MNPurchaseReceipt *)receipt {
    __block BOOL result = NO;
    dispatch_sync(MN_PURCHASE_SERIAL_QUEUE, ^{
        result = [MNPurchaseReceipt removeReceipt:receipt];
    });
    return result;
}

- (void)removeAllReceipts {
    dispatch_sync(MN_PURCHASE_SERIAL_QUEUE, ^{
        [MNPurchaseReceipt removeAllReceipts];
    });
}

#pragma mark - 更新收据
- (BOOL)updateReceipt:(MNPurchaseReceipt *)receipt {
    __block BOOL result = NO;
    dispatch_sync(MN_PURCHASE_SERIAL_QUEUE, ^{
        result = [receipt update];
    });
    return result;
}


#pragma mark - Setter
- (void)setMaxCheckoutCount:(int)maxCheckoutCount {
    _maxCheckoutCount = MAX(1, maxCheckoutCount);
}

- (void)setMaxRequestCount:(int)maxRequestCount {
    _maxRequestCount = MAX(1, maxRequestCount);
}

#pragma mark - Getter
- (BOOL)canPayment {
#ifdef TARGET_IPHONE_SIMULATOR
    if (TARGET_IPHONE_SIMULATOR) return NO;
#endif
#if __has_include("UIDevice+MNHelper.h")
    if (UIDevice.isBreakDevice) return NO;
#endif
    return [SKPaymentQueue canMakePayments];
}

@end
#endif
