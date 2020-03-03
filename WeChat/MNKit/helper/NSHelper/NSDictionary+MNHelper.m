//
//  NSDictionary+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSDictionary+MNHelper.h"

@implementation NSDictionary (MNHelper)

#pragma mark - 转换为字符串
- (NSString *)urlString {
    return [self componentsJoinedByString:@"&"];
}

- (NSString *)componentString {
    return [self componentsJoinedByString:@"="];
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    if (self.count <= 0) return @"";
    if (separator.length <= 0) separator = @",";
    NSMutableArray <NSString *>*components = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if (([key isKindOfClass:NSString.class] || [key isKindOfClass:NSNumber.class]) && ([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
            [components addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }];
    if (components.count <= 0) return @"";
    return [components componentsJoinedByString:separator];
}

@end
