//
//  WXUserInfoHeaderView.h
//  WeChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  用户资料详情Header

#import "MNAdsorbView.h"
@class WXUser, WXUserInfoHeaderView;

@interface WXUserInfoHeaderView : MNAdsorbView

/**更新用户信息*/
@property (nonatomic, strong) WXUser *user;

@end
