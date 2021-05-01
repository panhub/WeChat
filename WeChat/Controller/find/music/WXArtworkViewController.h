//
//  WXArtworkViewController.h
//  WeChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//  音乐播放

#import "MNBaseViewController.h"
@class WXSong;

NS_ASSUME_NONNULL_BEGIN

@interface WXArtworkViewController : MNBaseViewController

/**歌曲*/
@property (nonatomic, strong) WXSong *song;

/**内容区*/
@property (nonatomic) UIEdgeInsets contentInset;

/**播放时间*/
@property (nonatomic) NSTimeInterval playTimeInterval;

/**开始动画*/
- (void)startArtworkAnimation;

/**停止动画*/
- (void)stopArtworkAnimation;

@end

NS_ASSUME_NONNULL_END
