//
//  WXRedpacketAlertView.h
//  WeChat
//
//  Created by Vincent on 2019/5/27.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包弹窗

#import <UIKit/UIKit.h>
#import "WXRedpacket.h"

typedef void(^WXRedpacketAlertHandler)(void);

NS_ASSUME_NONNULL_BEGIN

@interface WXRedpacketAlertView : UIView

@property (nonatomic, strong) WXRedpacket *redpacket;

- (void)show;

- (void)dismiss;

- (instancetype)initWithOpenHandler:(WXRedpacketAlertHandler)openHandler
                      detailHandler:(WXRedpacketAlertHandler)detailHandler;

@end

NS_ASSUME_NONNULL_END
