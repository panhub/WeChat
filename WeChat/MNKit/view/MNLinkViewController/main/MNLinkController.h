//
//  MNLinkController.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNLinkController : UIViewController

@property (nonatomic, assign, readonly) CGRect frame;

/**
 外部指定是否作为子控制器使用
 */
@property (nonatomic, assign) BOOL childController;

/**
 唯一实例化入口
 @param frame 你懂得
 @return 控制器实例
 */
- (instancetype)initWithFrame:(CGRect)frame __attribute__((objc_requires_super));

/**
 数据初始化
 */
- (void)initialized __attribute__((objc_requires_super));


/**
 适配框架新增函数, 不必理会
 @return 是否是子控制器
 */
- (BOOL)isChildViewController;

@end

