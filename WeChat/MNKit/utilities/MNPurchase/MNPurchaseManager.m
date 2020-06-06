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
#define Lock()  dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(_semaphore)

NSNotificationName const MNPurchaseFinishNotificationName = @"com.mn.purchase.finish.notification.name";
NSNotificationName const MNPurchaseSubmitLocalNotificationName = @"com.mn.purchase.submit.local.notification.name";

@interface SKProductsRequest (MNProductContent)
@property (nonatomic, copy) NSString *productIdentifier;
@end

@implementation SKProductsRequest (MNProductContent)
- (void)setProductIdentifier:(NSString *)productIdentifier {
    objc_setAssociatedObject(self, "com.mn.product.request.identifier", productIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)productIdentifier {
    return objc_getAssociatedObject(self, "com.mn.product.request.identifier");
}
@end

@interface MNPurchaseManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic) NSInteger totalRestoreCount;
@property (nonatomic) NSInteger currentRestoreIndex;
@property (nonatomic) MNPurchaseResponseCode restoreCode;
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
        _manager.receiptMaxFailCount = 3;
        _manager.receiptMaxSubmitCount = 3;
#ifdef DEBUG
#if DEBUG
        _manager.useItunesSubmitReceipt = YES;
#endif
#endif
        _semaphore = dispatch_semaphore_create(1);
    });
    return _manager;
}

- (void)becomeTransactionObserver {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self submitLocalReceipts];
    });
}

- (void)startPurchaseProduct:(NSString *)productId
                startHandler:(MNPurchaseStartHandler)startHandler
           completionHandler:(MNPurchaseFinishHandler)completionHandler
{
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.restore = NO;
    request.subscribe = NO;
    request.startHandler = startHandler;
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)startSubscribeProduct:(NSString *)productId
                 startHandler:(MNPurchaseStartHandler)startHandler
            completionHandler:(MNPurchaseFinishHandler)completionHandler
{
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.restore = NO;
    request.subscribe = YES;
    request.startHandler = startHandler;
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)startRestorePurchase:(MNPurchaseStartHandler)startHandler
           completionHandler:(MNPurchaseFinishHandler)completionHandler
{
    // 创建恢复购买请求
    MNPurchaseRequest *request = MNPurchaseRequest.new;
    request.startHandler = startHandler;
    request.completionHandler = completionHandler;
    request.restore = YES;
    request.subscribe = NO;
    [self startRestore:request];
}

- (void)startRestore:(MNPurchaseRequest *)request {
    // 开启监测
    [self becomeTransactionObserver];
    // 检查是否满足内购要求
    if (self.request) return;
    if (self.canPayment == NO) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCannotPayment]);
        }
        return;
    }
    // 保存请求并开始恢复购买
    request.productIdentifier = nil;
    self.request = request;
    if (request.startHandler) request.startHandler(request);
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)startRequest:(MNPurchaseRequest *)request {
    if (request.isRestore) {
        [self startRestore:request];
        return;
    }
    if (self.request) return;
    // 检查是否满足内购要求
    if (request.productIdentifier.length <= 0) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeRequestError]);
        }
        return;
    }
    if (self.canPayment == NO) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCannotPayment]);
        }
        return;
    }
    // 开启检测
    [self becomeTransactionObserver];
    // 保存请求并开始
    self.request = request;
    if (request.startHandler) request.startHandler(request);
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
        [self productsRequestDidFail:request];
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
    [self productsRequestDidFail:(SKProductsRequest *)request];
}

- (void)productsRequestDidFail:(SKProductsRequest *)reqs {
    if ([reqs.productIdentifier isEqualToString:self.request.productIdentifier]) {
        if (self.request.requestCount >= self.request.requestMaxCount) {
            [self finishPurchaseWithReceipt:nil code:MNPurchaseResponseCodeRequestError];
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
                    if ([self.request.productIdentifier isEqualToString:transaction.payment.productIdentifier] && self.request.isRestore == NO) {
                        // 不允许重复购买, 正常情况不会触发
                        [self finishTransaction:transaction];
                    } else {
                        // 恢复购买完成
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
    if (self.request.isRestore == NO) return;
    NSArray<SKPaymentTransaction *> *transactions = [queue.transactions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.transactionState == %@", @(SKPaymentTransactionStateRestored)]];
    // 记录恢复购买的个数并重置结果
    self.currentRestoreIndex = 0;
    self.totalRestoreCount = transactions.count;
    self.restoreCode = MNPurchaseResponseCodeFailed;
    if (transactions.count <= 0) {
        [self finishPurchaseWithReceipt:nil code:MNPurchaseResponseCodeRestoreNone];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (self.request.isRestore) {
        [self finishPurchaseWithReceipt:nil code:MNPurchaseResponseCodeRestoreNone];
    }
}

#pragma mark - Payment Transaction
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSString *transactionIdentifier = transaction.originalTransaction.transactionIdentifier ? : transaction.transactionIdentifier;
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    SKPaymentTransactionState transactionState = transaction.transactionState;
    // 无论验证是否通过都结束此次内购操作,否则会出现虚假凭证信息一直验证不通过,每次进入程序都得输入苹果账号;
    // 收据已保存,下次开启支付前会检查收据,再次验证
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //NSData *receiptData = transaction.transactionReceipt;
    MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptWithData:receiptData];
    if (!receipt) {
        // 凭据错误, 结束此次购买
        if ([self.request.productIdentifier isEqualToString:productIdentifier]) {
            [self finishPurchaseWithReceipt:nil code:MNPurchaseResponseCodeReceiptError];
        }
        return;
    }
    receipt.productIdentifier = productIdentifier;
    receipt.transactionIdentifier = transactionIdentifier;
    if (productIdentifier && self.request && [productIdentifier isEqualToString:self.request.productIdentifier]) {
        receipt.userInfo = self.request.userInfo;
    }
    // 订阅或非消耗商品再次购买都会有originalTransaction
    if (self.request && self.request.isSubscribe) receipt.subscribe = YES;
    // 这里不保存恢复购买凭据, 验证失败再次手动恢复即可
    if ((self.request && self.request.isRestore) || transactionState == SKPaymentTransactionStateRestored) {
        // 标记恢复购买凭据,
        receipt.restore = YES;
    } else {
        // 将凭证保存沙盒
        [self saveReceiptToLocal:receipt];
    }
    // 验证收据
    [self submitReceipt:receipt];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    MNPurchaseResponseCode code = MNPurchaseResponseCodeFailed;
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        code = MNPurchaseResponseCodeRestored;
    } else if (transaction.error.code == SKErrorPaymentCancelled) {
        code = MNPurchaseResponseCodeCancelled;
    } else if (transaction.error) {
        code = transaction.error.code;
    }
    // 结束此次内购操作并回调结果
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self finishPurchaseWithReceipt:nil code:code];
}

- (void)finishUncompleteTransactions {
    for (SKPaymentTransaction *transaction in SKPaymentQueue.defaultQueue.transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased ||
            transaction.transactionState == SKPaymentTransactionStateRestored) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

#pragma mark - 验证收据
- (void)submitLocalReceipts {
    NSArray <MNPurchaseReceipt *>*receipts = MNPurchaseReceipt.localReceipts;
    if (receipts.count <= 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(purchaseManagerStartSubmitLocalReceipts:)]) {
            [self.delegate purchaseManagerStartSubmitLocalReceipts:receipts.copy];
        }
        [NSNotificationCenter.defaultCenter postNotificationName:MNPurchaseSubmitLocalNotificationName object:receipts.copy];
    });
    [receipts enumerateObjectsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self submitReceipt:obj];
    }];
}

- (void)submitReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return;
    if (self.isUseItunesSubmitReceipt) {
        // 默认先验证正式环境, 返回环境错误再验证沙箱环境
        [self submitReceiptToItunes:receipt sandbox:NO];
    } else {
        // 向服务端验证支付凭证
        [self submitReceiptToServer:receipt];
    }
}

- (void)submitReceiptToItunes:(MNPurchaseReceipt *)receipt sandbox:(BOOL)isSandbox {
    receipt.submitCount ++;
    NSString *url = isSandbox ? MNReceiptVerifySandbox : MNReceiptVerifyItunes;
    NSString *body = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"",receipt.content];
    body = receipt.isSubscribe ? [NSString stringWithFormat:@"%@,\"password\":\"%@\"}", body, self.secretKey] : [NSString stringWithFormat:@"%@}",body];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakself = self;
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.length <= 0 || error) {
            [weakself finishReceipt:receipt withCode:MNPurchaseResponseCodeVerifyError];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!json || error) {
            [weakself finishReceipt:receipt withCode:MNPurchaseResponseCodeVerifyError];
            return;
        }
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == MNPurchaseResponseCodeServerError || status == MNPurchaseResponseCodeSandboxError) {
            [weakself submitReceiptToItunes:receipt sandbox:!isSandbox];
        } else if (status == 0) {
            [weakself finishReceipt:receipt withCode:MNPurchaseResponseCodeSucceed];
        } else {
            [weakself finishReceipt:receipt withCode:status];
        }
    }];
    [dataTask resume];
}

- (void)submitReceiptToServer:(MNPurchaseReceipt *)receipt {
    // 向服务器验证凭证<地址, 参数自定>
    receipt.submitCount ++;
    __weak typeof(self) weakself = self;
    void(^checkResultHandler)(MNPurchaseResponseCode) = ^(MNPurchaseResponseCode code){
        if (code == MNPurchaseResponseCodeSucceed) {
            [weakself finishReceipt:receipt withCode:MNPurchaseResponseCodeSucceed];
        } else {
            [weakself finishReceipt:receipt withCode:code];
        }
    };
    if ([self.delegate respondsToSelector:@selector(purchaseManagerNeedSubmitReceipt:resultHandler:)]) {
        [self.delegate purchaseManagerNeedSubmitReceipt:receipt.copy resultHandler:[checkResultHandler copy]];
    }
}

- (void)finishReceipt:(MNPurchaseReceipt *)receipt withCode:(MNPurchaseResponseCode)code {
    if (code == MNPurchaseResponseCodeSucceed) {
        // 校验成功
        [self removeLocalReceipt:receipt];
        [self finishPurchaseWithReceipt:receipt code:MNPurchaseResponseCodeSucceed];
    } else if (receipt.submitCount >= self.receiptMaxSubmitCount) {
        // 校验失败, 判断是否删除凭据, 恢复购买不参与本地缓存, 重新恢复购买即可
        if (receipt.isRestore == NO) {
            receipt.failCount ++;
            if (receipt.failCount >= self.receiptMaxFailCount) {
                // 已超过最大验证尝试次数, 删除本地凭据, 提示失败
                [self removeLocalReceipt:receipt];
                if ([self.request.productIdentifier isEqualToString:receipt.productIdentifier]) {
                    [self showAlertWithMessage:@"购买凭据验证失败\n如有疑问请联系客服"];
                }
            } else {
                // 判断不是本地验证结果, 提示验证失败
                [self updateLocalReceipts];
                if (receipt.failCount == 1 && [self.request.productIdentifier isEqualToString:receipt.productIdentifier]) {
                    [self showAlertWithMessage:[NSString stringWithFormat:@"%@凭据验证失败\n下次打开应用将重新验证", receipt.isSubscribe ? @"订阅" : @"购买"]];
                }
            }
        }
        [self finishPurchaseWithReceipt:receipt code:code];
    } else {
        // 检查次数再次尝试校验
        [self submitReceipt:receipt];
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    if (self.isAllowsAlertIfNeeded == NO) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    });
}

#pragma mark - Finish Purchase
- (void)finishPurchaseWithReceipt:(MNPurchaseReceipt *)receipt code:(MNPurchaseResponseCode)responseCode {
    // 加锁保证通道
    Lock();
    if (receipt && receipt.failCount > 0) {
        // 本地凭据
        dispatch_async(dispatch_get_main_queue(), ^{
            MNPurchaseResponse *response = [MNPurchaseResponse responseWithCode:responseCode];
            response.receipt = receipt;
            if ([self.delegate respondsToSelector:@selector(purchaseManagerDidFinishSubmitReceipt:response:)]) {
                [self.delegate purchaseManagerDidFinishSubmitReceipt:receipt response:response];
            }
            [NSNotificationCenter.defaultCenter postNotificationName:MNPurchaseFinishNotificationName object:response];
        });
    } else {
        MNPurchaseRequest *request = self.request;
        if (request && ( !receipt || request.isRestore || [request.productIdentifier isEqualToString:receipt.productIdentifier])) {
            // 为了避免恢复购买多次验证触发方法
            if (receipt && request.isRestore && (self.currentRestoreIndex < self.restoreCode - 1)) {
                self.currentRestoreIndex ++;
                if (responseCode == MNPurchaseResponseCodeSucceed) self.restoreCode = responseCode;
            } else {
                if (receipt && request.isRestore && responseCode != MNPurchaseResponseCodeSucceed) {
                    responseCode = self.restoreCode;
                }
                self.totalRestoreCount = 0;
                self.currentRestoreIndex = 0;
                self.restoreCode = MNPurchaseResponseCodeFailed;
                self.request = nil;
                MNPurchaseResponse *response = [MNPurchaseResponse responseWithCode:responseCode];
                response.request = request;
                response.receipt = receipt;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (request.completionHandler) request.completionHandler(response);
                    if ([self.delegate respondsToSelector:@selector(purchaseManagerDidFinishSubmitReceipt:response:)]) {
                        [self.delegate purchaseManagerDidFinishSubmitReceipt:receipt response:response];
                    }
                    [NSNotificationCenter.defaultCenter postNotificationName:MNPurchaseFinishNotificationName object:response];
                });
            }
        }
    }
    Unlock();
}

#pragma mark - Local Receipts
- (void)saveReceiptToLocal:(MNPurchaseReceipt *)receipt {
    Lock();
    [receipt saveReceiptToLocal];
    Unlock();
}

- (void)removeLocalReceipt:(MNPurchaseReceipt *)receipt {
    Lock();
    [receipt removeFromLocal];
    Unlock();
}

- (void)updateLocalReceipts {
    Lock();
    [MNPurchaseReceipt updateLocalReceipts];
    Unlock();
}

- (BOOL)removeAllLocalReceipts {
    Lock();
    BOOL success = [MNPurchaseReceipt removeLocalReceipts];
    Unlock();
    return success;
}

- (BOOL)updateLocalReceiptCompulsory:(NSArray <MNPurchaseReceipt *>*)receipts {
    Lock();
    BOOL success = [MNPurchaseReceipt updateLocalReceiptCompulsory:receipts];
    Unlock();
    return success;
}

#pragma mark - Getter
- (BOOL)canPayment {
#ifdef TARGET_IPHONE_SIMULATOR
    if (TARGET_IPHONE_SIMULATOR) return NO;
#endif
#ifndef MN_IS_BREAK_DEVICE
    if (MN_IS_BREAK_DEVICE) return NO;
#endif
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Setter
- (void)setReceiptMaxSubmitCount:(int)receiptMaxSubmitCount {
    receiptMaxSubmitCount = MAX(1, receiptMaxSubmitCount);
    _receiptMaxSubmitCount = receiptMaxSubmitCount;
}

#pragma mark - dealloc
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
