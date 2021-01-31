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

@protocol WXAppletResultDelegate <NSObject>
@required
/**选择项*/
- (void)appletResultDidSelectModel:(WXDataValueModel *)model;
@end

@interface WXAppletResultController : MNListViewController<MNSearchResultUpdating>

/**数据源*/
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataSource;

/**交互代理*/
@property (nonatomic, weak) id <WXAppletResultDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
