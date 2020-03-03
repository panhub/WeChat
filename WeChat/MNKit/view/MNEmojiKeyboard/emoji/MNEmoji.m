//
//  MNEmoji.m
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmoji.h"

@implementation MNEmoji
#pragma mark - 字典样式
- (id)JsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:(self.img.length ? self.img : @"") forKey:@"img"];
    [dic setObject:(self.desc.length ? self.desc : @"") forKey:@"desc"];
    [dic setObject:(self.packet.length ? self.packet : @"") forKey:@"packet"];
    [dic setObject:(self.extension.length ? self.extension : @"") forKey:@"extension"];
    [dic setObject:@(self.type) forKey:@"type"];
    return dic.copy;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:self.packet forKey:@"packet"];
    [aCoder encodeObject:self.img forKey:@"img"];
    [aCoder encodeObject:self.extension forKey:@"extension"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            self.image = [aDecoder decodeObjectForKey:@"image"];
            self.desc = [aDecoder decodeObjectForKey:@"desc"];
            self.img = [aDecoder decodeObjectForKey:@"img"];
            self.packet = [aDecoder decodeObjectForKey:@"packet"];
            self.extension = [aDecoder decodeObjectForKey:@"extension"];
            self.type = [aDecoder decodeIntegerForKey:@"type"];
        }
    }
    return self;
}

@end
