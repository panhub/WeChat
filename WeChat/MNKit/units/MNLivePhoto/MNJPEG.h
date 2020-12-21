//
//  MNJPEG.h
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  为LivePhoto解决JPEG处理方案

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNJPEG : NSObject
/**
 图片二进制流
 */
@property (nonatomic, copy) NSData *imageData;

/**
 依据图片实例化
 @param image 图片
 @return JPEG图片
 */
- (instancetype)initWithImage:(UIImage *)image;
/**
 依据图片二进制流实例化
 @param imageData 图片二进制流
 @return JPEG图片
 */
- (instancetype)initWithData:(NSData *)imageData;
/**
 依据图片路径实例化
 @param filePath 图片路径
 @return JPEG图片
 */
- (instancetype)initWithContentsOfFile:(NSString *)filePath;

/**
 写入文件
 @param path 指定路径
 @param identifier 唯一标识
 @return 是否写入成功
 */
- (BOOL)writeToFile:(NSString *)path withIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
