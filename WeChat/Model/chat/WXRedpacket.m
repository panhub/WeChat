//
//  WXRedpacket.m
//  MNChat
//
//  Created by Vincent on 2019/5/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacket.h"

@implementation WXRedpacket
@synthesize fromUser = _fromUser;
@synthesize toUser = _toUser;
#pragma mark - Instance
- (instancetype)init {
    if (self = [super init]) {
        self.identifier = [NSDate shortTimestamps];
    }
    return self;
}

#pragma mark - Getter
- (WXUser *)fromUser {
    if (!_fromUser && _from_uid.length > 0) {
        _fromUser = [[MNChatHelper helper] userForUid:_from_uid];
    }
    return _fromUser;
}

- (WXUser *)toUser {
    if (!_toUser && _to_uid.length > 0) {
        _toUser = [[MNChatHelper helper] userForUid:_to_uid];
    }
    return _toUser;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.from_uid forKey:@"from_uid"];
    [aCoder encodeObject:self.to_uid forKey:@"to_uid"];
    [aCoder encodeObject:self.money forKey:@"money"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.create_time forKey:@"create_time"];
    [aCoder encodeObject:self.draw_time forKey:@"draw_time"];
    [aCoder encodeBool:self.isOpen forKey:@"open"];
    [aCoder encodeBool:self.isMine forKey:@"mine"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.from_uid = [aDecoder decodeObjectForKey:@"from_uid"];
        self.to_uid = [aDecoder decodeObjectForKey:@"to_uid"];
        self.money = [aDecoder decodeObjectForKey:@"money"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.create_time = [aDecoder decodeObjectForKey:@"create_time"];
        self.draw_time = [aDecoder decodeObjectForKey:@"draw_time"];
        self.open = [aDecoder decodeBoolForKey:@"open"];
        self.mine = [aDecoder decodeBoolForKey:@"mine"];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXRedpacket *redpacket = [WXRedpacket allocWithZone:zone];
    redpacket.identifier = self.identifier;
    redpacket.from_uid = self.from_uid;
    redpacket.to_uid = self.to_uid;
    redpacket.money = self.money;
    redpacket.text = self.text;
    redpacket.create_time = self.create_time;
    redpacket.draw_time = self.draw_time;
    redpacket.type = self.type;
    redpacket.mine = self.isMine;
    redpacket.open = self.isOpen;
    redpacket->_fromUser = self.fromUser;
    redpacket->_toUser = self.toUser;
    return redpacket;
}

@end
