//
//  MNMediaSeekAction.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaSeekAction.h"

@implementation MNMediaSeekAction

- (instancetype)initWithType:(MNMediaSeekActionType)type range:(NSRange)range {
    self = [super init];
    if (self) {
        _type = type;
        _range = range;
    }
    return self;
}

- (BOOL)isEqualToAction:(MNMediaSeekAction *)action {
    return (action && NSEqualRanges(action.range, self.range) && action.type == self.type);
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@%@", NSStringFromRange(self.range), @(self.type)] hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type: %@, range: %@", @(self.type), NSStringFromRange(self.range)];
}

@end
