//
//  WXCookListController.h
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜单List

#import "MNListViewController.h"
@class WXCookMenu;

NS_ASSUME_NONNULL_BEGIN

@interface WXCookListController : MNListViewController

- (instancetype)initWithFrame:(CGRect)frame menu:(WXCookMenu *)menu;

@end

NS_ASSUME_NONNULL_END
