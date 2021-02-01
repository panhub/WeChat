//
//  WXWeatherRequest.h
//  MNChat
//
//  Created by Vincent on 2019/5/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXJHRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXWeatherRequest : WXJHRequest

- (instancetype)initWithCity:(NSString *)city district:(NSString *)district;

@end

NS_ASSUME_NONNULL_END
