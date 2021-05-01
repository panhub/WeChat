//
//  WXChangeModel.m
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeModel.h"

@implementation WXChangeModel
- (instancetype)init {
    if (self = [super init]) {
        self.numbers = [NSDate shortTimestamps];
        self.channel = WXChangeChannelDefault;
    }
    return self;
}

@end
