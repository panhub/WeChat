//
//  NSObject+MNSwizzle.m
//  MNKit
//
//  Created by Vincent on 2018/9/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSObject+MNSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (MNSwizzle)
#pragma mark - Swizzled System Method
+ (BOOL)swizzleInstanceMethod:(SEL)systemSelector withSelector:(SEL)swizzledSelector {
    Method systemMethod = class_getInstanceMethod(self, systemSelector);
    if (!systemMethod) return NO;
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    if (!swizzledMethod) return NO;
    BOOL didAddMethod = class_addMethod(self, systemSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(self, swizzledSelector,
                            method_getImplementation(systemMethod),
                            method_getTypeEncoding(systemMethod));
    } else {
        method_exchangeImplementations(systemMethod, swizzledMethod);
    }
    return YES;
}

BOOL MNSwizzleInstanceMethod(Class cls, SEL systemSelector, SEL swizzledSelector) {
    return [cls swizzleInstanceMethod:systemSelector withSelector:swizzledSelector];
}

+ (BOOL)swizzleClassMethod:(SEL)systemSelector withSelector:(SEL)swizzledSelector {
    /**注意, 类方法列表存放在元类里, 实例方法列表存放在类里, 故这里要获取元类*/
    Class metaClass = objc_getMetaClass(object_getClassName(self));
    Method systemMethod = class_getClassMethod(metaClass, systemSelector);
    if (!systemMethod) return NO;
    Method swizzledMethod = class_getClassMethod(metaClass, swizzledSelector);
    if (!swizzledMethod) return NO;
    BOOL didAddMethod = class_addMethod(metaClass, systemSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(metaClass, swizzledSelector,
                            method_getImplementation(systemMethod),
                            method_getTypeEncoding(systemMethod));
    } else {
        method_exchangeImplementations(systemMethod, swizzledMethod);
    }
    return YES;
}

BOOL MNSwizzleClassMethod(Class cls, SEL systemSelector, SEL swizzledSelector) {
    return [cls swizzleClassMethod:systemSelector withSelector:swizzledSelector];
}

@end
