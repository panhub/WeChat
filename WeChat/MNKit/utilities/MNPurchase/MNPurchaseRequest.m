//
//  MNPurchaseRequest.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseRequest.h"
#import "MNPurchaseManager.h"

@interface MNPurchaseRequest ()

@property (nonatomic, copy) MNPurchaseReceiptHandler receiptHandler;

@property (nonatomic, copy) MNPurchaseRequestHandler requestHandler;

@end

@implementation MNPurchaseRequest
- (instancetype)initWithProductIdentifier:(NSString *)identifier {
    if (identifier.length <= 0) return nil;
    if (self = [super init]) {
        self.requestOutCount = 1;
        [self setValue:identifier forKey:@"productIdentifier"];
    }
    return self;
}

- (void)startRequestPaymentWithReceiptHandler:(MNPurchaseReceiptHandler)receiptHandler completionHandler:(MNPurchaseRequestHandler)completionHandler {
    self.receiptHandler = receiptHandler;
    self.requestHandler = completionHandler;
    [[MNPurchaseManager defaultManager] startRequest:self];
}

- (void)finishRequestWithResponseCode:(MNPurchaseResponseCode)responseCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.requestHandler) {
            self.requestHandler([MNPurchaseResponse responseWithCode:responseCode]);
        }
    });
}

- (void)completeRequest {
    BOOL succeed = NO;
    if (self.receiptHandler) {
        
    }
}

@end
