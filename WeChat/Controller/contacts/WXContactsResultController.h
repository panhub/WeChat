//
//  WXContactsResultController.h
//  WeChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//  联系人搜索结果

#import "MNListViewController.h"
@class WXUser;

@interface WXContactsResultController : MNListViewController<MNSearchResultUpdating>

/**数据源*/
@property (nonatomic, strong) NSArray <WXUser *>*dataSource;

/**选择的数组*/
@property (nonatomic, strong) NSMutableArray <WXUser *>*selectedUsers;

/**是否支持多选*/
@property (nonatomic, getter=isMultipleSelectEnabled) BOOL multipleSelectEnabled;

/**选择时回调*/
@property (nonatomic, copy) void (^selectedHandler) (WXUser *);

@end

