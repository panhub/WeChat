//
//  WXLyricViewController.h
//  WeChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//  音乐歌词

#import "MNListViewController.h"
@class WXSong;

NS_ASSUME_NONNULL_BEGIN

@interface WXLyricViewController : MNListViewController

/**歌曲*/
@property (nonatomic, strong) WXSong *song;

/**外界指定内容inset<选择器高度>*/
@property (nonatomic) CGFloat contentMinY;

/**外界指定内容最大y值<pageControl的y>*/
@property (nonatomic) CGFloat contentMaxY;

/**播放时间*/
@property (nonatomic) NSTimeInterval playTimeInterval;

@end

NS_ASSUME_NONNULL_END
