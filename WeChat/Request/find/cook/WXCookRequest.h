//
//  WXCookRequest.h
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱请求

#import "MNMobRequest.h"
#import "WXCookModel.h"

@interface WXCookRequest : MNMobRequest

- (instancetype)initWithCid:(NSString *)cid;

@end
