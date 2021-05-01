//
//  MNContextConfig.m
//  MNKit
//
//  Created by Vincent on 2019/8/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNContextConfig.h"

@implementation MNContextConfig
- (instancetype)init {
    if (self = [super init]) {
        self.lengths = nil;
        self.phase= 0;
        self.count = 0;
        self.lineWidth = 1.f;
        self.lineCap = kCGLineCapButt;
        self.lineJoin = kCGLineJoinRound;
        self.fillColor = [UIColor whiteColor];
        self.strokeColor = [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f];
    }
    return self;
}

@end
