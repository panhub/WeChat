//
//  WXNotifyPicture.h
//  WeChat
//
//  Created by Vicent on 2021/4/27.
//  Copyright © 2021 Vincent. All rights reserved.
//  朋友圈通知配图

#import <UIKit/UIKit.h>
@class WXExtendViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXNotifyPicture : UIView

/**视图模型*/
@property (nonatomic, strong) WXExtendViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
