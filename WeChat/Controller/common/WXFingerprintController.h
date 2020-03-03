//
//  WXFingerprintController.h
//  MNChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//  支付验证

#import "MNExtendViewController.h"

@interface WXFingerprintController : MNExtendViewController

@property (nonatomic, copy) void (^didSucceedHandler) (UIViewController *v);

@end
