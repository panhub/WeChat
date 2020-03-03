//
//  NSBundle+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/2/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  NSBundle 扩展

#import <Foundation/Foundation.h>

@interface NSBundle (MNHelper)
/**
 获取工程内Bundle
 @param name Bundle Name
 @return Bundle
 */
+ (NSBundle *)bundleWithName:(NSString *)name;
NSBundle * NSBundleWithName (NSString *name);

/**
 获取工程plist配置信息字典
 @return 配置信息字典
 */
+ (NSDictionary<NSString *, id>*)bundleInfo;
NSDictionary<NSString *, id>* NSBundleInfo (void);

/**
 获取工程唯一标识
 @return 工程唯一标识
 */
+ (NSString *)identifier;
NSString * NSBundleIdentifier (void);

/**
 获取项目版本号
 @return 版本号
 */
+ (NSString *)buildVersion;
NSString * NSBuildVersion (void);

/**
 获取Bundle版本号
 @return 版本号
 */
+ (NSString *)bundleVersion;
NSString * NSBundleVersion (void);

/**
 获取项目工程名
 @return 项目工程名
 */
+ (NSString *)displayName;
NSString * NSBundleDisplayName (void);

/**
 获取工程白名单
 @return 白名单配置
 */
+ (NSArray <NSString *>*)schemes;
NSArray <NSString *>* NSBundleSchemes (void);

/**
 获取Bundle下图片路径
 @param name 图片资源名
 @param type 图片类型
 @param directory 所在文件
 @return 图片资源路径
 */
- (NSString *)imagePathForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory;

@end


@interface MNBundle : NSObject

/**
 MNKit内置Bundle
 @return Bundle
 */
+ (NSBundle *)mainBundle;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @param type 类型 png, jpg, gif
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name inDirectory:(NSString *)directory;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @param type 图片类型
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory;

@end


@interface UIImage (MNBundle)
/**
 获取 Bundle 下图片资源
 @param name 图片名
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name;

/**
 获取 Bundle 下图片资源
 @param name 图片名
 @param type 类型 png, jpg, gif
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type;

/**
 获取 Bundle 下图片资源
 @param name 图片名
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name inDirectory:(NSString *)directory;

/**
 获取 Bundle 下图片资源
 @param name 图片名
 @param type 类型 png, jpg, gif
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory;

/**
 获取 Bundle 下图片资源
 @param bundle Bundle
 @param name 图片名
 @param type 类型 png, jpg, gif
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *)imageWithBundle:(NSBundle *)bundle forResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory;

@end




