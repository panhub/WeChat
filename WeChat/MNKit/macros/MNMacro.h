//
//  MNMacro.h
//  MNKit
//
//  Created by Vincent on 2018/10/30.
//  Copyright © 2018年 小斯. All rights reserved.
//  公共宏

#import <UIKit/UIKit.h>
#import "MNConfiguration.h"
#import "UIDevice+MNHelper.h"
#import <QuartzCore/QuartzCore.h>

#ifndef MNMacro_h
#define MNMacro_h

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH   UIScreenWidth()
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT   UIScreenHeight()
#endif

#ifndef SCREEN_MAX
#define SCREEN_MAX  UIScreenMax()
#endif

#ifndef SCREEN_MIN
#define SCREEN_MIN  UIScreenMin()
#endif

#ifndef IS_SIMULATOR
#define IS_SIMULATOR   UIDeviceSimulator()
#endif

#ifndef IS_DEBUG
#if DEBUG
#define IS_DEBUG   YES
#else
#define IS_DEBUG   NO
#endif
#endif

#ifndef IS_IPAD
#define IS_IPAD  UIInterfacePadModel()
#endif

#ifndef IS_FIRST_INSTALL
#define IS_FIRST_INSTALL  [[MNConfiguration configuration] isFirstInstall]
#endif

#ifndef IS_LOW_SCALE
#define IS_LOW_SCALE  (UIScreenScale() < 3.f)
#endif

#ifndef TAB_BAR_HEIGHT
#define TAB_BAR_HEIGHT  (IS_IPAD ? (60.f + UITabSafeHeight()) : UITabBarHeight())
#endif

#ifndef TAB_SAFE_HEIGHT
#define TAB_SAFE_HEIGHT  UITabSafeHeight()
#endif

#ifndef NAV_BAR_HEIGHT
#define NAV_BAR_HEIGHT  UINavBarHeight()
#endif

#ifndef STATUS_BAR_HEIGHT
#define STATUS_BAR_HEIGHT  UIStatusBarHeight()
#endif

#ifndef TOP_BAR_HEIGHT
#define TOP_BAR_HEIGHT  UITopBarHeight()
#endif

#ifndef MN_SEPARATOR_HEIGHT
#define MN_SEPARATOR_HEIGHT (IS_LOW_SCALE ? .5f : .3f)
#endif

#ifdef __cplusplus
#define MNKIT_EXTERN_C_BEGIN  extern "C" {
#define MNKIT_EXTERN_C_END  }
#define MNKIT_EXTERN   extern "C" __attribute__((visibility ("default")))
#else
#define MNKIT_EXTERN_C_BEGIN
#define MNKIT_EXTERN_C_END
#define MNKIT_EXTERN   extern __attribute__((visibility ("default")))
#endif

#define MNKIT_STATIC_INLINE  static inline

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored\"-Wshadow\"") \
autoreleasepool{} __weak typeof(var) weak##var = var; \
_Pragma("clang diagnostic pop")
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored\"-Wshadow\"") \
autoreleasepool{} __strong typeof(var) var = weak##var; \
_Pragma("clang diagnostic pop")
#else
#define weakify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored\"-Wshadow\"") \
autoreleasepool{} __block typeof(var) block##var = var; \
_Pragma("clang diagnostic pop")
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored\"-Wshadow\"") \
autoreleasepool{} typeof(var) var = block##var; \
_Pragma("clang diagnostic pop")
#endif
#endif

#define PropertyWeak(attributed) @property (nonatomic, weak) attributed
#define PropertyCopy(attributed) @property (nonatomic, copy) attributed
#define PropertyStrong(attributed) @property (nonatomic, strong) attributed
#define PropertyAssign(attributed) @property (nonatomic) attributed
#define PropertyString(attributed) @property (nonatomic, copy) NSString *attributed
#define PropertyBlock(attributed) @property (nonatomic, copy) attributed
#define PropertyProtocol(protocol) @property (nonatomic, weak) id<protocol> delegate
#define PropertyBOOL(attributed) @property (nonatomic) BOOL attributed

#ifndef NSRangeZero
#define NSRangeZero  NSMakeRange(0, 0)
#endif

#define UIViewControllerPush(cls, ani) \
[self.navigationController pushViewController:[NSClassFromString(cls) new] animated:ani]

#define UIViewControllerPop(ani) \
[self.navigationController popViewControllerAnimated:ani]

#ifndef kPath
#define kPath(path)    @(((void)(NO && ((void)path, NO)), strchr(# path, '.') + 1))
#endif

#ifndef kTransform
#define kTransform(type, obj)   ((type)(obj))
#endif

#ifndef PostNotify
#define PostNotify(name, obj) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored\"-Wshadow\"") \
autoreleasepool{} [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj]; \
_Pragma("clang diagnostic pop")
#endif

#define condition(cond, do, todo) \
autoreleasepool{ \
} \
if (cond) \
{ \
do; \
} else { \
todo; \
}

#ifndef NEXT_TODO
#define NEXT_TODO(...)
#endif

#endif
