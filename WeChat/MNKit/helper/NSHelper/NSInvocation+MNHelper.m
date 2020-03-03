//
//  NSInvocation+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSInvocation+MNHelper.h"

@implementation NSInvocation (MNHelper)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector objects:(id)obj,...NS_REQUIRES_NIL_TERMINATION
{
    if (!target || !selector) return nil;
    //方法签名
    NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:selector];
    if (!signature) return nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (!invocation) return nil;
    invocation.target = target;
    invocation.selector = selector;
    /**绑定其他参数*/
    if (obj) {
        NSMutableArray <id>*parameters = [NSMutableArray arrayWithCapacity:0];
        [parameters addObject:obj];
        va_list args;
        va_start(args, obj);
        while ((obj = va_arg(args, id))) {
            [parameters addObject:obj];
        }
        va_end(args);
        /*第一个参数：需要给指定方法传递的值, 需要接收一个指针, 也就是传递值的时候需要传递地址*/
        /*第二个参数：需要给指定方法的第几个参数传值*/
        /*注意: 设置参数的索引时不能从0开始, 因为0已经被self占用, 1已经被_cmd占用*/
        NSInteger index = 2;
        [parameters enumerateObjectsUsingBlock:^(id  _Nonnull parameter, NSUInteger idx, BOOL * _Nonnull stop) {
            [invocation setArgument:&parameter atIndex:(index + idx)];
        }];
    }
    return invocation;
}

@end
