//
//  MNEmoji.h
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情模型

#import <Foundation/Foundation.h>

/**
 表情类型
 -MNEmojiTypeText 文字富文本表情
 -MNEmojiTypeImage 图片表情
 -MNEmojiTypeFavorites 添加表情<仅存在于收藏夹>
 */
typedef NS_ENUM(NSInteger, MNEmojiType) {
    MNEmojiTypeText,
    MNEmojiTypeImage,
    MNEmojiTypeFavorites
};

@interface MNEmoji : NSObject <NSSecureCoding>
/**
 图片
 */
@property (nonatomic, strong) UIImage *image;
/**
 对应文字
 */
@property (nonatomic, copy) NSString *desc;
/**
 图片文件名
*/
@property (nonatomic, copy) NSString *img;
/**
 图片后缀
*/
@property (nonatomic, copy) NSString *extension;
/**
 所属表情包
 */
@property (nonatomic, copy) NSString *packet;
/**
 类型
*/
@property (nonatomic) MNEmojiType type;

/**
 字典样式
 */
- (id)JsonValue;

@end

