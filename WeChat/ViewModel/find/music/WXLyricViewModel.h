//
//  WXLyricViewModel.h
//  MNChat
//
//  Created by Vincent on 2020/2/7.
//  Copyright © 2020 Vincent. All rights reserved.
//  歌词视图模型

#import <Foundation/Foundation.h>
#import "WXLyric.h"

UIKIT_EXTERN const CGFloat WXMusicLyricHorMargin;
UIKIT_EXTERN const CGFloat WXMusicLyricVerMargin;

@interface WXLyricViewModel : NSObject

/**歌词*/
@property (nonatomic, strong) WXLyric *lyric;

/**行高*/
@property (nonatomic, readonly) CGFloat rowHeight;

/**内容区域*/
@property (nonatomic, readonly) CGRect contentRect;

/**内容富文本*/
@property (nonatomic, copy, readonly) NSAttributedString *content;

/**单行歌词所占比例*/
@property (nonatomic, readonly) float lineRatio;

/**当前播放进度*/
@property (nonatomic, readonly) float progress;

/**
 依据歌词实例化
 @param lyric 歌词模型
 @return 歌词视图模型
 */
- (instancetype)initWithLyric:(WXLyric *)lyric;

/**更新内容*/
- (void)updateContent;

/**
 更新播放进度
 @param timeInterval 当前播放时间
 */
- (void)updateProgressWithPlayTimeInterval:(NSTimeInterval)timeInterval;

@end
