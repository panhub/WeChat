//
//  MNNotification.h
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//  通知

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *MNNotificationName NS_EXTENSIBLE_STRING_ENUM;

@interface MNNotification : NSObject

@property (nonatomic, readonly, copy) MNNotificationName name;

@property (nonatomic, strong, readonly, nullable) id object;

@property (nonatomic, copy, readonly, nullable) NSDictionary *userInfo;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(MNNotificationName)name;

- (instancetype)initWithName:(MNNotificationName)name object:(nullable id)object;

- (instancetype)initWithName:(MNNotificationName)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
