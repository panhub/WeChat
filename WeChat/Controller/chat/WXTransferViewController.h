//
//  WXTransferViewController.h
//  MNChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账

#import "MNExtendViewController.h"

@interface WXTransferViewController : MNExtendViewController

@property (nonatomic, copy) void (^completionHandler) (NSString *money, NSString *text);

- (instancetype)initWithUser:(WXUser *)user;

@end
