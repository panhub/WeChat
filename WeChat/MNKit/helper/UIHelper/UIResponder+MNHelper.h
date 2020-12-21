//
//  UIResponder+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2019/9/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (MNHelper)

/**寻找自身所在的控制器*/
- (UIViewController *_Nullable)viewController;

/**寻找响应链上的指定类实例*/
- (id _Nullable)nextResponderForClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
