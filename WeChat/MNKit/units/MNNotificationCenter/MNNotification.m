//
//  MNNotification.m
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//

#import "MNNotification.h"

@interface MNNotification ()
@property (nonatomic, copy) MNNotificationName name;
@property (nonatomic, strong, nullable) id object;
@property (nonatomic, copy, nullable) NSDictionary *userInfo;
@end

@implementation MNNotification
- (instancetype)initWithName:(MNNotificationName)name {
    return [self initWithName:name object:nil userInfo:nil];
}

- (instancetype)initWithName:(MNNotificationName)name object:(id)object {
    return [self initWithName:name object:object userInfo:nil];
}

- (instancetype)initWithName:(MNNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo {
    if (self = [super init]) {
        self.name = name;
        self.object = object;
        self.userInfo = userInfo;
    }
    return self;
}

@end
