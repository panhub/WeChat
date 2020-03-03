//
//  MNEmojiManager.h
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情资源管理者

#import <Foundation/Foundation.h>
#import "MNEmoji.h"
#import "MNEmojiPacket.h"
#import "MNEmojiAttachment.h"

FOUNDATION_EXTERN NSString * const MNEmojiFavoritesIdentifier;
FOUNDATION_EXTERN NSRegularExpression * MNEmojiRegularExpression (void);

@interface MNEmojiManager : NSObject
/**
收藏夹
*/
@property (nonatomic, readonly) MNEmojiPacket *favoritesPacket;
/**
 所有表情包
 */
@property (nonatomic, readonly, strong) NSMutableArray<MNEmojiPacket *>*packets;
/**
 用到的表情缓存
 */
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *, MNEmoji *>*emojiCache;

/**
 唯一实例化方式
 @return 表情管理者
 */
+ (MNEmojiManager *)defaultManager;

/**
 获取表情
 @param desc 表情文字描述
 @return 表情对象
 */
- (MNEmoji *)emojiForDesc:(NSString *)desc;

/**
 利用缓存获取表情
 @param desc 表情文字描述
 @return 表情对象
 */
- (MNEmoji *)emojiForDescUseCache:(NSString *)desc;

/**
 向收藏夹中加入表情
 @param emojiImage 表情图片
 @param desc 表情描述
 @return 是否添加成功
 */
- (BOOL)insertEmojiToFavorites:(UIImage *)emojiImage desc:(NSString *)desc;

/**
 匹配字符串中表情部分, 制作附件
 @param string 字符串
 @return 表情附件
 */
+ (NSArray<MNEmojiAttachment *> *)matchingEmojiForString:(NSString *)string;

/**
 更新表情包本地数据
 @param packet 指定表情包
 @return 是否更新成功
 */
- (BOOL)updatePacket:(MNEmojiPacket *)packet;

@end

