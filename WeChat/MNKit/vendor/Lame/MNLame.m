//
//  MNLame.m
//  MNKit
//
//  Created by Vicent on 2020/12/24.
//  Copyright © 2020 Vicent. All rights reserved.
//

#import "MNLame.h"
#import "lame.h"
#import <stdio.h>

@implementation MNLame
- (instancetype)init {
    if (self = [super init]) {
        self.mode = -1;
        self.brate = 11;
        self.sampleRate = 44100;
        self.channel = MNLameChannelStereo;
        self.quality = MNLameQualityMedium;
    }
    return self;
}

- (void)exportAsynchronouslyWithCompletionHandler:(void(^)(BOOL, NSString *))completionHandler {
    NSString *filePath = self.filePath;
    NSString *outputPath = self.outputPath;
    int sampleRate = self.sampleRate;
    MNLameQuality quality = self.quality;
    MNLameChannel channel = self.channel;
    int brate = self.brate;
    int mode = self.mode;
    if (!outputPath) {
        outputPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/%@.mp3", [NSNumber numberWithInteger:NSDate.date.timeIntervalSince1970*1000].stringValue];
    }
    if (![NSFileManager.defaultManager fileExistsAtPath:filePath] || ![NSFileManager.defaultManager createFileAtPath:outputPath contents:nil attributes:nil]) {
        if (completionHandler) completionHandler(NO, nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            int read, write;
            //音频源文件位置
            FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");
            //跳过 PCM header 能保证录音的开头没有噪音
            fseek(pcm, 4*1024, SEEK_CUR);
            //mp3文件位置
            FILE *mp3 = fopen([outputPath cStringUsingEncoding:1], "wb+");
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            //初始化 lame
            lame_t lame = lame_init();
            // 1为单通道，2双通道 默认双通道, 设置单声道可以减少压缩后文件的体积
            lame_set_num_channels(lame, channel);
            // 采样率
            lame_set_in_samplerate(lame, sampleRate);
            // 比特压缩比
            lame_set_brate(lame, brate);
            // 模式 不设置则lame挑选基于压缩比和输入通道
            if (mode >= 0) lame_set_mode(lame, mode);
            // 质量
            lame_set_quality(lame, quality);
            // 码率模式 VBR动态码率  CBR恒定码率
            // vbr_off CBR, vbr_abr ABR, vbr_mtrh VBR
            lame_set_VBR(lame, vbr_default);
            // 根据设置好的参数建立编码器
            lame_init_params(lame);
            
            //反复读取
            do {
                read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0) {
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                } else {
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                }
                fwrite(mp3_buffer, write, 1, mp3);
            } while (read != 0);
            
            // 写入VBR头文件, 否则读取时长不正确
            // 将VBR/INFO tags封装到一个MP3 Frame中, 写到文件开头
            // 如果输出流没有办法回溯, 那么必须在第3步设置lame_set_bWriteVbrTag(gfp, 0)
            // 这里调用lame_mp3_tags_fid(lame_global_flags *, FILE*)将fid参数＝NULL, 这样的话那个开头的信息帧的所有字节都是0
            lame_mp3_tags_fid(lame, mp3);
            
            // 销毁编码器, 释放资源
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
            if (completionHandler) {
                completionHandler(NO, nil);
            }
        }
        @finally {
            if (completionHandler) {
                completionHandler(YES, outputPath);
            }
        }
    });
}

@end
