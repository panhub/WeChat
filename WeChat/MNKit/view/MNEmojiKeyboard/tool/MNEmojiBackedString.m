//
//  MNEmojiBackedString.m
//  MNKit
//
//  Created by Vincent on 2019/2/7.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiBackedString.h"

NSAttributedStringKey MNEmojiBackedAttributeName = @"com.mn.emoji.backed.attribute.name";

@implementation MNEmojiBackedString

+ (instancetype)backedWithString:(NSString *)string {
    return [[MNEmojiBackedString alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        self.string = string;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _string = [aDecoder decodeObjectForKey:@"string"];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    MNEmojiBackedString *backedString = [MNEmojiBackedString allocWithZone:zone];
    backedString.string = self.string;
    return backedString;
}

@end
