//
//  MNModelViewController.h
//  MNKit
//
//  Created by Vincent on 2018/2/27.
//  Copyright © 2018年 Apple.lnc. All rights reserved.
//  模态转场控制器

#import "MNListViewController.h"
#import "MNTransitionAnimator.h"

@interface MNModelViewController : MNListViewController<UIViewControllerTransitioningDelegate>

- (BOOL)shouldChangeStatusBarStyle;

- (void)dismiss;

- (MNControllerTransitionType)modelTransitionType;

@end
