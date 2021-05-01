//
//  MNEmojiElementView.h
//  JLChat
//
//  Created by Vincent on 2020/2/13.
//  Copyright © 2020 AiZhe. All rights reserved.
//  表情删除/发送

#import <UIKit/UIKit.h>
@class MNEmojiKeyboardConfiguration;

@interface MNEmojiElementView : UIView
/**
 是否可点击
*/
@property(nonatomic,getter=isEnabled) BOOL enabled;
/**
 表情键盘配置信息
 */
@property (nonatomic, strong) MNEmojiKeyboardConfiguration *configuration;
/**
 添加事件
 @param target 响应者
 @param action 事件
 @param controlEvents 事件类型
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
