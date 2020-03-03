//
//  WXRedpacketInfoController.h
//  MNChat
//
//  Created by Vincent on 2019/5/28.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包领取详情

#import "MNListViewController.h"
#import "WXRedpacket.h"

typedef NS_ENUM(NSInteger, WXRedpacketInfoType) {
    WXRedpacketInfoDraw = 0,
    WXRedpacketInfoSend
};

NS_ASSUME_NONNULL_BEGIN

@interface WXRedpacketInfoController : MNListViewController

@property (nonatomic, assign) WXRedpacketInfoType type;

- (instancetype)initWithRedpacket:(WXRedpacket *)redpacket;

@end

NS_ASSUME_NONNULL_END
