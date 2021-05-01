//
//  WXNewMomentController.h
//  WeChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//  发布朋友圈 

#import "MNListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXNewMomentController : MNListViewController

/**
 依据资源模型实例化新建朋友圈控制器
 @param assets 资源数据模型集合
 @return 新建朋友圈实例
 */
- (instancetype)initWithAssets:(NSArray <MNAsset *>*_Nullable)assets;

@end

NS_ASSUME_NONNULL_END
