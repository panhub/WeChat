//
//  NSObject+MNEvent.m
//  MNKit
//
//  Created by Vincent on 2019/1/15.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "NSObject+MNEvent.h"
#import <objc/message.h>

static NSString * MNObjectEventTargetKey = @"com.mn.object.event.cache.key";

@interface MNEventTarget : NSObject
/**
 事件回调
 */
@property (nonatomic, copy) MNEventHandler eventHandler;
/**
 通知名
 */
@property (nonatomic, copy) NSNotificationName notificationName;
/**
 按钮事件
 */
@property (nonatomic) UIControlEvents events;

/**
 事件方法
 @param sender 按钮/通知
 */
- (void)handEvent:(id)sender;

@end

@implementation MNEventTarget

- (void)handEvent:(id)sender {
    if (self.eventHandler) self.eventHandler(sender);
}

- (void)dealloc {
    self.eventHandler = nil;
    if (self.notificationName.length > 0) [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation NSObject (MNEventHandler)
#pragma mark - Cache
- (NSMutableArray <MNEventTarget *>*)mn_eventTargets {
    NSMutableArray <MNEventTarget *>*targets = objc_getAssociatedObject(self, &MNObjectEventTargetKey);
    if (!targets) {
        targets = [NSMutableArray array];
        [self setMn_eventTargets:targets];
    }
    return targets;
}

- (void)setMn_eventTargets:(NSMutableArray<MNEventTarget *> *)mn_eventTargets {
    objc_setAssociatedObject(self, &MNObjectEventTargetKey, mn_eventTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Event
- (void)handNotification:(NSNotificationName)notificationName eventHandler:(MNEventHandler)eventHandler {
    [self handNotification:notificationName object:nil eventHandler:eventHandler];
}

- (void)handNotification:(NSNotificationName)notificationName object:(id)obj eventHandler:(MNEventHandler)eventHandler {
    if (!eventHandler || notificationName.length <= 0) return;
    MNEventTarget *target = [MNEventTarget new];
    target.notificationName = notificationName;
    target.eventHandler = eventHandler;
    [self.mn_eventTargets addObject:target];
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:@selector(handEvent:)
                                                 name:notificationName
                                               object:obj];
}

- (void)removeNotification:(NSNotificationName)notificationName {
    if (notificationName.length <= 0) return;
    NSMutableArray <MNEventTarget *>*targets = self.mn_eventTargets;
    if (targets.count <= 0) return;
    NSMutableArray <MNEventTarget *>*array = @[].mutableCopy;
    [targets enumerateObjectsUsingBlock:^(MNEventTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.notificationName isEqualToString:notificationName]) {
            obj.eventHandler = nil;
            obj.notificationName = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:obj];
            [array addObject:obj];
        }
    }];
    [targets removeObjectsInArray:array];
}

- (void)removeAllNotifications {
    NSMutableArray <MNEventTarget *>*targets = self.mn_eventTargets;
    if (targets.count <= 0) return;
    NSMutableArray <MNEventTarget *>*array = @[].mutableCopy;
    [targets enumerateObjectsUsingBlock:^(MNEventTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.notificationName.length > 0) {
            obj.eventHandler = nil;
            obj.notificationName = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:obj];
            [array addObject:obj];
        }
    }];
    [targets removeObjectsInArray:array];
}

@end

@implementation UIControl (MNEventHandler)

- (void)handEvents:(UIControlEvents)events eventHandler:(MNEventHandler)eventHandler {
    if (!eventHandler) return;
    MNEventTarget *target = [MNEventTarget new];
    target.events = events;
    target.eventHandler = eventHandler;
    [self.mn_eventTargets addObject:target];
    [self addTarget:target action:@selector(handEvent:) forControlEvents:events];
}

- (void)handTouchEventHandler:(MNEventHandler)eventHandler {
    [self handEvents:UIControlEventTouchUpInside eventHandler:eventHandler];
}

- (void)removeEvents:(UIControlEvents)events {
    NSMutableArray <MNEventTarget *>*targets = self.mn_eventTargets;
    if (targets.count <= 0) return;
    NSMutableArray <MNEventTarget *>*array = @[].mutableCopy;
    [targets enumerateObjectsUsingBlock:^(MNEventTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.events == events) {
            obj.eventHandler = nil;
            [self removeTarget:obj action:@selector(handEvent:) forControlEvents:events];
            [array addObject:obj];
        }
    }];
    [targets removeObjectsInArray:array];
}

- (void)removeAllEvents {
    NSMutableArray <MNEventTarget *>*targets = self.mn_eventTargets;
    if (targets.count <= 0) return;
    NSMutableArray <MNEventTarget *>*array = @[].mutableCopy;
    [targets enumerateObjectsUsingBlock:^(MNEventTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.events != 0) {
            obj.eventHandler = nil;
            [self removeTarget:obj action:@selector(handEvent:) forControlEvents:obj.events];
            [array addObject:obj];
        }
    }];
    [targets removeObjectsInArray:array];
}

@end


@implementation UIGestureRecognizer (MNEventHandler)

- (void)handEventHandler:(MNEventHandler)eventHandler {
    if (!eventHandler) return;
    MNEventTarget *target = [MNEventTarget new];
    target.eventHandler = eventHandler;
    [self.mn_eventTargets addObject:target];
    [self addTarget:target action:@selector(handEvent:)];
}

- (void)removeAllEventHandlers {
    NSMutableArray <MNEventTarget *>*targets = self.mn_eventTargets;
    if (targets.count <= 0) return;
    [targets enumerateObjectsUsingBlock:^(MNEventTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.eventHandler = nil;
        [self removeTarget:obj action:@selector(handEvent:)];
    }];
    [targets removeAllObjects];
}

@end


@implementation UIView (MNEventHandler)
- (void)handTapEventHandler:(MNEventHandler)eventHandler {
    [self handTapConfiguration:nil eventHandler:eventHandler];
}

- (void)handTapConfiguration:(void(^)(UITapGestureRecognizer *))configuration eventHandler:(MNEventHandler)eventHandler
{
    if (!eventHandler) return;
    if ([self isKindOfClass:UIControl.class]) {
        [((UIControl *)self) handTouchEventHandler:eventHandler];
        return;
    }
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] init];
    recognizer.numberOfTapsRequired = 1;
    if (configuration) configuration(recognizer);
    if (recognizer) {
        self.userInteractionEnabled = YES;
        [recognizer handEventHandler:eventHandler];
        [self addGestureRecognizer:recognizer];
    }
}

- (void)handPanConfiguration:(void(^)(UIPanGestureRecognizer *))configuration eventHandler:(MNEventHandler)eventHandler
{
    if (!eventHandler) return;
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]init];
    recognizer.maximumNumberOfTouches = 1;
    if (configuration) configuration(recognizer);
    if (recognizer) {
        self.userInteractionEnabled = YES;
        [recognizer handEventHandler:eventHandler];
        [self addGestureRecognizer:recognizer];
    }
}

- (void)handLongPressConfiguration:(void(^)(UILongPressGestureRecognizer *))configuration eventHandler:(MNEventHandler)eventHandler
{
    if (!eventHandler) return;
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] init];
    recognizer.minimumPressDuration = .5f;
    if (configuration) configuration(recognizer);
    if (recognizer) {
        self.userInteractionEnabled = YES;
        [recognizer handEventHandler:eventHandler];
        [self addGestureRecognizer:recognizer];
    }
}

- (void)handPinchConfiguration:(void(^)(UIPinchGestureRecognizer *))configuration eventHandler:(MNEventHandler)eventHandler
{
    if (!eventHandler) return;
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc]init];
    recognizer.scale = [[UIScreen mainScreen] scale];
    if (configuration) configuration(recognizer);
    if (recognizer) {
        self.userInteractionEnabled = YES;
        [recognizer handEventHandler:eventHandler];
        [self addGestureRecognizer:recognizer];
    }
}

- (void)removeAllGestureHandlers {
    NSArray<UIGestureRecognizer *> *recognizers = self.gestureRecognizers.copy;
    if (recognizers.count <= 0) return;
    [recognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer * _Nonnull rec, NSUInteger idx, BOOL * _Nonnull stop) {
        [rec removeAllEventHandlers];
    }];
}

@end
