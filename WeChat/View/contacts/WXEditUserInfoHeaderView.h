//
//  WXEditUserInfoHeaderView.h
//  WeChat
//
//  Created by Vincent on 2019/4/6.
//  Copyright © 2019 Vincent. All rights reserved.
//  编辑用户资料表头

#import "MNAdsorbView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXEditUserInfoHeaderView : MNAdsorbView

@property (nonatomic, strong) WXUser *user;

@property (nonatomic, weak, readonly) UIButton *headButton;

@end

NS_ASSUME_NONNULL_END
