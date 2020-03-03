//
//  MNAudioConvert.m
//  MNKit
//
//  Created by Vincent on 2018/7/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAudioConvert.h"
#import "MNFileManager.h"
#import "VoiceConvert.h"
#import "lame.h"

static dispatch_queue_t dispatch_audio_convert_queue (void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

@implementation MNAudioConvert

#pragma mark - WavToMp3

/**
lame的转码压缩
@录制的 AVFormatIDKey 设置成 kAudioFormatLinearPCM, 生成的文件可以是 caf 或者 wav.
@AVNumberOfChannelsKey 必须设置为双声道, 不然转码生成的 MP3 会声音尖锐变声.
@AVSampleRateKey 必须保证和转码设置的相同.
*/

+ (void)convertWavToMp3Sync:(NSString *)wavPath
                   savePath:(NSString *)savePath
                 completion:(MNAudioConvertCallback)completion
{
    if (![self prepareConvert:wavPath toPath:savePath]) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    dispatch_async(dispatch_audio_convert_queue(), ^{
        @try {
            
            int read, write;
            FILE *pcm = fopen([wavPath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
            FILE *mp3 = fopen([savePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE * 2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 11025);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            long curpos;
            BOOL isSkipHeader = NO;
            
            /**判断结束*/
            long untreated = 0;
            BOOL finish = NO;
            
            do {
                /**读取内容*/
                curpos = ftell(pcm);
                long startPos = ftell(pcm);
                fseek(pcm, 0, SEEK_END);
                long endPos = ftell(pcm);
                long length = endPos - startPos;
                fseek(pcm, curpos, SEEK_SET);
                
                if (length > PCM_SIZE*2*sizeof(short int)) {
                    
                    if (!isSkipHeader) {
                        //跳过头文件, 否则会有噪音
                        fseek(pcm, 4*1024, SEEK_CUR);
                        isSkipHeader = YES;
                    }
                    
                    read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    fwrite(mp3_buffer, write, 1, mp3);
                    
                    untreated = 0;
                    
                } else {
                    if (untreated == length) {
                        finish = YES;
                    } else {
                        untreated = length;
                        [NSThread sleepForTimeInterval:.05f];
                    }
                }
            } while (finish);
            
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            /**写入VBR头文件, 否则读取时长不正确*/
            lame_mp3_tags_fid(lame, mp3);
            
            /**释放*/
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
            
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
                if (completion) {
                    completion(nil);
                }
            });
        } @finally {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(savePath);
                });
            }
        }
    });
}

void dispatch_convert_mp3_sync (NSString *wavPath, NSString *savePath, MNAudioConvertCallback callback) {
    [MNAudioConvert convertWavToMp3Sync:wavPath savePath:savePath completion:callback];
}

+ (void)convertWavToMp3:(NSString *)wavPath
               savePath:(NSString *)savePath
             completion:(MNAudioConvertCallback)completion
{
    if (![self prepareConvert:wavPath toPath:savePath]) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    dispatch_async(dispatch_audio_convert_queue(), ^{
        @try {
            int read, write;
            //音频源文件位置
            FILE *pcm = fopen([wavPath cStringUsingEncoding:1], "rb");
            //跳过 PCM header 能保证录音的开头没有噪音
            fseek(pcm, 4*1024, SEEK_CUR);
            //mp3文件位置
            FILE *mp3 = fopen([savePath cStringUsingEncoding:1], "wb+");
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            //初始化 lame
            lame_t lame = lame_init();
            //1为单通道，2双通道
            //默认双通道, 设置单声道可以减少压缩后文件的体积
            lame_set_num_channels(lame, 1);
            lame_set_in_samplerate(lame, 11024);
            lame_set_VBR(lame, vbr_default);
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
            
            //写入VBR头文件, 否则读取时长不正确
            lame_mp3_tags_fid(lame, mp3);
            
            //释放
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
                if (completion) {
                    completion(nil);
                }
            });
        }
        @finally {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(savePath);
                });
            }
        }
    });
}

void dispatch_convert_mp3 (NSString *wavPath, NSString *savePath, MNAudioConvertCallback callback) {
    [MNAudioConvert convertWavToMp3:wavPath savePath:savePath completion:callback];
}

#pragma mark - WavToAmr
+ (BOOL)convertWavToAmr:(NSString *)wavPath savePath:(NSString *)savePath {
    if (![self prepareConvert:wavPath toPath:savePath]) return NO;
    return [VoiceConvert ConvertWavToAmr:wavPath amrSavePath:savePath];
}

+ (void)convertWavToAmr:(NSString *)wavPath
               savePath:(NSString *)savePath
             completion:(MNAudioConvertCallback)completion
{
    dispatch_async(dispatch_audio_convert_queue(), ^{
        BOOL isSucceed = [self convertWavToAmr:wavPath savePath:savePath];
        NSString *filePath = isSucceed ? savePath : nil;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(filePath);
            });
        }
    });
}

#pragma mark - AmrToWav
+ (BOOL)convertAmrToWav:(NSString *)amrPath savePath:(NSString *)savePath {
    if (![self prepareConvert:amrPath toPath:savePath]) return NO;
    return [VoiceConvert ConvertAmrToWav:amrPath wavSavePath:savePath];
}

+ (void)convertAmrToWav:(NSString *)amrPath
               savePath:(NSString *)savePath
             completion:(MNAudioConvertCallback)completion {
    dispatch_async(dispatch_audio_convert_queue(), ^{
        BOOL isSucceed = [self convertAmrToWav:amrPath savePath:savePath];
        NSString *filePath = isSucceed ? savePath : nil;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(filePath);
            });
        }
    });
}

#pragma mark - 判断文件是否存在
+ (BOOL)prepareConvert:(NSString *)filePath toPath:(NSString *)toPath {
    if (filePath.length <= 0 || toPath.length <= 0) return NO;
    return ([[NSFileManager defaultManager] fileExistsAtPath:filePath] && [MNFileManager createFileAtPath:toPath error:nil]);
}

@end
