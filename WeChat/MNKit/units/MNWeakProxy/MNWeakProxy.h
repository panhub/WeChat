//
//  MNWeakProxy.h
//  MNKit
//
//  Created by Vincent on 2019/9/17.
//  Copyright © 2019 Vincent. All rights reserved.
//  弱代理

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNWeakProxy : NSObject

@property (nullable, nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
