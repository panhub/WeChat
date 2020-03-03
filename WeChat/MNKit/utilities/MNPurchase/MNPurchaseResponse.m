//
//  MNPurchaseResponse.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseResponse.h"

@implementation MNPurchaseResponse

- (instancetype)initWithResponseCode:(MNPurchaseResponseCode)code {
    if (self = [super init]) {
        [self setValue:@(code) forKey:@"code"];
        [self setValue:[self responseMessageWithCode:code] forKey:@"message"];
    }
    return self;
}

+ (instancetype)responseWithCode:(MNPurchaseResponseCode)code {
    return [[self alloc] initWithResponseCode:code];
}

- (NSString *)responseMessageWithCode:(MNPurchaseResponseCode)code {
    return @"发生错误";
}

@end
