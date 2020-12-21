//
//  WXCityListController.h
//  MNChat
//
//  Created by Vincent on 2019/5/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNListViewController.h"
@class WXCityModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXCityListController : MNListViewController

@property (nonatomic, strong) NSArray <WXCityModel *>*dataSource;

@end

NS_ASSUME_NONNULL_END
