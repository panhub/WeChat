//
//  MNPurchaseRequest.m
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseRequest.h"
#import "MNPurchaseManager.h"

@interface MNPurchaseRequest ()
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *productIdentifier;
@property (nonatomic, getter=isRestore) BOOL restore;
@property (nonatomic, getter=isCheckout) BOOL checkout;
@property (nonatomic, copy) void(^statusHandler)(MNPurchaseRequest *);
@property (nonatomic, copy) void(^completionHandler)(MNPurchaseResponse *);
@end

@implementation MNPurchaseRequest
- (instancetype)init {
    if (self = [super init]) {
        _requestCount = 0;
        _status = MNPurchaseStatusNormal;
        NSMutableString *identifier = @"com.mn.purchase".mutableCopy;
        [identifier appendString:@"."];
        [identifier appendString:[[NSNumber numberWithLongLong:(long long)(NSDate.date.timeIntervalSince1970*1000)] stringValue]];
        [identifier appendString:@"."];
        [identifier appendFormat:@"%@", @(__COUNTER__).stringValue];
        _identifier = identifier.copy;
    }
    return self;
}

- (instancetype)initWithProductIdentifier:(NSString *)productIdentifier {
    if (self = [self init]) {
        self.productIdentifier = productIdentifier;
    }
    return self;
}

- (void)makeRestoreUsable {
    self.restore = YES;
    self.checkout = NO;
    self.productIdentifier = nil;
}

- (void)makeCheckoutUsable {
    self.restore = NO;
    self.checkout = YES;
    self.productIdentifier = nil;
}

- (void)signal {
    if (self.statusHandler) self.statusHandler(self);
}

- (BOOL)isEqualToRequest:(MNPurchaseRequest *)request {
    return [self.identifier isEqualToString:request.identifier];
}

- (void)didFinishWithResponse:(MNPurchaseResponse *)response {
    _status = MNPurchaseStatusCompleted;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completionHandler) self.completionHandler(response);
    });
}

#pragma mark - Setter
- (void)setStatus:(MNPurchaseStatus)status {
    if (_status == status) return;
    _status = status;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self signal];
    });
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"⚠️⚠️⚠️⚠️ %@ undefined key:%@ ⚠️⚠️⚠️⚠️", NSStringFromClass(self.class), key);
}

#pragma mark - Getter
- (NSString *)message {
    return @[@"即将开始购买项目", (self.isRestore ? @"正在查询可恢复项目" : (self.isCheckout ? @"正在查询本地订单" : @"项目获取中")), @"正在支付", (self.isRestore ? @"恢复购买中" : (self.isCheckout ? @"正在校验本地订单" : @"正在校验订单")), @"应用内购买结束"][self.status];
}

- (BOOL)isValid {
    if (self.productIdentifier.length) return (!self.isRestore && !self.isCheckout);
    return ((self.isRestore && !self.isCheckout) || (!self.isRestore && self.isCheckout));
}

- (BOOL)isLoading {
    return (self.status != MNPurchaseStatusNormal && self.status != MNPurchaseStatusCompleted);
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"===dealloc===%@", NSStringFromClass(self.class));
}

@end

