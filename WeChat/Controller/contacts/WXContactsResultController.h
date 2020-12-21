//
//  WXContactsResultController.h
//  MNChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//  联系人搜索结果

#import "MNListViewController.h"
@class WXUser;

@interface WXContactsResultController : MNListViewController<MNSearchResultUpdating>

/**选择回调*/
@property (nonatomic, copy) void (^selectedHandler) (WXUser *);

@end

