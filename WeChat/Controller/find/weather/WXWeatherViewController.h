//
//  WXWeatherViewController.h
//  MNChat
//
//  Created by Vincent on 2019/5/6.
//  Copyright © 2019 Vincent. All rights reserved.
//  天气

#import "MNExtendViewController.h"
@class WXDistrictModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXWeatherViewController : MNExtendViewController

- (instancetype)initWithDistrict:(WXDistrictModel *)districtModel;

@end

NS_ASSUME_NONNULL_END
