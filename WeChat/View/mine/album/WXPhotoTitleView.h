//
//  WXPhotoTitleView.h
//  WeChat
//
//  Created by Vicent on 2021/4/22.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册-朋友圈标题

#import <UIKit/UIKit.h>
@class WXProfile, WXMoment;

NS_ASSUME_NONNULL_BEGIN

@interface WXPhotoTitleView : UIView

/**图片数据模型*/
@property (nonatomic, strong) WXProfile *profile;

@end

NS_ASSUME_NONNULL_END
