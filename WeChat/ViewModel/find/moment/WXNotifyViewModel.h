//
//  WXNotifyViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXExtendViewModel.h"
#import "WXNotify.h"
@class WXMoment;

// 表格高度
FOUNDATION_EXTERN CGFloat const WXNotifyCellHeight;

@interface WXNotifyViewModel : NSObject
/**
 提醒数据模型
 */
@property (nonatomic, readonly, strong) WXNotify *notify;
/**
 关联的朋友圈数据模型
 */
@property (nonatomic, readonly, strong) WXMoment *moment;
/**
 头像
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *avatarViewModel;
/**
 昵称
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *nickViewModel;
/**
 时间
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *dateViewModel;
/**
 朋友圈内容
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *contentViewModel;
/**
 点赞
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *likeViewModel;
/**
 评论
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *commentViewModel;
/**
 配图
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *pictureViewModel;


/**
 实例化提醒视图模型
 @param notify 提醒数据模型
 @return 提醒事项视图模型
 */
+ (WXNotifyViewModel *)viewModelWithNotify:(WXNotify *)notify;

@end
