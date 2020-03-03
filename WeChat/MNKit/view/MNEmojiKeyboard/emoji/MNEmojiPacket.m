//
//  MNEmojiPacket.m
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiPacket.h"

@implementation MNEmojiPacket
#pragma mark - 字典样式
- (id)JsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:(self.img.length ? self.img : @"") forKey:@"img"];
    [dic setObject:(self.desc.length ? self.desc : @"") forKey:@"desc"];
    [dic setObject:(self.name.length ? self.name : @"") forKey:@"name"];
    [dic setObject:(self.uuid.length ? self.uuid : @"") forKey:@"uuid"];
    [dic setObject:@(self.type) forKey:@"type"];
    [dic setObject:@(self.state) forKey:@"state"];
    NSMutableArray <NSDictionary *>*emojis = @[].mutableCopy;
    [self.emojis enumerateObjectsUsingBlock:^(MNEmoji * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [emojis addObject:obj.JsonValue];
    }];
    [dic setObject:emojis.copy forKey:@"emotions"];
    return dic.copy;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.img forKey:@"img"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.emojis forKey:@"emojis"];
    [aCoder encodeInteger:self.state forKey:@"state"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            self.name = [aDecoder decodeObjectForKey:@"name"];
            self.desc = [aDecoder decodeObjectForKey:@"desc"];
            self.image = [aDecoder decodeObjectForKey:@"image"];
            self.img = [aDecoder decodeObjectForKey:@"img"];
            self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
            self.state = [aDecoder decodeIntegerForKey:@"state"];
            self.type = [aDecoder decodeIntegerForKey:@"type"];
            [self.emojis addObjectsFromArray:[aDecoder decodeObjectForKey:@"emojis"]];
        }
    }
    return self;
}

#pragma mark - Getter
- (NSMutableArray <MNEmoji *>*)emojis {
    if (!_emojis) {
        _emojis = [NSMutableArray arrayWithCapacity:0];
    }
    return _emojis;
}

@end
