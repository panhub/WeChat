//
//  MNSegmentViewController.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  分段控制器基类

#import <UIKit/UIKit.h>

@interface MNSegmentViewController : UIViewController

/**记录位置*/
@property (nonatomic, assign, readonly) CGRect frame;

/**外界标记是否作为子控制器形式存在*/
@property (nonatomic, assign) BOOL childController;

/**外界携带位置信息初始化*/
- (instancetype)initWithFrame:(CGRect)frame __attribute__((objc_requires_super));

/**初始化参数*/
- (void)initialized __attribute__((objc_requires_super));

/**适配项目函数*/
- (BOOL)isChildViewController;

@end

