//
//  WXBankCard.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCard.h"

@implementation WXBankCard
@synthesize icon = _icon;
@synthesize desc = _desc;

- (instancetype)init {
    if (self = [super init]) {
        self.number = [NSDate shortTimestamps];
    }
    return self;
}

- (UIImage *)icon {
    if (!_icon && _img.length > 0) {
        _icon = [UIImage imageNamed:_img];
    }
    return _icon;
}

- (NSString *)desc {
    return _type == WXBankCardTypeDeposit ? @"储蓄卡" : @"信用卡";
}

- (BOOL)isValid {
    return _number.length > 0 && _img.length > 0 && _name.length > 0;
}

@end
