//
//  MNFileHandle.m
//  MNKit
//
//  Created by Vincent on 2018/10/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNFileHandle.h"
#import <CoreFoundation/CFUUID.h>
#import <CommonCrypto/CommonDigest.h>
#import "MNFileManager.h"

@implementation MNFileHandle
#pragma mark - 获取唯一文件名
+ (NSString *)fileName {
    //当前时空UUID
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    //拼接文件名
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@", uuidString, [NSDate shortTimestamps], @(__COUNTER__)];
    return fileName.md5String32;
}

#pragma mark - 获取唯一文件名(类型)
+ (NSString *)fileNameWithExtension:(NSString *)extension {
    NSString *fileName = [self fileName];
    if (extension.length <= 0) return fileName;
    extension = [extension stringByReplacingOccurrencesOfString:@" " withString:@""];
    extension = [extension stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [fileName stringByAppendingPathExtension:extension];
}

inline NSString * MNFileNameWithExtension (NSString *extension) {
    return [MNFileHandle fileNameWithExtension:extension];
}

#pragma mark - WriteData
+ (BOOL)writeData:(NSData *)data toFile:(NSString *)filePath error:(NSError **)error {
    if (data.length <= 0 || filePath.length <= 0) return NO;
    if ([MNFileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] error:nil]) {
        return [data writeToFile:filePath options:NSDataWritingAtomic error:error];
    }
    return NO;
}

#pragma mark - WriteImage
+ (BOOL)writeImage:(UIImage *)image toFile:(NSString *)filePath error:(NSError **)error {
    return [self writeData:UIImagePNGRepresentation(image) toFile:filePath error:error];
}

#pragma mark - WriteText
+ (BOOL)writeText:(NSString *)text toFile:(NSString *)filePath error:(NSError **)error {
    return [self writeData:[text dataUsingEncoding:NSUTF8StringEncoding] toFile:filePath error:error];
}

@end
