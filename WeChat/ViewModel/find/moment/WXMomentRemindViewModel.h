//
//  WXMomentRemindViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXMomentRemind.h"
#import "WXExtendViewModel.h"
@class WXMoment;


FOUNDATION_EXTERN CGFloat const WXMomentRemindCellHeight;

@interface WXMomentRemindViewModel : NSObject
/**
 提醒数据模型
 */
@property (nonatomic, readonly, strong) WXMomentRemind *model;
/**
 关联的朋友圈数据模型
 */
@property (nonatomic, readonly, strong) WXMoment *moment;
/**
 头像
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *headViewModel;
/**
 昵称
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *nameLabelModel;
/**
 时间
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *timeLabelModel;
/**
 文字<赞, 评论内容>
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *textLabelModel;
/**
 由方简介视图<赞, 评论内容>
 */
@property (nonatomic, readonly, strong) WXExtendViewModel *briefViewModel;

/**
 实例化
 @param model 提醒事项数据模型
 @return 提醒事项视图模型
 */
- (instancetype)initWithModel:(WXMomentRemind *)model;

@end
