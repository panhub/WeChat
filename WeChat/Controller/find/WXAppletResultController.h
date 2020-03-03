//
//  WXAppletResultController.h
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  小程序搜索

#import "MNListViewController.h"
@class WXDataValueModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXAppletResultController : MNListViewController<MNSearchResultUpdating>

@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataSource;

@end

NS_ASSUME_NONNULL_END
