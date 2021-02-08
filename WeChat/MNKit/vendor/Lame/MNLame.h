//
//  MNLame.h
//  MNKit
//
//  Created by Vicent on 2020/12/24.
//  Copyright © 2020 Vicent. All rights reserved.
//  音频转换 PCM-MP3

#import <Foundation/Foundation.h>

/**
 声道设置
 - MNLameChannelMono: 单声道
 - MNLameChannelStereo: 立体声
 */
typedef NS_ENUM(int, MNLameChannel) {
    MNLameChannelMono = 1,
    MNLameChannelStereo
};

/**
 转换质量
 - MNLameQualityHigh: 高
 - MNLameQualityMedium: 中
 - MNLameQualityLow: 低
 */
typedef NS_ENUM(int, MNLameQuality) {
    MNLameQualityHigh = 2,
    MNLameQualityMedium = 5,
    MNLameQualityLow = 7
};

NS_ASSUME_NONNULL_BEGIN

@interface MNLame : NSObject
/**声道 默认MNLameChannelStereo立体声*/
@property(nonatomic) MNLameChannel channel;
/** 质量 内部算法选择
 * 真正的质量是由比特率决定的, 但这个变量会通过选择昂贵或廉价的算法来影响质量
 * 0质量最好 速度慢, 9质量最差 速度快
 * 推荐以下配置
 * 2 质量很好 速度慢
 * 5 质量好 速度较快
 * 7 质量较好, 速度非常快
 */
@property(nonatomic) MNLameQuality quality;
/**采样率 默认44100*/
@property(nonatomic) int sampleRate;
/**比特压缩比 lame默认11 影响质量*/
@property(nonatomic) int brate;
/**模式(0, 1, 2, 3) 不设置则lame挑选基于压缩比和输入通道*/
@property(nonatomic) int mode;
/**音频文件路径*/
@property(nonatomic, copy, nullable) NSString *filePath;
/**输出路径*/
@property(nonatomic, copy) NSString *outputPath;

/**
 异步输出转换
 @param completionHandler 完成回调
 */
- (void)exportAsynchronouslyWithCompletionHandler:(void(^)(BOOL, NSString *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
