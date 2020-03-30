//
//  MNPurchaseManager.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseManager.h"
#import "MNPurchaseRequest.h"
#import "MNPurchaseReceipt.h"
#import "MNURLDataRequest.h"
#import <StoreKit/StoreKit.h>

#define kMNPurchaseReceiptIdentifier  @"com.mn.purchase.receipt.identifier"
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

@interface MNPurchaseRequest (MNHelper)
@property (nonatomic) NSInteger requestCount;
@property (nonatomic, getter=isSubscribe) BOOL subscribe;
@end

@implementation MNPurchaseRequest (MNHelper)
- (void)setRequestCount:(NSInteger)requestCount {
    objc_setAssociatedObject(self, "com.mn.product.request.count", @(requestCount), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)requestCount {
    NSNumber *n = objc_getAssociatedObject(self, "com.mn.product.request.count");
    if (n) return n.integerValue;
    return 0;
}

- (void)setSubscribe:(BOOL)subscribe {
    objc_setAssociatedObject(self, "com.mn.product.purchase.subscribe", @(subscribe), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isSubscribe {
    NSNumber *n = objc_getAssociatedObject(self, "com.mn.product.purchase.subscribe");
    if (n) return n.boolValue;
    return NO;
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
        if (_manager) {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:_manager];
        }
    });
    return _manager;
}

- (void)startPurchaseProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler {
    MNPurchaseRequest *request = [[MNPurchaseRequest alloc] initWithProductIdentifier:productId];
    request.completionHandler = completionHandler;
    [self startRequest:request];
}

- (void)startRequest:(MNPurchaseRequest *)request {
    /// 检查是否可请求
    if (request.productIdentifier.length <= 0 || self.request) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeRepeated]);
        }
        return;
    }
    /// 检查是否支持内购
    if (self.canPayment == NO) {
        if (request.completionHandler) {
            request.completionHandler([MNPurchaseResponse responseWithCode:MNPurchaseResponseCodeCannotPayment]);
        }
        return;
    }
    /// 保存请求
    self.request = request;
    /// 开始请求
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

- (void)requestDidFinish:(SKRequest *)request {
    if (![request isKindOfClass:SKProductsRequest.class]) return;
    NSLog(@"产品请求结束===%@", ((SKProductsRequest *)request).productIdentifier);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (![request isKindOfClass:SKProductsRequest.class]) return;
    [self productsRequest:(SKProductsRequest *)request didFailWithError:error];
}

- (void)productsRequest:(SKProductsRequest *)reqs didFailWithError:(NSError *)error {
    if ([reqs.productIdentifier isEqualToString:self.request.productIdentifier]) {
        if (self.request.requestCount >= self.request.requestOutCount) {
            [self finishPurchaseWithCode:MNPurchaseResponseCodeProductError];
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
                case SKPaymentTransactionStatePurchasing:
                {
                    // 添加到支付行列
                } break;
                case SKPaymentTransactionStatePurchased:
                {
                    if (transaction.originalTransaction) {
                        // 订阅
                    }
                    [self completeTransaction:transaction];
                } break;
                case SKPaymentTransactionStateRestored:
                case SKPaymentTransactionStateFailed:
                {
                    [self finishTransaction:transaction];
                } break;
                default:
                {
                    
                } break;
            }
        }
    });
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
    if (self.request && [productIdentifier isEqualToString:self.request.productIdentifier]) {
        receipt.subscribe = self.request.isSubscribe;
    } else {
        // 是上次验证失败的订单
        receipt.subscribe = MNPurchaseReceipt.localReceipt.isSubscribe;
        if (receipt.identifier <= 0) {
            receipt.identifier = MNPurchaseReceipt.localReceipt.identifier;
            if (receipt.identifier <= 0) receipt.identifier = @"com.mn.purchase.receipt.identifier";
        }
    }
    // 将凭证保存沙盒
    [receipt saveReceiptToLocal];
    // 验证凭证
    [self verifyPurchaseWithReceipt:receipt];
}

- (void)verifyPurchaseWithReceipt:(MNPurchaseReceipt *)receipt {
#if DEBUG
    NSString *body = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"",receipt.receipt];
    body = receipt.isSubscribe ? [NSString stringWithFormat:@"%@,\"password\":\"%@\"}", body, self.sharedKey] : [NSString stringWithFormat:@"%@}",body];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MNReceiptVerifySandbox] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.f];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 官方验证结果为空
        if (data == nil)
        {
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dict != nil) {
            //~验证成功
            if ([dict[@"status"] intValue] == 0) {
             
            }
            else {
                
            }
            
        }
        else {
        
        }
    }];
    [dataTask resume];
#else
    // 向服务器验证凭证<地址, 参数自定>
    MNURLDataRequest *request = MNURLDataRequest.new;
    request.method = MNURLHTTPMethodPost;
    [request loadData:^{
        
    } completion:^(MNURLResponse *response) {
        if (response.code == MNURLResponseCodeSucceed) {
            
        } else if (response.code == 106 || response.code == 107) {
            // 交易失败, 不结束transaction, 下次打开后再次验证
            [self finishTransaction:nil];
        }
    }];
#endif
}

#pragma mark - Updated Transaction
- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    // transaction.originalTransaction
    MNPurchaseResponseCode code = MNPurchaseResponseCodeFailed;
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        code = MNPurchaseResponseCodeRestored;
    } else {
        
    }
    //NSString *productIdentifier = transaction.payment.productIdentifier;
    
}

#pragma mark - Private
- (void)finishPurchaseWithCode:(MNPurchaseResponseCode)responseCode {
    MNPurchaseManager *manager = MNPurchaseManager.defaultManager;
    if (!manager.request || !manager.request.completionHandler) return;
    MNPurchaseResponse *response = [MNPurchaseResponse responseWithCode:responseCode];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (manager.request.completionHandler) {
            manager.request.completionHandler(response);
        }
        manager.request = nil;
    });
}

#pragma mark - Getter
- (BOOL)canPayment {
    if (self.request || MNPurchaseReceipt.localReceipt.receipt.length || UIDevice.isBreakDevice) return NO;
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - dealloc
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
