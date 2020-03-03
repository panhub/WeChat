//
//  WXContactsSelectController.h
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//  选择用户控制器 

#import "MNSearchViewController.h"
@class WXUser;

@interface WXContactsSelectController : MNSearchViewController

/**除去指定联系人*/
@property (nonatomic, strong) NSArray <WXUser *>*expelUsers;

/**多选时是否允许未选中回调*/
@property (nonatomic, getter=isAllowsUnselected) BOOL allowsUnselected;

/**是否多选*/
@property (nonatomic, getter=isMultipleSelectEnabled) BOOL multipleSelectEnabled;

/**默认已选联系人, 多选模式下有效*/
@property (nonatomic, strong) NSMutableArray <WXUser *>*selectedArray;

/**选择回调*/
@property (nonatomic, copy) void (^selectedHandler) (UIViewController *, NSArray <WXUser *>*);

/**
 联系人选择控制器构造方法
 @param selectedHandler 选择回调
 @return 联系人选择控制器
 */
- (instancetype)initWithSelectedHandler:(void(^)(UIViewController *, NSArray <WXUser *>*))selectedHandler;

@end
