//
//  WXMomentPreview.h
//  WeChat
//
//  Created by Vincent on 2019/9/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈详情 

#import <UIKit/UIKit.h>
@class WXMoment;

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentPreview : UIView

- (instancetype)initWithMoment:(WXMoment *)moment;

@end

NS_ASSUME_NONNULL_END
