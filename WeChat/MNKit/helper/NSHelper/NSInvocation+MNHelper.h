//
//  NSInvocation+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (MNHelper)

+ (NSInvocation *_Nullable)invocationWithTarget:(id)target selector:(SEL)selector objects:(id _Nullable)obj,...NS_REQUIRES_NIL_TERMINATION;

@end
NS_ASSUME_NONNULL_END
