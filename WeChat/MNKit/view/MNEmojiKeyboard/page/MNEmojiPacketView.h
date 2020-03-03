//
//  MNEmojiPacketView.h
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情类型控制器

#import <UIKit/UIKit.h>
@class MNEmojiPacketView, MNEmojiKeyboardConfiguration;

@protocol MNEmojiPacketViewDelegate <NSObject>
/**表情包选择*/
- (void)emojiPacketViewDidSelectPacketOfIndex:(NSUInteger)index;
/**Return键点击*/
- (void)emojiReturnButtonTouchUpInside;
/**添加键点击*/
- (void)emojiPacketAddButtonTouchUpInside;
@end

@protocol MNEmojiPacketViewDataSource <NSObject>
/**获取表情包*/
- (NSArray <MNEmojiPacket *>*)emojiPacketsOfPacketView;
@end

@interface MNEmojiPacketView : UIView
/**
 交互事件代理
 */
@property (nonatomic, weak) id<MNEmojiPacketViewDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNEmojiPacketViewDataSource> dataSource;

/**
 选择器实例化入口
 @param configuration 表情键盘配置
 @return 表情键盘选择器
 */
- (instancetype)initWithConfiguration:(MNEmojiKeyboardConfiguration *)configuration;
/**
 设置选择索引
 @param index 指定索引
 */
- (void)selectPacketOfIndex:(NSUInteger)index;
/**
 选择器重载数据
 */
- (void)reloadData;

@end
