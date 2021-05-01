//
//  WXRedpacketInfoHeader.h
//  WeChat
//
//  Created by Vincent on 2019/5/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAdsorbView.h"
@class WXRedpacket;

NS_ASSUME_NONNULL_BEGIN

@interface WXRedpacketInfoHeader : MNAdsorbView

@property (nonatomic, strong) WXRedpacket *redpacket;

@property (nonatomic, copy) void (^changeInfoEventHandler) (void);

@end

NS_ASSUME_NONNULL_END
