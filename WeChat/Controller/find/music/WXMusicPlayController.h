//
//  WXMusicPlayController.h
//  MNChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//  音乐控制器

#import "MNExtendViewController.h"
@class WXSong;

@interface WXMusicPlayController : MNExtendViewController

/**从哪首歌曲开始*/
@property (nonatomic) NSInteger playIndex;

/**歌曲数组*/
@property (nonatomic, copy) NSArray <WXSong *>*songs;

/**
 歌曲播放控制器实例化
 @param songs 歌曲数组
 @return 歌曲播放
 */
- (instancetype)initWithSongs:(NSArray <WXSong *>*)songs;

/**
 歌曲播放控制器实例化
 @param songs 歌曲数组
 @param playIndex 从哪首歌曲开始
 @return 歌曲播放
 */
- (instancetype)initWithSongs:(NSArray <WXSong *>*)songs atIndex:(NSInteger)playIndex;

@end
