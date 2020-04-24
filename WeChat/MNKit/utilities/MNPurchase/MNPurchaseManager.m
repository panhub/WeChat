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
{
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, strong) MNPurchaseRequest *request;
@property (nonatomic, strong) void (^receiptCheckHandler)(MNPurchaseReceipt *, void(^)(MNPurchaseResponseCode));
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
        _manager.checkTryCount = 3;
        _manager.receiptMaxFailCount = 3;
        _semaphore = dispatch_semaphore_create(1);
        //062dbdb74e1a4407988fbaf00ae6f98c
    });
    return _manager;
}

- (void)becomeTransactionObserver {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self verifyLocalReceipts];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    });
}

- (void)startPurchaseProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler {
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.restore = NO;
    request.subscribe = NO;
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)startSubscribeProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler {
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.restore = NO;
    request.subscribe = YES;
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)startRestorePurchaseWithCompletionHandler:(MNPurchaseRequestHandler)completionHandler {
    // 创建恢复购买请求
    MNPurchaseRequest *request = MNPurchaseRequest.new;
    request.completionHandler = completionHandler;
    request.restore = YES;
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
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)startRequest:(MNPurchaseRequest *)request {
    if (request.isRestore) {
        [self startRestore:request];
        return;
    }
    // 开启检测
    [self becomeTransactionObserver];
    // 检查是否满足内购要求
    if (self.request || request.productIdentifier.length <= 0) return;
    if (self.canPayment == NO) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCannotPayment]);
        }
        return;
    }
    // 保存请求并开始
    self.request = request;
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
        if (self.request.requestCount >= self.request.requestOutCount) {
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
                        // 不允许重复购买
                        [self finishTransaction:transaction];
                    } else {
                        // 恢复购买
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
    //NSData *receiptData = transaction.transactionReceipt;
    MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptWithData:receiptData];
    if (!receipt) {
        // 凭据错误, 结束此次购买
        if ([self.request.productIdentifier isEqualToString:productIdentifier]) {
            [self finishPurchaseWithReceipt:nil code:MNPurchaseResponseCodeReceiptError];
        }
        return;
    }
    NSMutableDictionary *header = @{}.mutableCopy;
    if (productIdentifier) [header setObject:productIdentifier forKey:@"productIdentifier"];
    if (transactionIdentifier) [header setObject:transactionIdentifier forKey:@"transactionIdentifier"];
    [self.receiptHeader enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [header setObject:obj forKey:key];
    }];
    receipt.identifier = productIdentifier;
    receipt.header = [header.copy componentsJoinedByString:@"&"];
    // 订阅或非消耗商品再次购买都会有originalTransaction
    if (self.request.isSubscribe) receipt.subscribe = YES;
    // 这里不保存恢复购买凭据, 验证失败再次手动恢复即可
    if (self.request.isRestore || transaction.transactionState == SKPaymentTransactionStateRestored) {
        // 标记恢复购买凭据,
        receipt.restore = YES;
    } else {
        // 将凭证保存沙盒
        [self saveReceiptToLocal:receipt];
    }
    // 无论验证是否通过都结束此次内购操作,否则会出现虚假凭证信息一直验证不通过,每次进入程序都得输入苹果账号;
    // 收据已保存,下次开启支付前会检查收据,再次验证
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    // 验证收据
    [self verifyReceipt:receipt];
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
- (void)verifyLocalReceipts {
    NSArray <MNPurchaseReceipt *>*receipts = MNPurchaseReceipt.localReceipts;
    if (receipts.count <= 0) return;
    [self showAlertWithMessage:@"~正在验证本地凭据~"];
    [receipts enumerateObjectsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self verifyReceipt:obj];
    }];
}

- (void)verifyReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return;
    #if DEBUG
    if (self.isUseServerCheckReceipt) {
        // 向服务端验证支付凭证
        [self verifyReceiptToServer:receipt];
    } else {
        // 默认先验证正式环境, 返回环境错误再验证沙箱环境
        [self verifyReceiptToItunes:receipt sandbox:NO];
    }
    #else
    // 正式版本, 向服务端验证支付凭证
    [self verifyReceiptToServer:receipt];
    #endif
}

- (void)verifyReceiptToItunes:(MNPurchaseReceipt *)receipt sandbox:(BOOL)isSandbox {
    receipt.tryCount ++;
    NSString *url = isSandbox ? MNReceiptVerifySandbox : MNReceiptVerifyItunes;
    NSString *body = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"",receipt.content];
    body = receipt.isSubscribe ? [NSString stringWithFormat:@"%@,\"password\":\"%@\"}", body, self.secretKey] : [NSString stringWithFormat:@"%@}",body];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakself = self;
    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.length <= 0 || error) {
            [weakself finishVerifyReceipt:receipt withCode:MNPurchaseResponseCodeVerifyError];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!json || error) {
            [weakself finishVerifyReceipt:receipt withCode:MNPurchaseResponseCodeVerifyError];
            return;
        }
        NSInteger status = [[json objectForKey:@"status"] integerValue];
        if (status == MNPurchaseResponseCodeServerError || status == MNPurchaseResponseCodeSandboxError) {
            [weakself verifyReceiptToItunes:receipt sandbox:!isSandbox];
        } else if (status == 0) {
            [weakself completeVerifyReceipt:receipt];
        } else {
            [weakself finishVerifyReceipt:receipt withCode:status];
        }
    }];
    [dataTask resume];
}

- (void)verifyReceiptToServer:(MNPurchaseReceipt *)receipt {
    // 向服务器验证凭证<地址, 参数自定>
    if (self.receiptCheckHandler == nil && self.delegate == nil) return;
    receipt.tryCount ++;
    __weak typeof(self) weakself = self;
    void(^checkResultHandler)(MNPurchaseResponseCode) = ^(MNPurchaseResponseCode code){
        if (code == MNPurchaseResponseCodeSucceed) {
            [weakself completeVerifyReceipt:receipt];
        } else {
            [weakself finishVerifyReceipt:receipt withCode:code];
        }
    };
    if (self.receiptCheckHandler) self.receiptCheckHandler(receipt, [checkResultHandler copy]);
    if ([self.delegate respondsToSelector:@selector(purchaseManagerShouldCheckReceipt:resultHandler:)]) {
        [self.delegate purchaseManagerShouldCheckReceipt:receipt resultHandler:[checkResultHandler copy]];
    }
}

- (void)completeVerifyReceipt:(MNPurchaseReceipt *)receipt {
    [self removeLocalReceipt:receipt];
    if (receipt.failCount > 0) {
        [self showAlertWithMessage:@"~本地凭据验证成功~"];
    } else if (receipt.isRestore) {
        [self showAlertWithMessage:@"恢复购买成功"];
    } else if (receipt.isSubscribe) {
        [self showAlertWithMessage:@"订阅成功"];
    } else {
        [self showAlertWithMessage:@"购买成功"];
    }
    [self finishPurchaseWithReceipt:receipt code:MNPurchaseResponseCodeSucceed];
}

- (void)finishVerifyReceipt:(MNPurchaseReceipt *)receipt withCode:(MNPurchaseResponseCode)code {
    if (receipt.tryCount >= self.checkTryCount) {
        receipt.failCount ++;
        if (receipt.isRestore || receipt.failCount >= self.receiptMaxFailCount) {
            // 恢复购买凭据并未缓存本地, 这里只是为了删除正常凭据
            [self removeLocalReceipt:receipt];
            if (receipt.isRestore) {
                [self showAlertWithMessage:@"恢复购买验证失败\n如有疑问请联系客服"];
            } else if ([self.request.productIdentifier isEqualToString:receipt.identifier]) {
                [self showAlertWithMessage:@"购买凭据验证失败\n如有疑问请联系客服"];
            }
        } else {
            [self updateLocalReceipts];
            // 判断不是本地验证结果, 提示验证失败
            if (receipt.failCount == 1 && [self.request.productIdentifier isEqualToString:receipt.identifier]) {
                [self showAlertWithMessage:[NSString stringWithFormat:@"%@凭据验证失败\n下次打开应用将重新验证", receipt.isSubscribe ? @"订阅" : @"购买"]];
            }
        }
        [self finishPurchaseWithReceipt:receipt code:code];
    } else {
        [self verifyReceipt:receipt];
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    if (self.isAllowsAlertIfNeeded == NO) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    });
}

#pragma mark - Finish Purchase
- (void)finishPurchaseWithReceipt:(MNPurchaseReceipt *)receipt code:(MNPurchaseResponseCode)responseCode {
    // 本地凭据无论成功失败, 拒绝回调
    if (receipt && receipt.failCount > 1) return;
    // 加锁保证多份恢复购买凭据重复回调
    Lock();
    MNPurchaseRequest *request = self.request;
    if (request && ( !receipt || receipt.isRestore || [request.productIdentifier isEqualToString:receipt.identifier])) {
        MNPurchaseManager.defaultManager.request = nil;
        MNPurchaseResponse *response = [MNPurchaseResponse responseWithCode:responseCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request.completionHandler) request.completionHandler(response);
        });
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

#pragma mark - Getter
- (BOOL)canPayment {
    if (UIDevice.isBreakDevice) return NO;
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Setter
- (void)setCheckTryCount:(int)checkTryCount {
    checkTryCount = MAX(1, checkTryCount);
    _checkTryCount = checkTryCount;
}

- (void)setPurchaseReceiptCheckHandler:(void(^)(MNPurchaseReceipt *, void(^)(MNPurchaseResponseCode)))receiptCheckHandler {
    self.receiptCheckHandler = [receiptCheckHandler copy];
}

#pragma mark - dealloc
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
