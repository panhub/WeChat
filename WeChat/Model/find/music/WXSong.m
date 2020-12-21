//
//  WXSong.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXSong.h"

@implementation WXSong
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"未知歌曲";
        self.albumName = @"未知专辑";
        self.artist = @"未知艺术家";
        self.type = @"未知类型";
        self.artwork = [UIImage imageNamed:@"music_artwork_default"];
    }
    return self;
}

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
                if ([value isKindOfClass:NSData.class]) {
                    song.title = [NSString replacingEmptyCharacters:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] withCharacters:@"未知歌曲"];
                } else if ([value isKindOfClass:NSString.class]) {
                    song.title = [NSString replacingEmptyCharacters:value withCharacters:@"未知歌曲"];
                }
            } else if ([key isEqualToString:AVMetadataCommonKeyAlbumName]) {
                if ([value isKindOfClass:NSData.class]) {
                    song.albumName = [NSString replacingEmptyCharacters:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] withCharacters:@"未知专辑"];
                } else if ([value isKindOfClass:NSString.class]) {
                    song.albumName = [NSString replacingEmptyCharacters:value withCharacters:@"未知专辑"];
                }
            } else if ([key isEqualToString:AVMetadataCommonKeyArtist]) {
                if ([value isKindOfClass:NSData.class]) {
                    song.artist = [NSString replacingEmptyCharacters:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] withCharacters:@"未知艺术家"];
                } else if ([value isKindOfClass:NSString.class]) {
                    song.artist = [NSString replacingEmptyCharacters:value withCharacters:@"未知艺术家"];
                }
            } else if ([key isEqualToString:AVMetadataCommonKeyType]) {
                if ([value isKindOfClass:NSData.class]) {
                    song.type = [NSString replacingEmptyCharacters:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] withCharacters:@"未知类型"];
                } else if ([value isKindOfClass:NSString.class]) {
                    song.type = [NSString replacingEmptyCharacters:value withCharacters:@"未知类型"];
                }
            } else if ([key isEqualToString:AVMetadataCommonKeyArtwork]) {
                if ([value isKindOfClass:NSData.class]) {
                    UIImage *image = [UIImage imageWithData:value];
                    if (image) song.artwork = image;
                }
            }
        }
    }
    song.title = [NSString replacingEmptyCharacters:song.title withCharacters:fileName];
    NSString *lyricPath = [WeChatBundle pathForResource:fileName ofType:@"json" inDirectory:@"json"];
    if (![MNFileManager itemExistsAtPath:lyricPath isDirectory:nil]) return song;
    NSError *error;
    NSArray <NSString *>*array = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:lyricPath] options:NSJSONReadingAllowFragments error:&error];
    if ([NSObject isEmptying:array]) return song;
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
