//
//  MNEmojiPacket.h
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情包

#import <Foundation/Foundation.h>
#import "MNEmoji.h"

/**
 表情包状态
 -MNEmojiPacketStateValid 可用
 -MNEmojiPacketStateInvalid 不可用
 */
typedef NS_ENUM(NSInteger, MNEmojiPacketState) {
    MNEmojiPacketStateValid,
    MNEmojiPacketStateInvalid
};

/**
 表情类型
 -MNEmojiPacketTypeText 文字富文本表情
 -MNEmojiPacketTypeImage 图片表情
 */
typedef NS_ENUM(NSInteger, MNEmojiPacketType) {
    MNEmojiPacketTypeText,
    MNEmojiPacketTypeImage
};

@interface MNEmojiPacket : NSObject <NSSecureCoding>
/**
 表情包名
 */
@property (nonatomic, copy) NSString *name;
/**
 表情包描述
 */
@property (nonatomic, copy) NSString *desc;
/**
 图片
 */
@property (nonatomic, strong) UIImage *image;
/**
 封面
 */
@property (nonatomic, strong) NSString *img;
/**
 标识符<表情图片文件夹>
 */
@property (nonatomic, copy) NSString *uuid;
/**
 类型
*/
@property (nonatomic) MNEmojiPacketType type;
/**
 状态
*/
@property (nonatomic) MNEmojiPacketState state;
/**
 表情数组
 */
@property (nonatomic, strong) NSMutableArray <MNEmoji *>*emojis;

/**
 字典样式
 */
- (id)JsonValue;

@end

