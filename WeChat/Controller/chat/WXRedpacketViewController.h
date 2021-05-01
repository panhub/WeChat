//
//  WXRedpacketViewController.h
//  WeChat
//
//  Created by Vincent on 2019/5/22.
//  Copyright © 2019 Vincent. All rights reserved.
//  发送红包

#import "MNExtendViewController.h"

@interface WXRedpacketViewController : MNExtendViewController

@property (nonatomic, getter=isMine) BOOL mine;

@property (nonatomic, copy) void (^completionHandler) (NSString *money, NSString *text);

@end
