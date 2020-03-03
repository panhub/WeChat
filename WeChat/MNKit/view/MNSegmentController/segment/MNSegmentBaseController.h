//
//  MNSegmentBaseController.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  分段控制器基类

#import <UIKit/UIKit.h>

@interface MNSegmentBaseController : UIViewController

@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, assign) BOOL childController;

- (instancetype)initWithFrame:(CGRect)frame __attribute__((objc_requires_super));
- (void)initialized __attribute__((objc_requires_super));

/**适配项目函数*/
- (BOOL)isChildViewController;

@end

