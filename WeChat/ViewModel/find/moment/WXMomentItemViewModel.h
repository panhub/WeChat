//
//  WXMomentItemViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  点赞/评论视图模型基类

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXMomentItemType) {
    WXMomentItemTypeLiked,
    WXMomentItemTypeComment
};

@interface WXMomentItemViewModel : NSObject
/**
 标记类型
 */
@property (nonatomic) WXMomentItemType type;
/**
 视图高度
 */
@property (nonatomic) CGFloat height;
/**
 显示的内容
 */
@property (nonatomic, strong) NSMutableAttributedString *content;
/**
 内容尺寸
 */
@property (nonatomic) CGRect contentFrame;
/**
 是否隐藏分割线
 */
@property (nonatomic, readonly, getter=isHiddenDivider) BOOL hiddenDivider;

@end
