//
//  NSBundle+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/2/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  NSBundle 扩展

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSBundle (MNHelper)
/**
 获取工程内Bundle
 @param name Bundle Name
 @return Bundle
 */
+ (NSBundle *_Nullable)bundleWithName:(NSString *)name;
FOUNDATION_EXPORT NSBundle *_Nullable NSBundleWithName (NSString *name);

/**
 获取工程plist配置信息字典
 @return 配置信息字典
 */
+ (NSDictionary<NSString *, id>*)bundleInfo;
FOUNDATION_EXPORT NSDictionary<NSString *, id>* NSBundleInfo (void);

/**
 获取工程唯一标识
 @return 工程唯一标识
 */
+ (NSString *)identifier;
FOUNDATION_EXPORT NSString * NSBundleIdentifier (void);

/**
 获取项目版本号
 @return 版本号
 */
+ (NSString *)buildVersion;
FOUNDATION_EXPORT NSString * NSBuildVersion (void);

/**
 获取Bundle版本号
 @return 版本号
 */
+ (NSString *)bundleVersion;
FOUNDATION_EXPORT NSString * NSBundleVersion (void);

/**
 获取项目工程名
 @return 项目工程名
 */
+ (NSString *)displayName;
FOUNDATION_EXPORT NSString * NSBundleDisplayName (void);

/**
 获取工程白名单
 @return 白名单配置
 */
+ (NSArray <NSString *>*_Nullable)schemes;
FOUNDATION_EXPORT NSArray <NSString *>*_Nullable NSBundleSchemes (void);

/**
 获取Bundle下图片路径
 @param name 图片资源名
 @param type 图片类型
 @param directory 所在文件
 @return 图片资源路径
 */
- (NSString *_Nullable)imagePathForResource:(NSString *)name ofType:(NSString *_Nullable)type inDirectory:(NSString *_Nullable)directory;

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
+ (UIImage *_Nullable)imageForResource:(NSString *)name;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @param type 类型 png, jpg, gif
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name ofType:(NSString *_Nullable)type;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name inDirectory:(NSString *_Nullable)directory;

/**
 获取 框架Bundle 下图片资源
 @param name 图片名
 @param type 图片类型
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name ofType:(NSString *_Nullable)type inDirectory:(NSString *_Nullable)directory;

/**
获取框架内本地化语言
@param key 获取本地化语言key
@return 本地化语言
*/
+ (NSString *)localizedStringForKey:(NSString *)key;

/**
获取框架内本地化语言
@param key 获取本地化语言key
 @param value value
@return 本地化语言
*/
+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *_Nullable)value;

/**
获取框架内本地化语言
@param key 获取本地化语言key
@param value value
 @param tableName tableName
@return 本地化语言
*/
+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *_Nullable)value table:(NSString *_Nullable)tableName;
FOUNDATION_EXPORT NSString * MNLocalizedString(NSString *key);

@end


@interface UIImage (MNBundle)
/**
 获取 Bundle 下图片资源
 @param name 图片名
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name;

/**
 获取 Bundle 下图片资源
 @param name 图片名
 @param type 类型 png, jpg, gif
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name ofType:(NSString *_Nullable)type;

/**
 获取 Bundle 下图片资源
 @param name 图片名
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name inDirectory:(NSString *_Nullable)directory;

/**
 获取 Bundle 下图片资源
 @param name 图片名
 @param type 类型 png, jpg, gif
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *_Nullable)imageForResource:(NSString *)name ofType:(NSString *_Nullable)type inDirectory:(NSString *_Nullable)directory;

/**
 获取 Bundle 下图片资源
 @param bundle Bundle
 @param name 图片名
 @param type 类型 png, jpg, gif
 @param directory 所在文件夹
 @return 图片资源
 */
+ (UIImage *_Nullable)imageWithBundle:(NSBundle *)bundle forResource:(NSString *)name ofType:(NSString *_Nullable)type inDirectory:(NSString *_Nullable)directory;

@end
NS_ASSUME_NONNULL_END
