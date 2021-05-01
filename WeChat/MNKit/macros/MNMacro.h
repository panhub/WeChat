//
//  MNMacro.h
//  MNKit
//
//  Created by Vincent on 2018/10/30.
//  Copyright © 2018年 小斯. All rights reserved.
//  公共宏

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIDevice+MNHelper.h"
#import "MNConfiguration.h"

#ifndef MNMacro_h
#define MNMacro_h

#define MN_IS_SIMULATOR   UIDeviceSimulator()

#if DEBUG
#define MN_IS_DEBUG   YES
#else
#define MN_IS_DEBUG   NO
#endif

#define MN_IS_IPAD  UIInterfacePadModel()

#define MN_IS_FIRST_INSTALL  [[MNConfiguration configuration] isFirstInstall]

#define MN_IS_LOW_SCALE  (UIScreen.mainScreen.scale < 3.f)

#define MN_SEPARATOR_HEIGHT (MN_IS_LOW_SCALE ? 1.f : .5f)

#define MN_THEME_COLOR  MN_R_G_B(30.f, 144.f, 25.f)

#define MN_APP_DOWNLOAD_URL(appId)  [@"https://apps.apple.com/cn/app/id" stringByAppendString:appId]

#ifdef __cplusplus
#define MNKIT_EXTERN_C_BEGIN  extern "C" {
#define MNKIT_EXTERN_C_END  }
#define MNKIT_EXTERN   extern "C" __attribute__((visibility ("default")))
#else
#define MNKIT_EXTERN_C_BEGIN
#define MNKIT_EXTERN_C_END
#define MNKIT_EXTERN   extern __attribute__((visibility ("default")))
#endif

#ifndef MNKIT_STATIC_INLINE
#define MNKIT_STATIC_INLINE  static inline
#endif

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

#ifndef OPPOSITE
#define OPPOSITE(number) (-1*(number))
#endif

#endif



