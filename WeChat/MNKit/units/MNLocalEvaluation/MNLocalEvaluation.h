//
//  MNLocalEvaluation.h
//  MNKit
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  TouchID FaceID 验证辅助
//  FaceID需要在info.plist中增加NSFaceIDUsageDescription权限申请说明

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNLocalEvaluation : NSObject
/**
 是否支持本地验证<TouchID或FaceID>
*/
@property (nonatomic, class, readonly, getter=isEnabled) BOOL enabled;
/**
 是否在验证中
 */
@property (nonatomic, class, readonly, getter=isEvaluating) BOOL evaluating;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
/**
 是否支持TouchEvaluation
*/
@property (nonatomic, class, readonly, getter=isTouchEnabled) BOOL touchEnabled;
/**
 是否支持FaceEvaluation
*/
@property (nonatomic, class, readonly, getter=isFaceEnabled) BOOL faceEnabled;
#endif

/**
 Touch ID 验证
 @param reason 验证提示信息
 @param handler 输入密码回调
 @param reply 验证结果回调
 */
+ (void)evaluateReason:(NSString *_Nullable)reason
              password:(void(^_Nullable)(void))handler
                 reply:(void(^_Nullable)(BOOL succeed, NSError *error))reply;

@end

NS_ASSUME_NONNULL_END
