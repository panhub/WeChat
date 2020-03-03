//
//  MNMediaInfo.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaInfo.h"

static NSString *MNMediaContentLengthKey = @"com.media.content.length.key";
static NSString *MNMediaContentTypeKey = @"com.media.content.type.key";
static NSString *MNMediaByteRangeAccessSupported = @"com.media.byte.range.access.supported.key";

@implementation MNMediaInfo

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\ncontentLength: %lld\ncontentType: %@\nbyteRangeAccessSupported:%@", NSStringFromClass([self class]), self.contentLength, self.contentType, @(self.byteRangeAccessSupported)];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.contentLength) forKey:MNMediaContentLengthKey];
    [aCoder encodeObject:self.contentType forKey:MNMediaContentTypeKey];
    [aCoder encodeObject:@(self.byteRangeAccessSupported) forKey:MNMediaByteRangeAccessSupported];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _contentLength = [[aDecoder decodeObjectForKey:MNMediaContentLengthKey] longLongValue];
        _contentType = [aDecoder decodeObjectForKey:MNMediaContentTypeKey];
        _byteRangeAccessSupported = [[aDecoder decodeObjectForKey:MNMediaByteRangeAccessSupported] boolValue];
    }
    return self;
}

@end
