//
//  WXChangeInfoController.h
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱明细

#import "MNListViewController.h"
@class WXChangeModel;

@interface WXChangeInfoController : MNListViewController

- (instancetype)initWithChangeModel:(WXChangeModel *)model;

@end
