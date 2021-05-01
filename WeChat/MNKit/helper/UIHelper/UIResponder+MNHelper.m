//
//  UIResponder+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2019/9/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "UIResponder+MNHelper.h"

@implementation UIResponder (MNHelper)
#pragma mark - 寻找自身所在的控制器
- (UIViewController *)viewController {
    return [self nextResponderForClass:NSClassFromString(@"UIViewController")];
}

#pragma mark - 寻找响应链上的指定类实例
- (id)nextResponderForClass:(Class)cls {
    if ([self isKindOfClass:cls]) return self;
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:cls]) break;
        responder = responder.nextResponder;
    } while (responder);
    return responder;
}

@end
