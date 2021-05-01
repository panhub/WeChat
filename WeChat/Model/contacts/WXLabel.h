//
//  WXLabel.h
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  标签模型

#import <Foundation/Foundation.h>
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXLabel : NSObject<NSCopying>

/**标签名*/
@property (nonatomic, copy) NSString *name;

/**标识*/
@property (nonatomic, copy) NSString *identifier;

/**时间戳*/
@property (nonatomic, copy) NSString *timestamp;

/**用户*/
@property (nonatomic, strong) NSMutableArray <WXUser *>*users;

/**用户拼接*/
@property (nonatomic, strong, readonly) NSString *userString;

@end

NS_ASSUME_NONNULL_END
