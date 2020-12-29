//
//  WXShakeHistory.h
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//  摇一摇历史

/**
 摇一摇历史类型
 - WXShakeHistoryPerson 人
 - WXShakeHistoryMusic 音乐
 - WXShakeHistoryTV 电视节目
 */
typedef NS_ENUM(NSInteger, WXShakeHistoryType) {
    WXShakeHistoryPerson = 0,
    WXShakeHistoryMusic,
    WXShakeHistoryTV
};

#import <Foundation/Foundation.h>
@class WXUser, WXSong;

@interface WXShakeHistory : NSObject
/**性别*/
@property (nonatomic) WechatGender gender;
/**历史类型*/
@property (nonatomic) WXShakeHistoryType type;
/**缩略图*/
@property (nonatomic, strong, readonly) UIImage *image;
/**缩略图数据*/
@property (nonatomic, copy) NSData *imageData;
/**标题*/
@property (nonatomic, copy) NSString *title;
/**副标题*/
@property (nonatomic, copy) NSString *subtitle;
/**签名*/
@property (nonatomic, copy) NSString *signature;
/**日期*/
@property (nonatomic, copy) NSString *date;
/**扩展用户信息*/
@property (nonatomic, copy) NSData *extend;

/**
 陌生人摇一摇历史模型
 @param user 用户
 @return 摇一摇历史模型
 */
- (instancetype)initWithUser:(WXUser *)user;

/**
 歌曲摇一摇历史模型
 @param song 歌曲
 @return 摇一摇历史模型
 */
- (instancetype)initWithSong:(WXSong *)song;

/**
 电视节目历史模型
 @return 摇一摇历史模型
 */
+ (instancetype)fetchTVHistory;

@end
