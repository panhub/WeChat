//
//  WXChangeModel.h
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱数据模型

#import <Foundation/Foundation.h>

/**
 零钱发生途径
 - WXChangeChannelDefault: 默认
 - WXChangeChannelRecharge: 充值
 - WXChangeChannelWithdraw: 提现
 - WXChangeChannelCost: 服务费
 - WXChangeChannelTransfer: 转账
 - WXChangeChannelRedpacket: 红包
 */
typedef NS_ENUM(NSInteger, WXChangeChannel) {
    WXChangeChannelDefault = 0,
    WXChangeChannelRecharge,
    WXChangeChannelWithdraw,
    WXChangeChannelCost,
    WXChangeChannelTransfer,
    WXChangeChannelRedpacket
};

@interface WXChangeModel : NSObject
/**
 单号
 */
@property (nonatomic, copy) NSString *numbers;
/**
 零钱渠道
 */
@property (nonatomic, copy) NSString *title;
/**
 发生时间
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 金额
 */
@property (nonatomic, assign) CGFloat money;
/**
 类型
 */
@property (nonatomic, copy) NSString *type;
/**
 渠道
 */
@property (nonatomic, assign) WXChangeChannel channel;
/**
 备注
 */
@property (nonatomic, copy) NSString *note;
/**
 事件产生的用户uid
 */
@property (nonatomic, copy) NSString *uid;

@end
