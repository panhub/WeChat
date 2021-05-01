//
//  WXSong.h
//  WeChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXLyric.h"

@interface WXSong : NSObject
/*歌曲名*/
@property (nonatomic, copy) NSString *title;
/*专辑名*/
@property (nonatomic, copy) NSString *albumName;
/*艺术家<歌手>*/
@property (nonatomic, copy) NSString *artist;
/*类型*/
@property (nonatomic, copy) NSString *type;
/*插图*/
@property (nonatomic, copy) UIImage *artwork;
/*路径*/
@property (nonatomic, copy) NSString *filePath;
/*歌词*/
@property (nonatomic, copy) NSArray <WXLyric *>*lyrics;

/**
 匹配音乐
 @param completionHandler 结束回调
 */
+ (void)fetchMusicAtResourceWithCompletionHandler:(void(^)(NSArray <WXSong *>*))completionHandler;

/**
 随机获取本地音乐
 @return 音乐模型
 */
+ (instancetype)fetchRandomSong;

/**
 获取指定名称的歌曲
 @param title 指定名称
 @return 歌曲
 */
+ (instancetype)fetchSongWithTitle:(NSString *)title;

@end
