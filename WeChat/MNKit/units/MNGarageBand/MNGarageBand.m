//
//  MNGarageBand.m
//  MNFoundation
//
//  Created by Vicent on 2020/9/1.
//

#import "MNGarageBand.h"
#import "MNAssetExportSession.h"
#import "ExtAudioConverter.h"

@implementation MNGarageBand
+ (void)exportBandFileAsynchronouslyUsingVideoAtPath:(NSString *)videoPath completion:(void(^)(NSString *))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // m4a输出路径
        NSString *m4aPath = [NSString stringWithFormat:@"%@/%@.m4a", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject, [NSNumber numberWithLongLong:NSDate.date.timeIntervalSince1970*1000]];
        // 输出m4a
        MNAssetExportSession *exportSession = MNAssetExportSession.new;
        exportSession.URL = [NSURL fileURLWithPath:videoPath];
        exportSession.outputURL = [NSURL fileURLWithPath:m4aPath];
        exportSession.exportAudioTrack = YES;
        exportSession.exportVideoTrack = NO;
        exportSession.outputFileType = AVFileTypeAppleM4A;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(AVAssetExportSessionStatus status, NSError * _Nullable error) {
            if (status == AVAssetExportSessionStatusCompleted) {
                [self exportBandFileAsynchronouslyUsingM4aAtPath:m4aPath completion:completionHandler];
            } else {
                if (completionHandler) completionHandler(nil);
            }
        }];
    });
}

+ (void)exportBandFileAsynchronouslyUsingM4aAtPath:(NSString *)m4aPath completion:(void(^)(NSString *))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 判断文件是否存在
        if (![NSFileManager.defaultManager fileExistsAtPath:m4aPath]) {
            if (completionHandler) completionHandler(nil);
            return;
        }
        // 拷贝一个band文件
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        cachePath = [cachePath stringByAppendingPathComponent:@"bandfile.band"];
        if (![NSFileManager.defaultManager fileExistsAtPath:cachePath]) {
            NSBundle *resourceBundle = [NSBundle bundleForClass:MNGarageBand.class];
            NSString *bandPath = [resourceBundle pathForResource:@"band" ofType:@"band"];
            if (![NSFileManager.defaultManager copyItemAtPath:bandPath toPath:cachePath error:nil]) {
                if (completionHandler) completionHandler(nil);
                return;
            }
        }
        NSString *aiffPath = [cachePath stringByAppendingFormat:@"/Media/ringtone.aiff"];
        if ([NSFileManager.defaultManager fileExistsAtPath:aiffPath]) [NSFileManager.defaultManager removeItemAtPath:aiffPath error:nil];
        // 把你音频转码为aiff
        ExtAudioConverter *converter = [[ExtAudioConverter alloc] init];
        converter.inputFile = m4aPath;
        converter.outputFile = aiffPath;
        converter.outputFileType = kAudioFileAIFFType;
        if ([converter convert]) {
            if (completionHandler) completionHandler(cachePath);
        } else {
            [NSFileManager.defaultManager removeItemAtPath:aiffPath error:nil];
            if (completionHandler) completionHandler(nil);
        }
    });
}

@end
