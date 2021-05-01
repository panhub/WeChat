//
//  WXAddMomentTableView.h
//  WeChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  发布朋友圈底部cell

#import <UIKit/UIKit.h>
@class WXLocation;

@interface WXAddMomentTableView : UIView
/**
 是否隐私
 */
@property (nonatomic, getter=isPrivacy) BOOL privacy;
/**
 位置
 */
@property (nonatomic, strong) WXLocation *location;
/**
 发布日期
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 朋友圈发布者
 */
@property (nonatomic, strong) WXUser *user;

@end
