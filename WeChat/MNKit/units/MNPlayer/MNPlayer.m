//
//  MNPlayer.m
//  MNKit
//
//  Created by Vincent on 2018/3/10.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>

@interface MNPlayer()
/**监听者*/
@property (nonatomic, weak) id observer;
/**播放状态*/
@property (nonatomic) MNPlayerState state;
/**当前播放索引*/
@property (nonatomic) NSUInteger playIndex;
/**播放器*/
@property (nonatomic, strong) AVPlayer *player;
/**标记应该播放*/
@property (nonatomic, getter=isShouldPlaying) BOOL shouldPlaying;
/**待播数组*/
@property (nonatomic, strong) NSMutableArray <NSURL *>*URLs;
/**播放缓存*/
@property (nonatomic, strong) NSMutableDictionary <NSString *, AVPlayerItem *>*caches;
@end

#define AVPlayItemStatusKeyPath             @"status"
#define AVPlayItemLoadedKeyPath           @"loadedTimeRanges"
#define AVPlayItemEmptyKeyPath             @"playbackBufferEmpty"
#define AVPlayItemKeepUpKeyPath           @"playbackLikelyToKeepUp"

const NSTimeInterval MNPlayItemTimeErrorKey = -1.f;

@implementation MNPlayer
- (instancetype)initWithURLs:(NSArray <NSURL *>*)URLs {
    if (self = [self init]) {
        [self.URLs addObjectsFromArray:URLs];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    if (URL) {
        return [self initWithURLs:@[URL]];
    }
    return [self init];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
    }
    return self;
}

- (void)initialized {
    _playIndex = 0;
    _state = MNPlayerStateUnknown;
    _URLs = [NSMutableArray arrayWithCapacity:1];
    _caches = [NSMutableDictionary dictionaryWithCapacity:1];
    /*
     AVPlayer存在于AVFoundation中,它更加接近于底层,所以灵活性也更强,AVPlayer本身并不能显示视频,而且它也不像MPMoviePlayerController有一个view属性.如果AVPlayer要显示必须创建一个播放器层AVPlayerLayer用于展示,播放器层继承于CALayer,有了AVPlayerLayer之添加到控制器视图的layer中即可。要使用AVPlayer首先了解一下几个常用的类和它的属性/方法(源自网络);
     AVAsset: 主要用于获取多媒体信息，是一个抽象类，不能直接使用
     AVURLAsset: AVAsset的子类，可以根据一个URL路径创建一个包含媒体信息的AVURLAsset对象。
     AVPlayerItem: 一个媒体资源管理对象，管理者视音频的一些基本信息和状态，一个AVPlayerItem对应着一个视音频资源。
     replaceCurrentItemWithPlayerItem: 替换AVPlayer的当前Item.
     play: 播放媒体.
     pause: 暂停.
     seekToTime:completionHandler: 跳转, 调整播放进度.
     ***AVPlayerItem***
     AVPlayerItem相当于一款说明书, 为AVPlayer解释着音频的相关信息
     每一个AVPlayer对象, 都有一个自己的AVPlayerItem属性, 名字叫做:currentItem, 我们可以通过
     replaceCurrentItemWithPlayerItem: 方法来替换当前的Item, 将准备好的Item, 交给Player.
     这个过程我们使用观察者模式模式来监视AVPlayerItem的准备情况. 一旦准备完毕, 会修改自身的status属性为AVPlayerItemStatusReadyToPlay枚举值, 一旦观察到这种状态, 我们就开始真正的播放.
     ***play和pause***
     AVPlayer的对象成员变量中没有来标识当前播放状态的,所以不可能直接的获得当前AVPlayer正在播放中或者暂停了;
     通常情况下, 我们通过AVPlayer的一个rate(播放速率)来间接得到播放状态, rate==0则暂停, 不为0则正在播放中.
     AVPlayer并没有直接提供下一曲和上一曲的的功能, 但是我们可以通过上面的replaceCurrentItemWithPlayerItem:方法, 将AVPlayer对象的Item替换掉, 之后让它播放, 就可以达到这个效果.
     */
    _player = [AVPlayer new];
    /**添加周期性监听*/
    self.observeTime = CMTimeMake(1, 1);
    /**播放结束*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    /**中断*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionInterruptionNotification:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    /**耳机*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    /**提示音*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionSilenceSecondaryAudioHintNotification:)
                                                 name:AVAudioSessionSilenceSecondaryAudioHintNotification
                                               object:nil];
}

#pragma mark - 资源控制
- (BOOL)containsURL:(NSURL *)URL {
    __block BOOL exists = NO;
    [self.URLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (URL.isFileURL ? [obj.path isEqualToString:URL.path] : [obj.absoluteString isEqualToString:URL.absoluteString]) {
            exists = YES;
            *stop = YES;
        }
    }];
    return exists;
}

- (void)addURL:(NSURL *)URL {
    [self insertURL:URL afterURL:nil];
}

- (void)insertURL:(NSURL *)URL afterURL:(NSURL *)afterURL {
    if (!URL) return;
    if (afterURL) {
        NSURL *U = self.URLs.count > _playIndex ? self.URLs[_playIndex] : nil;
        __block NSInteger index = self.URLs.count - 1;
        [self.URLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (afterURL.isFileURL ? [obj.path isEqualToString:afterURL.path] : [obj.absoluteString isEqualToString:afterURL.absoluteString]) {
                index = idx;
                *stop = YES;
            }
        }];
        index ++;
        [self.URLs insertObject:URL atIndex:index];
        if (U) _playIndex = [self.URLs indexOfObject:U];
    } else {
        [self.URLs addObject:URL];
    }
}

- (void)removeURL:(NSURL *)URL {
    if (!URL) return;
    NSURL *currentURL = self.URLs.count > _playIndex ? self.URLs[_playIndex] : nil;
    __block NSURL *U;
    __block NSInteger index = 0;
    [self.URLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (URL.isFileURL ? [obj.path isEqualToString:URL.path] : [obj.absoluteString isEqualToString:URL.absoluteString]) {
            U = obj;
            index = idx;
            *stop = YES;
        }
    }];
    if (U) {
        if (index == _playIndex) return;
        [self.URLs removeObject:U];
        [self removePlayerItemForKey:U];
    }
    if (currentURL) _playIndex = [self.URLs indexOfObject:currentURL];
}

- (void)removeAllURLs {
    if (self.URLs.count <= 0) return;
    [self replaceCurrentItemWithNil];
    [self.caches removeAllObjects];
    [self.URLs removeAllObjects];
    self.playIndex = 0;
    self.state = MNPlayerStateUnknown;
}

- (BOOL)replaceCurrentPlayIndexWithIndex:(NSInteger)playIndex {
    if (playIndex >= self.URLs.count) return NO;
    [self replaceCurrentItemWithNil];
    self.playIndex = playIndex;
    self.state = MNPlayerStateUnknown;
    return YES;
}

- (void)replaceCurrentItemWithNil {
    if (!self.player.currentItem) return;
    if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) [self.player pause];
    [self removeObserverWithPlayerItem:self.player.currentItem];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.state = MNPlayerStateUnknown;
    if ([self.delegate respondsToSelector:@selector(playerDidPlayTimeInterval:)]) {
        [self.delegate playerDidPlayTimeInterval:self];
    }
}

#pragma mark - 播放/暂停
- (void)prepareToPlay {
    if (self.URLs.count <= self.playIndex) return;
    /// 先移除旧PlayerItem
    [self replaceCurrentItemWithNil];
    /// 获取当前播放源, 建立异步链接
    @synchronized (self) {
        NSURL *URL = self.URLs[self.playIndex];
        AVPlayerItem *playerItem = [self playerItemForURL:URL];
        [self addObserverWithPlayerItem:playerItem];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
    if ([self.delegate respondsToSelector:@selector(playerDidChangePlayItem:)]) {
        [self.delegate playerDidChangePlayItem:self];
    }
}

- (void)play {
    if ([self makePlaySessionActive] == NO) {
        [self playerDidInterruptionWithMessage:@"设置会话类型失败"];
        return;
    }
    AVPlayerItem *playerItem = _player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        if (self.progress >= 1.f) {
            __weak typeof(self) weakself = self;
            [self seekToProgress:0.f completion:^(BOOL finished) {
                if (finished) {
                    [weakself.player play];
                    weakself.state = MNPlayerStatePlaying;
                }
            }];
        } else {
            [_player play];
            self.state = MNPlayerStatePlaying;
        }
    } else {
        [self prepareToPlay];
    }
}

- (void)pause {
    if (_state == MNPlayerStatePlaying && _player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [_player pause];
        self.state = MNPlayerStatePause;
    }
}

- (void)playNextItem {
    if (self.playIndex > (self.URLs.count - 2)) return;
    self.playIndex ++;
    [self prepareToPlay];
}

- (void)playPreviousItem {
    if (self.URLs.count <= 1 || self.playIndex <= 0) return;
    self.playIndex --;
    [self prepareToPlay];
}

#pragma mark - 播放结束事件
- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    AVPlayerItem *playerItem = (AVPlayerItem *)(notification.object);
    if (playerItem != _player.currentItem) return;
    BOOL playNext = NO;
    if ([self.delegate respondsToSelector:@selector(playerShouldPlayNextItem:)]) {
        playNext = [self.delegate playerShouldPlayNextItem:self];
    }
    if (playNext) {
        // 进度调整为开始部分, 避免播放上一曲时直接就是结束位置
        [self seekToProgress:0.f completion:nil];
        if (self.playIndex < (self.URLs.count - 1)) {
            [self playNextItem];
        } else {
            __weak typeof(self) weakself = self;
            [self seekToProgress:0.f completion:^(BOOL finished) {
                [weakself play];
            }];
        }
    } else {
        self.state = MNPlayerStateFinished;
        if ([self.delegate respondsToSelector:@selector(playerDidPlayToEndTime:)]) {
            [self.delegate playerDidPlayToEndTime:self];
        }
    }
}

#pragma mark - PlayerItem
- (void)addObserverWithPlayerItem:(AVPlayerItem *)item {
    [item safelyAddObserver:self
                 forKeyPath:AVPlayItemStatusKeyPath
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    [item safelyAddObserver:self
                 forKeyPath:AVPlayItemLoadedKeyPath
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    [item safelyAddObserver:self
                 forKeyPath:AVPlayItemEmptyKeyPath
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    [item safelyAddObserver:self
                 forKeyPath:AVPlayItemKeepUpKeyPath
                    options:NSKeyValueObservingOptionNew
                    context:nil];
}

- (void)removeObserverWithPlayerItem:(AVPlayerItem *)item {
    if (!item) return;
    [item safelyRemoveObserver:self forKeyPath:AVPlayItemStatusKeyPath];
    [item safelyRemoveObserver:self forKeyPath:AVPlayItemLoadedKeyPath];
    [item safelyRemoveObserver:self forKeyPath:AVPlayItemEmptyKeyPath];
    [item safelyRemoveObserver:self forKeyPath:AVPlayItemKeepUpKeyPath];
}

- (void)cancelLoadingWithPlayerItem:(AVPlayerItem *)item {
    [item cancelPendingSeeks];
    [item.asset cancelLoading];
}

#pragma mark - 跳转到指定位置播放
- (void)seekToProgress:(CGFloat)progress completion:(void(^)(BOOL finished))completion {
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status != AVPlayerStatusReadyToPlay) {
        if (completion) completion(NO);
        return;
    }
    progress = MIN(MAX(progress, 0.f), 1.f);
    CMTime time = playerItem.duration;
    time.value = time.value*progress;
    if (_state == MNPlayerStatePause && progress >= .99f) {
        _state = MNPlayerStateFinished;
    } else if (_state == MNPlayerStateFinished && progress < .99f) {
        _state = MNPlayerStatePause;
    }
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completion];
}

- (void)seekToSeconds:(NSTimeInterval)seconds completion:(void(^)(BOOL finished))completion {
    AVPlayerItem *playerItem = _player.currentItem;
    if (playerItem.status != AVPlayerStatusReadyToPlay) {
        if (completion) completion(NO);
        return;
    }
    CMTime time = playerItem.duration;
    CMTimeValue value = time.value;
    time.value = MAX(1, MIN(value, (CMTimeValue)(time.timescale*seconds)));
    if (_state == MNPlayerStatePause && llabs(time.value - value) <= 5) {
        _state = MNPlayerStateFinished;
    } else if (_state == MNPlayerStateFinished && llabs(time.value - value) > 5) {
        _state = MNPlayerStatePause;
    }
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completion];
}

#pragma mark - 错误信息回调
- (void)playerDidInterruptionWithMessage:(NSString *)message {
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    [userInfo setObject:message forKey:NSLocalizedDescriptionKey];
    if (_player.currentItem.error) [userInfo setObject:_player.currentItem.error forKey:NSUnderlyingErrorKey];
    self->_error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorDecodeFailed userInfo:userInfo.copy];
    self.state = MNPlayerStateFailed;
    if ([self.delegate respondsToSelector:@selector(playerDidPlayFailure:)]) [self.delegate playerDidPlayFailure:self];
}

#pragma mark - Observe Value
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:AVPlayItemStatusKeyPath]) {
        AVPlayerItemStatus status = [change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                if (_state != MNPlayerStateUnknown) return;
                if ([self.delegate respondsToSelector:@selector(playerDidEndDecode:)]) {
                    [self.delegate playerDidEndDecode:self];
                }
                BOOL play = YES;
                if ([self.delegate respondsToSelector:@selector(playerShouldPlaying:)]) {
                    play = [self.delegate playerShouldPlaying:self];
                }
                if (play) {
                    [self play];
                } else {
                    [self pause];
                }
            } break;
            case AVPlayerItemStatusUnknown:
            {
                [_player pause];
                [self playerDidInterruptionWithMessage:@"发生未知错误"];
            } break;
            case AVPlayerItemStatusFailed:
            {
                [_player pause];
                [self playerDidInterruptionWithMessage:@"解析媒体文件失败"];
            } break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:AVPlayItemLoadedKeyPath]) {
        /// 缓存状态
        if ([self.delegate respondsToSelector:@selector(playerDidLoadTimeRanges:)]) {
            [self.delegate playerDidLoadTimeRanges:self];
        }
    } else if ([keyPath isEqualToString:AVPlayItemEmptyKeyPath]) {
        /// 缓冲不足
        if ([self.delegate respondsToSelector:@selector(playerLikelyBufferEmpty:)]) {
            [self.delegate playerLikelyBufferEmpty:self];
        }
    } else if ([keyPath isEqualToString:AVPlayItemKeepUpKeyPath]) {
        /// 缓冲够了 播放
        if ([self.delegate respondsToSelector:@selector(playerLikelyToKeepUp:)]) {
            [self.delegate playerLikelyToKeepUp:self];
        }
    }
}

#pragma mark - Notification
/// 中断事件
- (void)sessionInterruptionNotification:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [[notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    AVAudioSessionInterruptionOptions option = [[notification.userInfo objectForKey:AVAudioSessionInterruptionOptionKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        // 中断开始
        if (self.state == MNPlayerStatePlaying) {
            self.shouldPlaying = YES;
            [self pause];
        }
    } else if (option == AVAudioSessionInterruptionOptionShouldResume && self.state >= MNPlayerStatePause && self.isShouldPlaying) {
        // 中断结束并建议播放
        self.shouldPlaying = NO;
        [self play];
    }
}

/// 耳机通知
- (void)sessionRouteChangeNotification:(NSNotification *)notification {
    AVAudioSessionRouteChangeReason reason = [[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        if ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            if (self.state == MNPlayerStatePlaying) {
                [self pause];
            } else if (self.isShouldPlaying) {
                self.shouldPlaying = NO;
            }
        }
    } else if (reason == AVAudioSessionRouteChangeReasonCategoryChange) {
        AVAudioSessionCategory sessionCategory = AVAudioSession.sharedInstance.category;
        if (![sessionCategory isEqualToString:AVAudioSessionCategoryPlayback] && ![sessionCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord] && ![sessionCategory isEqualToString:AVAudioSessionCategoryAmbient]) {
            if (self.state == MNPlayerStatePlaying) {
                [self pause];
            } else if (self.isShouldPlaying) {
                self.shouldPlaying = NO;
            }
        }
    } else if (reason == AVAudioSessionRouteChangeReasonOverride || reason == AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory || reason == AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory) {
        if (self.state == MNPlayerStatePlaying) {
            [self pause];
        } else if (self.isShouldPlaying) {
            self.shouldPlaying = NO;
        }
    } else if (reason == AVAudioSessionRouteChangeReasonWakeFromSleep) {
        if (self.state >= MNPlayerStatePause && self.isShouldPlaying) {
            self.shouldPlaying = NO;
            [self play];
        }
    }
}

/// 提示音
- (void)sessionSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
    AVAudioSessionSilenceSecondaryAudioHintType hintType = [[notification.userInfo objectForKey:AVAudioSessionSilenceSecondaryAudioHintTypeKey] integerValue];
    if (hintType == AVAudioSessionSilenceSecondaryAudioHintTypeBegin) {
        /// 提示音响起
        if (self.state == MNPlayerStatePlaying) {
            self.shouldPlaying = YES;
            [self pause];
        }
    } else if (self.state >= MNPlayerStatePause && self.isShouldPlaying) {
        /// 提示音结束
        self.shouldPlaying = NO;
        [self play];
    }
}

#pragma mark - Cache
- (AVPlayerItem *)playerItemForURL:(NSURL *)URL {
    NSString *path = URL.path;
    AVPlayerItem *playerItem = [self.caches objectForKey:path];
    if (!playerItem) {
        playerItem = [[AVPlayerItem alloc] initWithURL:URL];
        /// 改变播放速率支持
        for (AVPlayerItemTrack *track in playerItem.tracks) {
            if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio]) {
                track.enabled = YES;
            }
        }
        if (playerItem && path.length > 0) [self.caches setObject:playerItem forKey:path];
    }
    return playerItem;
}

- (void)removePlayerItemForKey:(NSURL *)URL {
    [self.caches removeObjectForKey:URL.path];
}

- (void)removeAllPlayerItems {
    [self.caches removeAllObjects];
}

#pragma mark - Setter
- (void)setRate:(float)rate {
    _player.rate = rate;
}

- (void)setVolume:(float)volume {
    _player.volume = volume;
}

- (void)setState:(MNPlayerState)state {
    if (_state == state) return;
    _state = state;
    if ([self.delegate respondsToSelector:@selector(playerDidChangeState:)]) {
        [self.delegate playerDidChangeState:self];
    }
}

- (void)setLayer:(CALayer *)layer {
    if (![layer isKindOfClass:NSClassFromString(@"AVPlayerLayer")]) return;
    ((AVPlayerLayer *)layer).videoGravity = AVLayerVideoGravityResizeAspect;
    ((AVPlayerLayer *)_layer).player = nil;
    ((AVPlayerLayer *)layer).player = _player;
    _layer = layer;
}

- (void)setObserveTime:(CMTime)observeTime {
    if (_observer) [_player removeTimeObserver:_observer];
    __weak typeof(self)weakself = self;
    _observer = [_player addPeriodicTimeObserverForInterval:observeTime queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ([weakself.delegate respondsToSelector:@selector(playerDidPlayTimeInterval:)]) {
            [weakself.delegate playerDidPlayTimeInterval:weakself];
        }
    }];
}

- (void)setPlayURLs:(NSArray<NSURL *> *)playURLs {
    [self removeAllURLs];
    if (playURLs) [self.URLs addObjectsFromArray:playURLs.copy];
}

#pragma mark - 设置会话
- (BOOL)makePlaySessionActive {
    //设置会话类型,关闭其他声音,可后台播放(主要是音频)(注意工程选项卡 Capabilities - Background Modes 需要打开)
    /** 设置会话类型
     后台播放:
     1. AVAudioSessionModeMoviePlayback
     2.在plist 添加字段
     key : Required background modes  <NSArray>
     value : App plays audio or streams audio/video using AirPlay <NSString>
     */
    AVAudioSessionCategory category = self.isPlaybackEnabled ? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryAmbient;
    NSError *error;
    if (![[[AVAudioSession sharedInstance] category] isEqualToString:category]) {
        [[AVAudioSession sharedInstance] setCategory:category error:&error];
        if (error) return NO;
    }
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    return error == nil;
}

#pragma mark - Getter
- (BOOL)isPlaying {
    return _state == MNPlayerStatePlaying;
}

- (float)rate {
    return _player.rate;
}

- (float)volume {
    return _player.volume;
}

- (NSArray <NSURL *>*)playURLs {
    return self.URLs.copy;
}

- (NSURL *)currentPlayURL {
    if (self.URLs.count <= self.playIndex) return nil;
    return [self.URLs objectAtIndex:self.playIndex];
}

- (AVPlayerItem *)currentPlayItem {
    return self.player.currentItem;
}

- (float)buffer {
    AVPlayerItem *currentItem = self.player.currentItem;
    NSArray *ranges = currentItem.loadedTimeRanges;
    if (ranges.count <= 0) return 0.f;
    CMTimeRange range = [[ranges firstObject] CMTimeRangeValue];
    Float64 start = CMTimeGetSeconds(range.start);
    Float64 length = CMTimeGetSeconds(range.duration);
    NSTimeInterval total = start + length;
    Float64 duration = CMTimeGetSeconds(currentItem.duration);
    Float64 progress = total/duration;
    return MIN(1.f, MAX(progress, 0.f));
}

- (NSTimeInterval)duration {
    AVPlayerItem *currentItem = self.player.currentItem;
    if (!currentItem || currentItem.status != AVPlayerItemStatusReadyToPlay) return 0.f;
    return CMTimeGetSeconds(currentItem.duration);
}

- (float)progress {
    AVPlayerItem *currentItem = self.player.currentItem;
    if (!currentItem || currentItem.status != AVPlayerItemStatusReadyToPlay) return 0.f;
    if (self.state == MNPlayerStateFinished) return 1.f;
    Float64 duration = CMTimeGetSeconds(currentItem.duration);
    Float64 current = CMTimeGetSeconds(currentItem.currentTime);
    CGFloat progress = current/duration;
    if (isnan(progress)) return 0.f;
    return MAX(0.f, MIN(progress, 1.f));
}

- (NSTimeInterval)currentTimeInterval {
    AVPlayerItem *currentItem = self.player.currentItem;
    if (!currentItem || currentItem.status != AVPlayerItemStatusReadyToPlay) return 0.f;
    return CMTimeGetSeconds(currentItem.currentTime);
}

#pragma mark - 播放音效
+ (void)playSoundWithFilePath:(NSString *)filePath shake:(BOOL)shake {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return;
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(URL), &soundID);
    [self playSoundID:soundID shake:shake];
}

+ (void)playSoundID:(UInt32)soundID shake:(BOOL)shake {
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, MNPlaySoundCompleteHandler, NULL);
    if (shake) {
        AudioServicesPlayAlertSound(soundID);
    } else {
        AudioServicesPlaySystemSound(soundID);
    }
}

static void MNPlaySoundCompleteHandler(SystemSoundID soundID,void *clientData){
    NSLog(@"播放音效结束:%@", @(soundID));
}

#pragma mark - dealloc
- (void)dealloc {
    _layer = nil;
    _delegate = nil;
    [self removeAllURLs];
    if (_observer) [_player removeTimeObserver:_observer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
