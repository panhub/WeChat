//
//  WXPasswordViewController.h
//  WeChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//  输入密码

#import "MNExtendViewController.h"

@interface WXPasswordViewController : MNExtendViewController

@property (nonatomic, copy) void (^didSucceedHandler) (UIViewController *v);

@end
