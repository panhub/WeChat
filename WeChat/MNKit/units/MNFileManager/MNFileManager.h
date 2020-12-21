//
//  MNFileManager.h
//  MNKit
//
//  Created by Vincent on 2018/7/17.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * _Nonnull const MNKitFolderName;

NS_ASSUME_NONNULL_BEGIN

@interface MNFileManager : NSObject

/**document路径*/
+ (NSString *)documentPath;
FOUNDATION_EXPORT NSString * MNDocumentPath (void);
FOUNDATION_EXPORT NSString * MNDocumentPathAppending (NSString *path);

/**library路径*/
+ (NSString *)libraryPath;
FOUNDATION_EXPORT NSString * MNLibraryPath (void);
FOUNDATION_EXPORT NSString * MNLibraryPathAppending (NSString *path);

/**cache路径*/
+ (NSString *)cachePath;
FOUNDATION_EXPORT NSString * MNCachePath (void);
FOUNDATION_EXPORT NSString * MNCachePathAppending (NSString *path);

/**偏好信息路径, 来自library, 支持备份*/
+ (NSString *)preferencePath;
FOUNDATION_EXPORT NSString * MNPreferencePath (void);
FOUNDATION_EXPORT NSString * MNPreferencePathAppending (NSString *path);

/**temp路径*/
+ (NSString *)tempPath;
FOUNDATION_EXPORT NSString * MNTempPath (void);
FOUNDATION_EXPORT NSString * MNTempPathAppending (NSString *path);

/**
 提供默认缓存路径<在cache文件夹下>
 @return 缓存路径
 */
+ (NSString *)cacheDirectory;
FOUNDATION_EXPORT NSString * MNCacheDirectory (void);
FOUNDATION_EXPORT NSString * MNCacheDirectoryAppending (NSString *path);

/**
 提供缓存路径<支持备份的路径, 不要清空>
 @return 默认路径
 */
+ (NSString *)libraryDirectory;
FOUNDATION_EXPORT NSString * MNLibraryDirectory (void);
FOUNDATION_EXPORT NSString * MNLibraryDirectoryAppending (NSString *path);

/**
 文件/文件夹 是否存在
 @param path 路径
 @param isDirectory 是否是文件夹
 @return 是否存在
 */
+ (BOOL)itemExistsAtPath:(NSString *)path isDirectory:(BOOL *_Nullable)isDirectory;

/**
 文件/文件夹 是否存在
 @param URL 路径
 @param isDirectory 是否是文件夹
 @return 是否存在
 */
+ (BOOL)itemExistsAtURL:(NSURL *)URL isDirectory:(BOOL *_Nullable)isDirectory;

/**
 创建文件夹
 @param path 文件夹路径
 @param error 错误信息
 @return 是否创建成功
 */
+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *_Nullable*_Nullable)error;

/**
 创建文件夹
 @param URL 文件夹路径
 @param error 错误信息
 @return 是否创建成功
 */
+ (BOOL)createDirectoryAtURL:(NSURL *)URL error:(NSError *_Nullable*_Nullable)error;

/**
 创建文件
 @param path 文件路径
 @param error 错误信息
 @return 是否创建成功
 */
+ (BOOL)createFileAtPath:(NSString *)path error:(NSError *_Nullable*_Nullable)error;

/**
 创建文件
 @param URL 文件路径
 @param error 错误信息
 @return 是否创建成功
 */
+ (BOOL)createFileAtURL:(NSURL *)URL error:(NSError *_Nullable*_Nullable)error;

/**
 创建文件/文件夹
 @param itemPath 文件/文件夹路径
 @param error 错误信息
 @return 是否创建成功
 */
+ (BOOL)createItemAtPath:(NSString *)itemPath error:(NSError *_Nullable*_Nullable)error;

/**
 创建文件/文件夹
 @param URL 文件/文件夹路径
 @param error 错误信息
 @return 是否创建成功
 */
+ (BOOL)createItemAtURL:(NSURL *)URL error:(NSError *_Nullable*_Nullable)error;

/**
 删除文件/文件夹
 @param path 文件/文件夹路径
 @param error 错误信息
 @return 是否删除成功
 */
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *_Nullable*_Nullable)error;

/**
 删除文件夹下所有文件
 @param error 错误信息
 @param path 文件夹路径
 @return 是否删除成功
 */
+ (BOOL)removeAllItemsAtPath:(NSString *)path error:(NSError *_Nullable*_Nullable)error;

/**
 移动文件到指定路径
 @param srcPath 原文件路径
 @param dstPath 目标路径
 @param error 错误信息
 @return 是否移动成功
 */
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError *_Nullable*_Nullable)error;

/**
 移动文件到指定路径
 @param srcURL 原文件路径
 @param dstURL 目标路径
 @param error 错误信息
 @return 是否移动成功
 */
+ (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError *_Nullable*_Nullable)error;

/**
 获取文件/文件夹体积
 @param itemPath 文件/文件夹路径
 @return 体积大小<M>
 */
+ (CGFloat)itemSizeAtPath:(NSString *)itemPath;

/**
 获取文件/文件夹体积
 @param itemURL 文件/文件夹路径
 @return 体积大小<M>
 */
+ (CGFloat)itemSizeAtURL:(NSURL *)itemURL;

@end

NS_ASSUME_NONNULL_END
