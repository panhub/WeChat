//
//  WXMomentEventViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  点赞/评论视图模型基类

#import <Foundation/Foundation.h>

/**
 事件类型
 - WXMomentEventTypeLiked: 点赞
 - WXMomentEventTypeComment: 评论
 */
typedef NS_ENUM(NSInteger, WXMomentEventType) {
    WXMomentEventTypeLiked,
    WXMomentEventTypeComment
};

@interface WXMomentEventViewModel : NSObject
/**
 视图高度
 */
@property (nonatomic) CGFloat height;
/**
 内容尺寸
 */
@property (nonatomic) CGRect contentFrame;
/**
 标记类型
 */
@property (nonatomic) WXMomentEventType type;
/**
 显示的内容
 */
@property (nonatomic, strong) NSMutableAttributedString *content;
/**
 是否隐藏分割线
 */
@property (nonatomic, readonly, getter=isHiddenDivider) BOOL hiddenDivider;

/**
 更新约束
 */
- (void)updateLayout;

@end
