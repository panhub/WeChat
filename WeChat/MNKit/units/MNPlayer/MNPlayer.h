//
//  MNPlayer.h
//  MNKit
//
//  Created by Vincent on 2018/3/10.
//  Copyright © 2018年 小斯. All rights reserved.
//  播放器

#import <Foundation/Foundation.h>
@class MNPlayer, AVPlayerItem;

typedef NS_ENUM(NSInteger, MNPlayerState) {
    MNPlayerStateUnknown = 0,
    MNPlayerStateFailed,
    MNPlayerStatePlaying,
    MNPlayerStatePause,
    MNPlayerStateFinished
};

@protocol MNPlayerDelegate <NSObject>
@optional
/// 已分析媒体文件, 返回是否播放
- (void)playerDidEndDecode:(MNPlayer *)player;
/// 状态发生改变
- (void)playerDidChangeState:(MNPlayer *)player;
/// 播放进度变化
- (void)playerDidPlayTimeInterval:(MNPlayer *)player;
/// 播放结束
- (void)playerDidPlayToEndTime:(MNPlayer *)player;
/// 缓冲进度变化
- (void)playerDidLoadTimeRanges:(MNPlayer *)player;
/// 缓冲不足
- (void)playerLikelyBufferEmpty:(MNPlayer *)player;
/// 缓冲充裕
- (void)playerLikelyToKeepUp:(MNPlayer *)player;
/// 切换URL
- (void)playerDidChangePlayItem:(MNPlayer *)player;
/// 发生错误
- (void)playerDidPlayFailure:(MNPlayer *)player;
/// 是否播放下一曲
- (BOOL)playerShouldPlayNextItem:(MNPlayer *)player;
/// 解析完成想要开始播放
- (BOOL)playerShouldPlaying:(MNPlayer *)player;
@end

@interface MNPlayer : NSObject
/**视频显示层*/
@property (nonatomic, strong) CALayer *layer;
/**事件代理*/
@property (nonatomic, weak) id<MNPlayerDelegate> delegate;
/**标记自身状态*/
@property (nonatomic, readonly) MNPlayerState state;
/**是否在播放, 内部判断此时状态*/
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
/**错误*/
@property (nonatomic, strong, readonly) NSError *error;
/**当前的URL*/
@property (nonatomic, strong, readonly) NSURL *playURL;
/**获取所有播放链接*/
@property (nonatomic, strong, readonly) NSArray <NSURL *>*playURLs;
/**当前的playerItem <AVPlayerItem>*/
@property (nonatomic, strong, readonly) AVPlayerItem *playItem;
/**当前的播放索引*/
@property (nonatomic, readonly) NSUInteger playIndex;
/**缓冲进度*/
@property (nonatomic, readonly) float buffer;
/**播放进度*/
@property (nonatomic, readonly) float progress;
/**文件时长*/
@property (nonatomic, readonly) NSTimeInterval duration;
/**当前播放时间*/
@property (nonatomic, readonly) NSTimeInterval currentTimeInterval;
/**时间回调*/
@property (nonatomic) CMTime observeTime;
/**播放速度 0.5, 0.67, 0.8, 1.0, 1.25, 1.5, 2.0*/
@property (nonatomic) float rate;
/**音量*/
@property (nonatomic) float volume;
/**是否支持后台播放*/
@property (nonatomic, getter=isPlaybackEnabled) BOOL playbackEnabled;

- (instancetype)initWithURLs:(NSArray <NSURL *>*)URLs;

- (instancetype)initWithURL:(NSURL *)URL;

- (BOOL)containsURL:(NSURL *)item;

- (void)addURL:(NSURL *)URL;

- (void)insertURL:(NSURL *)URL afterURL:(NSURL *)afterURL;

- (void)removeURL:(NSURL *)URL;

- (void)removeAllURLs;

/**切换播放索引*/
- (BOOL)replaceCurrentPlayIndexWithIndex:(NSInteger)playIndex;

/**播放*/
- (void)play;

/**暂停*/
- (void)pause;

/**播放下一曲*/
- (void)playNextItem;

/**播放上一曲*/
- (void)playPreviousItem;

/**
 跳转到指定进度
 @param progress 指定进度 <0 - 1>
 @param completion 结束回调
 */
- (void)seekToProgress:(CGFloat)progress completion:(void(^)(BOOL finished))completion;

/**
 跳转到指定时间
 @param seconds 时间/秒
 @param completion 结束回调
 */
- (void)seekToSeconds:(NSTimeInterval)seconds completion:(void(^)(BOOL finished))completion;

#pragma mark - 播放音效
/**
 播放音效
 @param filePath 音效地址
 @param shake 是否震动
 */
+ (void)playSoundWithFilePath:(NSString *)filePath shake:(BOOL)shake;

/**
 播放音效
 @param soundID 音效id
 @param shake 是否震动
 */
+ (void)playSoundID:(UInt32)soundID shake:(BOOL)shake;

@end
