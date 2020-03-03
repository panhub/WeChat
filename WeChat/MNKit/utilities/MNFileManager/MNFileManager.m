//
//  MNFileManager.m
//  MNKit
//
//  Created by Vincent on 2018/7/17.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNFileManager.h"

NSString * const MNKitFolderName = @"MNKitBox";

@implementation MNFileManager

+ (NSString *)documentPath {
    static NSString *document;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    });
    return document;
}

inline NSString * MNDocumentPath (void) {
    return [MNFileManager documentPath];
}

inline NSString * MNDocumentPathAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager documentPath];
    return [[MNFileManager documentPath] stringByAppendingPathComponent:path];
}

+ (NSString *)libraryPath {
    static NSString *library;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    });
    return library;
}

inline NSString * MNLibraryPath (void) {
    return [MNFileManager libraryPath];
}

inline NSString * MNLibraryPathAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager libraryPath];
    return [[MNFileManager libraryPath] stringByAppendingPathComponent:path];
}

+ (NSString *)cachePath {
    static NSString *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    });
    return cache;
}

inline NSString * MNCachePath (void) {
    return [MNFileManager cachePath];
}

inline NSString * MNCachePathAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager cachePath];
    return [[MNFileManager cachePath] stringByAppendingPathComponent:path];
}

+ (NSString *)preferencePath {
    return MNLibraryPathAppending(@"Preferences");
}

inline NSString * MNPreferencePath (void) {
    return [MNFileManager preferencePath];
}

inline NSString * MNPreferencePathAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager preferencePath];
    return [[MNFileManager preferencePath] stringByAppendingPathComponent:path];
}

+ (NSString *)tempPath {
    static NSString *temp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        temp = NSTemporaryDirectory();
    });
    return temp;
}

inline NSString * MNTempPath (void) {
    return [MNFileManager tempPath];
}

inline NSString * MNTempPathAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager tempPath];
    return [[MNFileManager tempPath] stringByAppendingPathComponent:path];
}

+ (NSString *)cacheDirectory {
    static NSString *kit_cache_path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *cachePath = MNCachePathAppending(MNKitFolderName);
        if ([MNFileManager createDirectoryAtPath:cachePath error:nil]) {
            kit_cache_path = cachePath;
        } else if ([MNFileManager createDirectoryAtPath:cachePath error:nil]) {
            kit_cache_path = cachePath;
        } else {
            kit_cache_path = MNCachePath();
        }
    });
    return kit_cache_path;
}

NSString * MNCacheDirectory (void) {
    return [MNFileManager cacheDirectory];
}

NSString * MNCacheDirectoryAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager cacheDirectory];
    return [[MNFileManager cacheDirectory] stringByAppendingPathComponent:path];
}

+ (NSString *)libraryDirectory {
    static NSString *kit_library_path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *libraryPath = MNLibraryPathAppending(MNKitFolderName);
        if ([MNFileManager createDirectoryAtPath:libraryPath error:nil]) {
            kit_library_path = libraryPath;
        } else if ([MNFileManager createDirectoryAtPath:libraryPath error:nil]) {
            kit_library_path = libraryPath;
        } else {
            kit_library_path = MNLibraryPath();
        }
    });
    return kit_library_path;
}

NSString * MNLibraryDirectory (void) {
    return [MNFileManager libraryDirectory];
}

NSString * MNLibraryDirectoryAppending (NSString *path) {
    if (path.length <= 0) return [MNFileManager libraryDirectory];
    return [[MNFileManager libraryDirectory] stringByAppendingPathComponent:path];
}

+ (BOOL)itemExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    if (path.length <= 0) {
        if (isDirectory) *isDirectory = NO;
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

+ (BOOL)itemExistsAtURL:(NSURL *)URL isDirectory:(BOOL *)isDirectory {
    return [self itemExistsAtPath:[URL path] isDirectory:isDirectory];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError **)error {
    if (path.length <= 0) return NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    if (path.pathExtension.length > 0) {
        path = [path stringByDeletingLastPathComponent];
    }
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+ (BOOL)createDirectoryAtURL:(NSURL *)URL error:(NSError **)error {
    return [self createDirectoryAtPath:[URL path] error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError **)error {
    if (path.length <= 0) return NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    if (path.pathExtension.length <= 0) return NO;
    if ([self createDirectoryAtPath:path error:error]) {
        return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return NO;
}

+ (BOOL)createFileAtURL:(NSURL *)URL error:(NSError **)error {
    return [self createFileAtPath:[URL path] error:error];
}

+ (BOOL)createItemAtPath:(NSString *)itemPath error:(NSError **)error {
    if (itemPath.length <= 0) return NO;
    if (itemPath.pathExtension.length > 0) {
        return [self createFileAtPath:itemPath error:error];
    }
    return [self createDirectoryAtPath:itemPath error:error];
}

+ (BOOL)createItemAtURL:(NSURL *)URL error:(NSError **)error {
    return [self createItemAtPath:[URL path] error:error];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
    if (path.length <= 0) return NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

+ (BOOL)removeAllItemsAtPath:(NSString *)path error:(NSError **)error {
    BOOL isDirectory = NO;
    if (![self itemExistsAtPath:path isDirectory:&isDirectory]) return YES;
    if (isDirectory) {
        BOOL succeed = YES;
        NSString *fileName;
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        while (fileName = [enumerator nextObject]) {
            BOOL s = [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:error];
            if (succeed) succeed = s;
        }
        return succeed;
    }
    return [self removeItemAtPath:path error:error];
}

+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {
    if (srcPath.length <= 0 || dstPath.length <= 0) return NO;
    if ([self createDirectoryAtPath:dstPath error:error]) {
        return [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:error];
    }
    return NO;
}

+ (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error {
    return [self moveItemAtPath:[srcURL path] toPath:[dstURL path] error:error];
}

+ (CGFloat)itemSizeAtPath:(NSString *)itemPath {
    if (itemPath.length <= 0) return 0.f;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:itemPath isDirectory:&isDirectory]) return 0.f;
    CGFloat totalSize = 0.f;
    if (isDirectory) {
        //获得这个文件夹下面的所有子路径(直接\间接子路径),包括子文件夹下面的所有文件及文件夹
        NSArray *subpaths = [[NSFileManager defaultManager] subpathsAtPath:itemPath];
        //遍历所有子路径
        for (NSString *sub in subpaths) {
            //拼成全路径
            NSString *fullSubPath = [itemPath stringByAppendingPathComponent:sub];
            isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:fullSubPath isDirectory:&isDirectory];
            if (!isDirectory) {
                //子路径是个文件
                NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullSubPath error:nil];
                totalSize += [attrs[NSFileSize] intValue];
            }
        }
        totalSize = totalSize/(1024.f*1024.f);//单位M
    } else {
        //获取文件信息
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
        totalSize = [attrs[NSFileSize] floatValue]/(1024.f*1024.f);//单位M
    }
    return totalSize;
}

+ (CGFloat)itemSizeAtURL:(NSURL *)itemURL {
    return [self itemSizeAtPath:[itemURL path]];
}

@end
