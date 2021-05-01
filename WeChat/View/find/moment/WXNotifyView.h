//
//  WXNotifyView.h
//  WeChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 AiZhe. All rights reserved.
//  朋友圈提醒视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXNotifyView : UIView

/**描述*/
@property (nonatomic, copy) NSString *title;

/**用户uid*/
@property (nonatomic, copy) UIImage *avatar;

@end

NS_ASSUME_NONNULL_END
