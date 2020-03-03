//
//  UIResponder+MNHelper.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/24.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (MNHelper)

/**寻找自身所在的控制器*/
- (UIViewController *)viewController;

/**寻找响应链上的指定类实例*/
- (id)nextResponderForClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
