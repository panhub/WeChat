//
//  NSDictionary+MNSQLStatement.m
//  MNKit
//
//  Created by Vicent on 2020/6/24.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "NSDictionary+MNSQLStatement.h"

@implementation NSDictionary (MNSQLStatement)

- (NSString *)sqliteStatement {
    if (self.count <= 0) return @"";
    NSMutableArray <NSString *>*components = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if (([key isKindOfClass:NSString.class] || [key isKindOfClass:NSNumber.class]) && ([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
            [components addObject:[NSString stringWithFormat:@"%@ = %@", key, value]];
        }
    }];
    if (components.count <= 0) return @"";
    return [components componentsJoinedByString:@" AND "];
}

@end
