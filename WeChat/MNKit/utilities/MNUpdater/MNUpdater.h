//
//  MNVersionManager.h
//  MNKit
//
//  Created by Vincent on 2018/10/28.
//  Copyright © 2018年 小斯. All rights reserved.
//  检查版本更新

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MNVersionCheckHandler)(BOOL update, NSString *_Nullable version, NSDictionary *_Nullable result, NSError *_Nullable error);

@interface MNUpdater : NSObject

/**
 检查版本信息<是否需要更新版本>
 @param appleID 应用id
 @param timeInterval 超时时长
 @param completion 信息回调<主线程>
 */
+ (void)checkProductVersionFromItunes:(nullable NSString *)appleID
                      timeoutInterval:(NSTimeInterval)timeInterval
                           completion:(MNVersionCheckHandler)completion;

/**
 检查版本信息<是否需要更新版本>
 @param appleID 应用id
 @param timeInterval 超时时长
 @param queue 回调线程
 @param completion 应用信息回调
 */
+ (void)checkProductVersionFromItunes:(nullable NSString *)appleID
                      timeoutInterval:(NSTimeInterval)timeInterval
                                queue:(nullable dispatch_queue_t)queue
                           completion:(MNVersionCheckHandler)completion;

@end

NS_ASSUME_NONNULL_END
