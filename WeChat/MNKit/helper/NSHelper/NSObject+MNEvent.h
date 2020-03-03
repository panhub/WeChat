//
//  NSObject+MNEvent.h
//  MNKit
//
//  Created by Vincent on 2019/1/15.
//  Copyright © 2019年 小斯. All rights reserved.
//  事件响应回调

#import <Foundation/Foundation.h>
@class MNEventTarget;

typedef void(^MNEventHandler)(id sender);

@interface NSObject (MNEventHandler)
/**
 存放事件回调者
*/
@property (nonatomic, strong) NSMutableArray <MNEventTarget *>*mn_eventTargets;

/**
 添加通知回调
 @param notificationName 通知名
 @param eventHandler 事件回调
 */
- (void)handNotification:(NSNotificationName)notificationName eventHandler:(MNEventHandler)eventHandler;

/**
 添加通知回调
 @param notificationName 通知名
 @param obj 通知参数
 @param eventHandler 事件回调
 */
- (void)handNotification:(NSNotificationName)notificationName object:(id)obj eventHandler:(MNEventHandler)eventHandler;

/**
 删除指定通知回调
 @param notificationName 通知名称
 */
- (void)removeNotification:(NSNotificationName)notificationName;

/**
 删除所有通知事件回调
 */
- (void)removeAllNotifications;

@end

@interface UIControl (MNEventHandler)
/**
 事件回调
 @param events 事件
 @param eventHandler 回调
 */
- (void)handEvents:(UIControlEvents)events eventHandler:(MNEventHandler)eventHandler;

/**
 点击事件回调
 @param eventHandler 事件回调
*/
- (void)handTouchEventHandler:(MNEventHandler)eventHandler;

/**
 删除指定事件的回调
 @param events 事件
 */
- (void)removeEvents:(UIControlEvents)events;

/**
 删除所有事件回调
 */
- (void)removeAllEvents;

@end


@interface UIGestureRecognizer (MNEventHandler)
/**
 手势事件回调
 @param eventHandler 回调
 */
- (void)handEventHandler:(MNEventHandler)eventHandler;

/**
 删除事件回调
 */
- (void)removeAllEventHandlers;

@end

@interface UIView (MNEventHandler)
/**
 添加点击手势回调
 @param eventHandler 点击事件回调
 */
- (void)handTapEventHandler:(MNEventHandler)eventHandler;

/**
 添加点击事件回调
 @param configuration 点击手势处理
 @param eventHandler 点击事件回调
 */
- (void)handTapConfiguration:(void(^)(UITapGestureRecognizer *recognizer))configuration eventHandler:(MNEventHandler)eventHandler;

/**
 添加拖拽事件回调
 @param configuration 拖拽手势处理
 @param eventHandler 拖拽事件回调
 */
- (void)handPanConfiguration:(void(^)(UIPanGestureRecognizer *recognizer))configuration eventHandler:(MNEventHandler)eventHandler;

/**
 添加长按事件回调
 @param configuration 长按手势处理
 @param eventHandler 长按事件回调
 */
- (void)handLongPressConfiguration:(void(^)(UILongPressGestureRecognizer *recognizer))configuration eventHandler:(MNEventHandler)eventHandler;

/**
 添加捏合事件回调
 @param configuration 捏合手势处理
 @param eventHandler 捏合事件回调
 */
- (void)handPinchConfiguration:(void(^)(UIPinchGestureRecognizer *recognizer))configuration eventHandler:(MNEventHandler)eventHandler;

/**
 删除所有手势事件回调
 */
- (void)removeAllGestureHandlers;

@end
