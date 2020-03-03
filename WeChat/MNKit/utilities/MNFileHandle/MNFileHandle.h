//
//  MNFileHandle.h
//  MNKit
//
//  Created by Vincent on 2018/10/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MNFileMP4Name   [MNFileHandle fileNameWithExtension:@"mp4"]
#define MNFileMP3Name   [MNFileHandle fileNameWithExtension:@"mp3"]
#define MNFileM4AName   [MNFileHandle fileNameWithExtension:@"m4a"]
#define MNFileWAVName   [MNFileHandle fileNameWithExtension:@"wav"]
#define MNFileName(extension)   [MNFileHandle fileNameWithExtension:extension]

@interface MNFileHandle : NSObject
/**
 获取文件名(唯一)
 @return 唯一文件名
 */
+ (NSString *)fileName;

/**
 获取文件名(唯一)
 @param extension 文件类型后缀
 @return 唯一文件名
 */
+ (NSString *)fileNameWithExtension:(NSString *)extension;
NSString * MNFileNameWithExtension (NSString *extension);

/**
 往目标路径中写入二进制数据
 @param data 二进制数据
 @param filePath 目标路径
 @param error 错误信息
 @return 是否写入成功
 */
+ (BOOL)writeData:(NSData *)data toFile:(NSString *)filePath error:(NSError **)error;

/**
 往目标路径中写入image
 @param image 图像
 @param filePath 目标路径
 @param error 错误信息
 @return 是否写入成功
 */
+ (BOOL)writeImage:(UIImage *)image toFile:(NSString *)filePath error:(NSError **)error;

/**
 往目标路径写入字符串
 @param text 字符串
 @param filePath 目标路径
 @param error 错误信息
 @return 是否写入成功
 */
+ (BOOL)writeText:(NSString *)text toFile:(NSString *)filePath error:(NSError **)error;

@end

