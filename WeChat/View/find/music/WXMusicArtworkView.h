//
//  WXMusicArtworkView.h
//  WeChat
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//  音乐播放器背景视图

#import <UIKit/UIKit.h>
@class WXSong;

@interface WXMusicArtworkView : UIImageView

/**是否添加效果*/
@property (nonatomic) BOOL allowsAddEffect;

/**动画类型*/
@property (nonatomic, copy) CATransitionType type;

/**动画附属类型*/
@property (nonatomic, copy) CATransitionSubtype subtype;

/**歌曲视图*/
@property (nonatomic, strong) WXSong *song;

@end
