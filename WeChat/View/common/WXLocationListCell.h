//
//  WXLocationListCell.h
//  WeChat
//
//  Created by Vincent on 2019/5/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class AMapPOI, AMapTip;

NS_ASSUME_NONNULL_BEGIN

@interface WXLocationListCell : MNTableViewCell

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) AMapTip *tip;

@property (nonatomic, strong) AMapPOI *location;

@end

NS_ASSUME_NONNULL_END
