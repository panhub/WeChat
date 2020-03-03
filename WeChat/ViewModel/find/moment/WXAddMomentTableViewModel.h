//
//  WXAddMomentTableViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  发布朋友圈底部视图描述模型

#import <Foundation/Foundation.h>
#import "WXMapLocation.h"

@interface WXAddMomentTableViewModel : NSObject
/**
 是否隐私
 */
@property (nonatomic, getter=isPrivacy) BOOL privacy;
/**
 位置
 */
@property (nonatomic, copy) NSString *location;
/**
 经纬位置
 */
@property (nonatomic, strong) WXMapLocation *point;
/**
 日期
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 朋友圈发布者
 */
@property (nonatomic, strong) WXUser *owner;
/**
 获取位置拼接
 */
@property (nonatomic, copy) NSString *dec;

@end
