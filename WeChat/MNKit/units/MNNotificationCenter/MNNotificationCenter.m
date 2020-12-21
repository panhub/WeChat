//
//  MNNotificationCenter.m
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//

#import "MNNotificationCenter.h"

#define Lock()      dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()   dispatch_semaphore_signal(_semaphore)

@interface MNNotificationCenter ()
{
    @private
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, strong) NSMutableDictionary <MNNotificationName, NSMutableArray <NSInvocation *>*>*invocations;
@end

static MNNotificationCenter *_center;
@implementation MNNotificationCenter
+ (MNNotificationCenter *)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _center = [[MNNotificationCenter alloc] init];
    });
    return _center;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _center = [super allocWithZone:zone];
    });
    return _center;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _center = [super init];
        _semaphore = dispatch_semaphore_create(1);
        _center.invocations = [NSMutableDictionary dictionary];
    });
    return _center;
}

#pragma mark - Add Observer
- (BOOL)addObserver:(id)observer selector:(SEL)aSelector name:(MNNotificationName)aName {
    if (!observer || aSelector == NULL || !aName || aName.length <= 0) return NO;
    NSMethodSignature *signature = [[observer class] instanceMethodSignatureForSelector:aSelector];
    if (!signature) return NO;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (!invocation) return NO;
    invocation.target = observer;
    invocation.selector = aSelector;
    Lock();
    NSMutableArray <NSInvocation *>*invocations = [self invocationsForNotificationName:aName];
    [invocations addObject:invocation];
    Unlock();
    return YES;
}

#pragma mark - Post Notification
- (BOOL)postNotificationName:(MNNotificationName)aName {
    return [self postNotificationName:aName object:nil userInfo:nil];
}

- (BOOL)postNotificationName:(MNNotificationName)aName object:(id)anObject {
    return [self postNotificationName:aName object:anObject userInfo:nil];
}

- (BOOL)postNotificationName:(MNNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)userInfo {
    MNNotification *notification = [[MNNotification alloc] initWithName:aName object:anObject userInfo:userInfo];
    return [self postNotification:notification];
}

- (BOOL)postNotification:(MNNotification *)notification {
    if (!notification.name || notification.name.length <= 0) return NO;
    Lock();
    NSMutableArray <NSInvocation *>*invocations = [self.invocations objectForKey:notification.name];
    for (NSInvocation *invocation in invocations) {
        if ([NSStringFromSelector(invocation.selector) hasSuffix:@":"]) {
            [invocation setArgument:&notification atIndex:2];
        }
        [invocation invoke];
    }
    Unlock();
    return YES;
}

#pragma mark - Remove Observer
- (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil];
}

- (void)removeObserver:(id)observer name:(MNNotificationName)aName {
    if (!observer) return;
    Lock();
    if (aName) {
        NSMutableArray <NSInvocation *>*removeds = @[].mutableCopy;
        NSMutableArray <NSInvocation *>*invocations = [self.invocations objectForKey:aName];
        for (NSInvocation *invocation in invocations) {
            if (invocation.target == observer) {
                [removeds addObject:invocation];
            }
        }
        [invocations removeObjectsInArray:removeds];
    } else {
        for (NSMutableArray <NSInvocation *>*invocations in self.invocations) {
            NSMutableArray <NSInvocation *>*removeds = @[].mutableCopy;
            for (NSInvocation *invocation in invocations) {
                if (invocation.target == observer) {
                    [removeds addObject:invocation];
                }
            }
            [invocations removeObjectsInArray:removeds];
        }
    }
    Unlock();
}

#pragma mark - Cache
- (NSMutableArray <NSInvocation *>*)invocationsForNotificationName:(MNNotificationName)aName {
    NSMutableArray <NSInvocation *>*invocations = [self.invocations objectForKey:aName];
    if (!invocations) {
        invocations = [NSMutableArray arrayWithCapacity:1];
        [self.invocations setObject:invocations forKey:aName];
    }
    return invocations;
}

@end
