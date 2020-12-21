//
//  NSObject+MNObserving.m
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/1/15.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import "NSObject+MNObserving.h"
#import "NSObject+MNSwizzle.h"
#import <objc/runtime.h>

static NSString * MNObserveItemAssociatedKey = @"com.mn.observe.item.associated.key";

@interface MNObserveItem : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy)  NSString *keyPath;
@end

@implementation MNObserveItem

@end

@implementation NSObject (MNObserving)

+ (void)load {
    /*
    [self swizzleInstanceMethod:@selector(addObserver:forKeyPath:options:context:) withSelector:@selector(mn_addObserver:forKeyPath:options:context:)];
    [self swizzleInstanceMethod:@selector(removeObserver:forKeyPath:) withSelector:@selector(mn_removeObserver:forKeyPath:)];
    [self swizzleInstanceMethod:@selector(removeObserver:forKeyPath:context:) withSelector:@selector(mn_removeObserver:forKeyPath:context:)];
     */
}

- (void)mn_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!observer || keyPath.length <= 0) return;
    if (![observer observedObj:self forKeyPath:keyPath]) {
        [self mn_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
    /*
    if (![self observeItemForObserver:observer keyPath:keyPath]) {
        //没有监听, 就设置监听
        MNObserveItem *item = [MNObserveItem new];
        item.observer = observer;
        item.keyPath = keyPath;
        [[self observeItems_] addObject:item];
        [self mn_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
     */
}

- (void)mn_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if (!observer || keyPath.length <= 0) return;
    if ([observer observedObj:self forKeyPath:keyPath]) {
        [self mn_removeObserver:observer forKeyPath:keyPath];
    }
    /*
    MNObserveItem *item = [self observeItemForObserver:observer keyPath:keyPath];
    if (item) {
        //存在监听, 删除监听
        [[self observeItems_] removeObject:item];
        [self mn_removeObserver:observer forKeyPath:keyPath];
    }
     */
}

- (void)mn_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if (!observer || keyPath.length <= 0) return;
    if ([observer observedObj:self forKeyPath:keyPath]) {
        [self mn_removeObserver:observer forKeyPath:keyPath context:context];
    }
    /*
    MNObserveItem *item = [self observeItemForObserver:observer keyPath:keyPath];
    if (item) {
        //存在监听, 删除监听
        [[self observeItems_] removeObject:item];
        [self mn_removeObserver:observer forKeyPath:keyPath context:context];
    }
     */
}

#pragma mark - Get MNObserveItem
- (MNObserveItem *)observeItemForObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    NSMutableArray <MNObserveItem *>*observeItems = [self observeItems_];
    __block MNObserveItem *item;
    [observeItems enumerateObjectsUsingBlock:^(MNObserveItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([observer isEqual:obj.observer] && [keyPath isEqualToString:obj.keyPath]) {
            item = obj;
            *stop = YES;
        }
    }];
    return item;
}

#pragma mark - Set/Get MNObserveItems
- (NSMutableArray <MNObserveItem *>*)observeItems_ {
    NSMutableArray <MNObserveItem *>*observeItems = objc_getAssociatedObject(self, &MNObserveItemAssociatedKey);
    if (!observeItems) {
        observeItems = [NSMutableArray arrayWithCapacity:0];
        [self setObserveItems_:observeItems];
    }
    return observeItems;
}

- (void)setObserveItems_:(NSMutableArray <MNObserveItem *>*)bserveItems_ {
    objc_setAssociatedObject(self, &MNObserveItemAssociatedKey, bserveItems_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 判断是否已监听属性变化
- (BOOL)observedObj:(NSObject *)obj forKeyPath:(NSString *)keyPath {
    if (!obj || keyPath.length <= 0) return NO;
    id info = obj.observationInfo;
    NSArray *observances = [info valueForKey:@"_observances"];
    for (id objc in observances) {
        id observer = [objc valueForKeyPath:@"_observer"];
        if (![observer isEqual:self]) continue;
        id property = [objc valueForKeyPath:@"_property"];
        NSString *_keyPath = [property valueForKeyPath:@"_keyPath"];
        if ([_keyPath isEqualToString:keyPath]) return YES;
    }
    return NO;
}

#pragma mark - 安全监听
- (void)safelyAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!observer || keyPath.length <= 0) return;
    if (![observer observedObj:self forKeyPath:keyPath]) {
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)safelyRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if (!observer || keyPath.length <= 0) return;
    if ([observer observedObj:self forKeyPath:keyPath]) {
        [self removeObserver:observer forKeyPath:keyPath];
    }
}

@end
