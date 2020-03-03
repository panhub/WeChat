//
//  WXSong.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXSong.h"

@implementation WXSong
+ (instancetype)fetchRandomSong {
    NSArray<NSString *>*paths = [NSBundle pathsForResourcesOfType:@"mp3" inDirectory:[[WeChatBundle resourcePath] stringByAppendingPathComponent:@"music"]];
    return [WXSong songWithFileAtPath:paths.randomObject];
}

+ (instancetype)fetchSongWithTitle:(NSString *)title {
    if (title.length <= 0) return nil;
    NSArray<NSString *>*paths = [NSBundle pathsForResourcesOfType:@"mp3" inDirectory:[[WeChatBundle resourcePath] stringByAppendingPathComponent:@"music"]];
    __block NSString *path;
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj.lastPathComponent stringByDeletingPathExtension] isEqualToString:title]) {
            path = obj;
            *stop = YES;
        }
    }];
    if (path.length <= 0) return nil;
    return [WXSong songWithFileAtPath:path];
}

+ (void)fetchMusicAtResourceWithCompletionHandler:(void(^)(NSArray <WXSong *>*))completionHandler {
    dispatch_async(dispatch_get_high_queue(), ^{
        NSArray<NSString *>*paths = [NSBundle pathsForResourcesOfType:@"mp3" inDirectory:[[WeChatBundle resourcePath] stringByAppendingPathComponent:@"music"]];
        NSMutableArray<WXSong *>*modelArray = @[].mutableCopy;
        [paths.scrambledArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![MNFileManager itemExistsAtPath:obj isDirectory:nil]) return;
            [modelArray addObject:[WXSong songWithFileAtPath:obj]];
        }];
        dispatch_async_main(^{
            if (completionHandler) completionHandler(modelArray.copy);
        });
    });
}

+ (instancetype)songWithFileAtPath:(NSString *)filePath {
    NSString *fileName = [filePath.lastPathComponent stringByDeletingPathExtension];
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSArray <AVMetadataFormat>*formats = [mp3Asset availableMetadataFormats];
    WXSong *song = WXSong.new;
    song.filePath = filePath;
    for (AVMetadataFormat format in formats) {
        NSArray <AVMetadataItem *>*metadataItems = [mp3Asset metadataForFormat:format];
        if (metadataItems.count <= 0) continue;
        for (AVMetadataItem *item in metadataItems) {
            id value = item.value;
            AVMetadataKey key = item.commonKey;
            if ([key isEqualToString:AVMetadataCommonKeyTitle]) {
                song.title = [NSString replacingBlankCharacter:value withCharacter:@"未知歌曲"];
            } else if ([key isEqualToString:AVMetadataCommonKeyAlbumName]) {
                song.albumName = [NSString replacingBlankCharacter:value withCharacter:@"未知专辑"];
            } else if ([key isEqualToString:AVMetadataCommonKeyArtist]) {
                song.artist = [NSString replacingBlankCharacter:value withCharacter:@"未知艺术家"];
            } else if ([key isEqualToString:AVMetadataCommonKeyType]) {
                song.type = [NSString replacingBlankCharacter:value withCharacter:@"未知类型"];
            } else if ([key isEqualToString:AVMetadataCommonKeyArtwork]) {
                if (value) {
                    song.artwork = [UIImage imageWithData:kTransform(NSData *, value)];
                } else {
                    song.artwork = [UIImage imageNamed:@"music_artwork_default"];
                }
            }
        }
    }
    song.title = [NSString replacingBlankCharacter:song.title withCharacter:fileName];
    NSString *lyricPath = [WeChatBundle pathForResource:fileName ofType:@"json" inDirectory:@"json"];
    if (![MNFileManager itemExistsAtPath:lyricPath isDirectory:nil]) return song;
    NSError *error;
    NSArray <NSString *>*array = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:lyricPath] options:NSJSONReadingAllowFragments error:&error];
    if ([NSObject isEmpty:array]) return song;
    WXLyric *prevLyric;
    NSMutableArray <WXLyric *>*lyrics = @[].mutableCopy;
    for (NSString *string in array) {
        if ([string containsString:@"ti"] || [string containsString:@"ar"]) continue;
        NSRange begin = [string rangeOfString:@"["];
        NSRange end = [string rangeOfString:@"]"];
        if (begin.location == NSNotFound || end.location == NSNotFound) continue;
        WXLyric *lyric = WXLyric.new;
        NSString *content = [string substringFromIndex:NSMaxRange(end)];
        if ((song.title.length && [content containsString:song.title]) || (song.artist.length && [content containsString:song.artist])) continue;
        lyric.content = content;
        NSString *time = [string substringWithRange:NSMakeRange(NSMaxRange(begin), end.location - NSMaxRange(begin))];
        NSArray <NSString *>*components = [time componentsSeparatedByString:@":"];
        lyric.begin = components.firstObject.intValue*60.f + components.lastObject.floatValue;
        lyric.end = lyric.begin + 2.f; // 避免最后一句end无值
        if (prevLyric) prevLyric.end = lyric.begin - .1f;
        [lyrics addObject:lyric];
        prevLyric = lyric;
    }
    song.lyrics = lyrics.copy;
    return song;
}

@end
