//
//  MNPurchaseRequest.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseRequest.h"
#import "MNPurchaseManager.h"
#import <StoreKit/StoreKit.h>

@interface MNPurchaseRequest ()

@end

@implementation MNPurchaseRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestOutCount = 3;
        self.productIdentifier = @"";
    }
    return self;
}

- (instancetype)initWithProductIdentifier:(NSString *)identifier {
    if (identifier.length <= 0) return nil;
    if (self = [self init]) {
        self.productIdentifier = identifier;
    }
    return self;
}

- (void)startRequestWithCompletionHandler:(MNPurchaseRequestHandler)completionHandler {
    [[MNPurchaseManager defaultManager] startRequest:self];
}

#pragma mark - Setter
- (void)setRequestOutCount:(NSInteger)requestOutCount {
    requestOutCount = MAX(1, requestOutCount);
    _requestOutCount = requestOutCount;
}

@end



@implementation MNPurchaseRequest (MNPurchasing)
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

- (void)setRestore:(BOOL)restore {
    objc_setAssociatedObject(self, "com.mn.product.purchase.restore", @(restore), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isRestore {
    NSNumber *n = objc_getAssociatedObject(self, "com.mn.product.purchase.restore");
    if (n) return n.boolValue;
    return NO;
}

@end
