//
//  WXChatSettingHeaderView.h
//  MNChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天设置表头

#import <UIKit/UIKit.h>
@class WXChatSettingHeaderView;

@protocol WXChatSettingHeaderDelegate <NSObject>
@optional;
- (void)headerViewAvatarButtonTouchUpInside:(WXChatSettingHeaderView *)headerView;
@end

@interface WXChatSettingHeaderView : UIView

/**用户信息*/
@property (nonatomic, strong) WXUser *user;

/**交互代理*/
@property (nonatomic, weak) id<WXChatSettingHeaderDelegate> delegate;

@end
