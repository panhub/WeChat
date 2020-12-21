//
//  NSDictionary+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSDictionary+MNHelper.h"

@implementation NSDictionary (MNHelper)

- (NSString *)queryValue {
    return [self componentsBy:@"=" joined:@"&"];
}

- (NSString *)componentString {
    return [self componentsBy:@"=" joined:@","];
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    return [self componentsBy:@"=" joined:separator];
}

- (NSString *)componentsBy:(NSString *)byString joined:(NSString *)joined {
    if (self.count <= 0 || byString.length <= 0 || joined.length <= 0) return nil;
    NSMutableArray <NSString *>*components = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if (([key isKindOfClass:NSString.class] || [key isKindOfClass:NSNumber.class]) && ([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
            [components addObject:[@[key, value] componentsJoinedByString:byString]];
        }
    }];
    if (components.count <= 0) return nil;
    return [components componentsJoinedByString:joined];
}

@end
