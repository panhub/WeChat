//
//  WXLocationViewController.h
//  WeChat
//
//  Created by Vincent on 2019/5/11.
//  Copyright © 2019 Vincent. All rights reserved.
//  选择位置

#import "MNSearchViewController.h"
#import "WXLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXLocationViewController : MNSearchViewController

/**位置选择回调*/
@property (nonatomic, copy, nullable) void (^didSelectHandler) (WXLocation *_Nullable);

@end

NS_ASSUME_NONNULL_END
