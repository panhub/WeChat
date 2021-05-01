//
//  WXChangeListController.h
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱明细

#import "MNListViewController.h"

typedef NS_ENUM(NSInteger, WXChangeListType) {
    WXChangeListAll = 0,
    WXChangeListWithdraw
};

@interface WXChangeListController : MNListViewController

@property (nonatomic, assign) WXChangeListType type;

@end
