//
//  MNAssetPickController.h
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片/视频显示

#import "MNListViewController.h"
#import "MNAssetPickConfiguration.h"

@interface MNAssetPickController : MNListViewController

/**配置信息*/
@property (nonatomic, readonly, strong) MNAssetPickConfiguration *configuration;

@end
