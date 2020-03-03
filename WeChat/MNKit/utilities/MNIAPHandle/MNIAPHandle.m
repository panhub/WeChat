//
//  MNIAPHandle.m
//  MNKit
//
//  Created by Vincent on 2019/3/1.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNIAPHandle.h"
#import <StoreKit/StoreKit.h>

/// 商品id
NSString * const MNIAPProductIdKey = @"com.mn.iap.product.id.key";
/// 交易凭证数据, key不可变
NSString * const MNIAPReceiptDataKey = @"receipt-data";

@interface MNIAPResult ()
@property (nonatomic, strong) NSDictionary *receipt;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) MNIAPFinishCallback completion;
@property (nonatomic, copy) MNIAPRequestCallback handler;
@end

@implementation MNIAPResult

- (id)copyWithZone:(NSZone *)zone {
    MNIAPResult *result = [MNIAPResult allocWithZone:zone];
    result.receipt = self.receipt;
    result.productId = self.productId;
    return result;
}

@end

@interface MNIAPHandle () <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, strong) NSMutableArray <MNIAPResult *>*resultCache;
@property (nonatomic, strong) NSMutableArray <MNIAPResult *>*requestCache;
@end

static MNIAPHandle *_iapHandle;
#define MNIAPSandboxUrl @"https://sandbox.itunes.apple.com/verifyReceipt"
#define MNIAPAppStoreUrl @"https://buy.itunes.apple.com/verifyReceipt"

@implementation MNIAPHandle

+ (instancetype)defaultHandle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_iapHandle) {
            _iapHandle = [[MNIAPHandle alloc] init];
        }
    });
    return _iapHandle;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iapHandle = [super allocWithZone:zone];
    });
    return _iapHandle;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iapHandle = [super init];
        if (_iapHandle) {
            _iapHandle.resultCache = [NSMutableArray arrayWithCapacity:1];
            _iapHandle.resultCache = [NSMutableArray arrayWithCapacity:1];
            [[NSNotificationCenter defaultCenter] addObserver:_iapHandle
                                                     selector:@selector(didEnterBackgroundNotification:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_iapHandle
                                                     selector:@selector(willEnterForegroundNotification:)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:_iapHandle];
        }
    });
    return _iapHandle;
}

#pragma mark - 请求商品信息部分
#pragma mark - public
+ (void)handRequestProduct:(NSString *)productId handler:(MNIAPRequestCallback)handler completion:(MNIAPFinishCallback)completion {
    /// 判断是否在请求中
    if ([[MNIAPHandle defaultHandle] isLoading]) return;
    /// 检查数据是否完整
    if (productId.length <= 0) {
        if (completion) {
            completion([self payErrorWithCode:MNIAPStatusCodeDataError]);
        }
        return;
    }
    /// 检查权限
    if (![SKPaymentQueue canMakePayments]) {
        if (completion) {
            completion([self payErrorWithCode:MNIAPStatusCodeCannotPayment]);
        }
        return;
    }
    MNIAPResult *result = [MNIAPResult new];
    result.productId = productId;
    result.handler = handler;
    result.completion = completion;
    [[MNIAPHandle defaultHandle].resultCache addObject:result];
    [[MNIAPHandle defaultHandle] requestProduct:productId];
}

#pragma mark - private
- (void)requestProduct:(NSString *)productId {
    /// 请求商品信息
    self.loading = YES;
    self.productId = productId;
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:productId, nil]];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    /// 查询到的商品信息数组
    NSArray <SKProduct *>*products = response.products;
    if (products.count <= 0) return;
    /// 获取商品
    SKProduct *product = products.firstObject;
    /// 添加到内购支付列表
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    /// 请求失败
    NSLog(@"内购请求错误");
    self.loading = NO;
    MNIAPResult *result = [self resultForProductId:self.productId];
    if (!result) return;
    if (result.completion) {
        result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeNetworkError]);
    }
    [self removeResult:result];
    self.productId = nil;
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"内购请求结束");
    self.loading = NO;
    self.productId = nil;
}

#pragma mark - 支付部分
#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull transaction, NSUInteger idx, BOOL * _Nonnull stop) {
        [self updateTransaction:transaction];
    }];
}

/// 处理支付事务
- (void)updateTransaction:(SKPaymentTransaction *)transaction {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"交易成功");
                [self completeTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            } break;
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"商品添加进列表");
            } break;
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"已购买过商品");
                [self restoredTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            } break;
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"交易失败");
                [self failedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            } break;
            default:
                break;
        }
    });
}

/// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    MNIAPResult *result = [self resultForProductId:transaction.payment.productIdentifier];
    if (!result) return;
    if (transaction.error.code == SKErrorPaymentCancelled) {
        if (result.completion) {
            result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeCancelled]);
        }
    } else {
        if (result.completion) {
            result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeFailed]);
        }
    }
    /// 删除缓存
    [self removeResult:result];
}

/// 已购买
- (void)restoredTransaction:(SKPaymentTransaction *)transaction {
    MNIAPResult *result = [self resultForProductId:transaction.payment.productIdentifier];
    if (!result) return;
    if (result.completion) {
        result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeRestored]);
    }
    /// 删除缓存
    [self removeResult:result];
}

/// 交易成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    MNIAPResult *result = [self resultForProductId:transaction.payment.productIdentifier];
    if (!result) return;
    /// 官方推荐获取凭证方法
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (receiptString.length <= 0) {
        if (result.completion) {
            result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeReceiptError]);
        }
        [self removeResult:result];
        return;
    }
    /// 验证交易凭证信息
    result.receipt = @{MNIAPReceiptDataKey:receiptString};
    /// 询问是否外界验证
    BOOL verify = YES;
    if (result.handler) {
        verify = result.handler([result copy]);
    }
    if (!verify) {
        [self removeResult:result];
        return;
    }
    /// 自行验证交易凭证
    [self verifyReceipt:result];
}

/// 验证交易凭证
- (void)verifyReceipt:(MNIAPResult *)result {
    NSData *data = [NSJSONSerialization dataWithJSONObject:result.receipt
                                                          options:kNilOptions
                                                            error:nil];
    if (data.length <= 0) {
        if (result.completion) {
            result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeReceiptError]);
        }
        [self removeResult:result];
        return;
    }
    self.loading = YES;
#if DEBUG
    NSString *url = MNIAPSandboxUrl;
#else
    NSString *url = MNIAPAppStoreUrl;
#endif
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 10.f;
    request.HTTPBody = data;
    request.HTTPMethod = @"POST";
    request.allowsCellularAccess = YES;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.loading = NO;
        if (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"验证交易凭证发生错误!"
                                                               delegate:self
                                                      cancelButtonTitle:@"关闭"
                                                      otherButtonTitles:@"重试", nil];
            alertView.user_info = result.productId;
            [alertView show];
        } else if (data.length <= 0) {
            if (result.completion) {
                result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeFailed]);
            }
            [self removeResult:result];
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (!json) {
                if (result.completion) {
                    result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeJSONError]);
                }
                [self removeResult:result];
            } else {
                /// 验证信息
                NSLog(@"%@", json);
                NSString *status = [MNJSONSerialization stringValueWithJSON:json forKey:@"status" def:@"21010"];
                if ([status integerValue] == 0) {
                    if (result.completion) {
                        result.completion(nil);
                    }
                } else {
                    if (result.completion) {
                        result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeFailed]);
                    }
                }
                [self removeResult:result];
            }
        }
    }];
    [dataTask resume];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    MNIAPResult *result = [self resultForProductId:alertView.user_info];
    if (!result) return;
    if (buttonIndex != alertView.cancelButtonIndex) {
        /// 重试
        [self verifyReceipt:result];
    } else {
        /// 取消
        if (result.completion) {
            result.completion([MNIAPHandle payErrorWithCode:MNIAPStatusCodeFailed]);
        }
        [self removeResult:result];
    }
}

#pragma mark - 获取错误信息
+ (NSError *)payErrorWithCode:(MNIAPStatusCode)code {
    if (code == MNIAPStatusCodeSucceed) return nil;
    NSString *desc = @"发生未知错误";
    switch (code) {
        case MNIAPStatusCodeCannotPayment:
        {
            desc = @"获取支付权限失败";
        } break;
        case MNIAPStatusCodeFailed:
        {
            desc = @"交易失败";
        } break;
        case MNIAPStatusCodeCancelled:
        {
            desc = @"已取消交易";
        } break;
        case MNIAPStatusCodeDataError:
        {
            desc = @"数据错误";
        } break;
        case MNIAPStatusCodeJSONError:
        {
            desc = @"JSON信息错误";
        } break;
        case MNIAPStatusCodeReceiptError:
        {
            desc = @"交易凭证错误";
        } break;
        case MNIAPStatusCodeRestored:
        {
            desc = @"已购买该商品";
        } break;
        case MNIAPStatusCodeNetworkError:
        {
            desc = @"网络错误";
        } break;
        default:
            break;
    }
    return [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
}

#pragma mark -- 检查更新交易事务
+ (void)checkUpdatePaymentIfNeeded {
    NSArray <SKPaymentTransaction *>*transactions = [SKPaymentQueue defaultQueue].transactions;
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[MNIAPHandle defaultHandle] updateTransaction:obj];
    }];
}

- (MNIAPResult *)resultForProductId:(NSString *)productId {
    if (productId.length <= 0) return nil;
    __block MNIAPResult *result;
    @synchronized (self) {
        [self.resultCache enumerateObjectsUsingBlock:^(MNIAPResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.productId isEqualToString:productId]) {
                result = obj;
                *stop = YES;
            }
        }];
    }
    return result;
}

- (void)removeResult:(MNIAPResult *)result {
    if (!result) return;
    @synchronized (self) {
        if ([self.resultCache containsObject:result]) {
            [self.resultCache removeObject:result];
        }
    }
}

- (void)removeResultForProductId:(NSString *)productId {
    [self removeResult:[self resultForProductId:productId]];
}

#pragma mark - NSNotificationCenter
- (void)didEnterBackgroundNotification:(NSNotification *)not {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)willEnterForegroundNotification:(NSNotification *)not {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [MNIAPHandle checkUpdatePaymentIfNeeded];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
