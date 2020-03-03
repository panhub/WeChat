//
//  NSInvocation+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (MNHelper)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector objects:(id)obj,...NS_REQUIRES_NIL_TERMINATION;

@end

