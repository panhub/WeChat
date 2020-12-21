//
//  WXShakePersonCard.h
//  MNChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//  摇一摇搜索附近人

#import <UIKit/UIKit.h>
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXShakePersonCard : UIControl

/**更新信息*/
@property (nonatomic, strong) WXUser *user;

/**相距多少公里*/
@property (nonatomic, readonly) NSString *distance;

/**隐藏摇一摇个人视图*/
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
