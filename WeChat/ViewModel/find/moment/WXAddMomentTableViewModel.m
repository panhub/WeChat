//
//  WXAddMomentTableViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentTableViewModel.h"

@implementation WXAddMomentTableViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.owner = [WXUser shareInfo];
        self.privacy = NO;
        self.location = @"";
        self.timestamp = [NSDate timestamps];
    }
    return self;
}

- (NSString *)dec {
    NSString *dec = self.location;
    if (self.point) {
        dec = [dec stringByAppendingFormat:@"%@%@%@%@",WXDataSeparatedSign, @(self.point.latitude), WXDataSeparatedSign, @(self.point.longitude)];
    }
    return dec;
}

@end
