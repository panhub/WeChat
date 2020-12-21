//
//  MNGarageBand.h
//  MNFoundation
//
//  Created by Vicent on 2020/9/1.
//  导出库乐队文件

#import <Foundation/Foundation.h>
#if __has_include("MNAssetExportSession.h")
#if __has_include("ExtAudioConverter.h")

NS_ASSUME_NONNULL_BEGIN

@interface MNGarageBand : NSObject

/**
 导出库乐队文件
 @param videoPath 视频文件路径
 @param completionHandler 完成回调
 */
+ (void)exportBandFileAsynchronouslyUsingVideoAtPath:(NSString *)videoPath completion:(void(^_Nullable)(NSString *_Nullable))completionHandler;

/**
 导出库乐队文件
 @param m4aPath m4a文件路径
 @param completionHandler 完成回调
 */
+ (void)exportBandFileAsynchronouslyUsingM4aAtPath:(NSString *)m4aPath completion:(void(^_Nullable)(NSString *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
#endif
#endif
