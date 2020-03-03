//
//  WXTransferDrawController.h
//  MNChat
//
//  Created by Vincent on 2019/6/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  收款

#import "MNExtendViewController.h"
@class WXRedpacket;

NS_ASSUME_NONNULL_BEGIN

@interface WXTransferDrawController : MNExtendViewController

@property (nonatomic, copy) void (^completionHandler) (void);

- (instancetype)initWithRedpacket:(WXRedpacket *)redpacket;

@end

NS_ASSUME_NONNULL_END
