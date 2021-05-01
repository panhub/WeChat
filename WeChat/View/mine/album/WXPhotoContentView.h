//
//  WXPhotoContentView.h
//  WeChat
//
//  Created by Vicent on 2021/4/23.
//  Copyright © 2021 Vincent. All rights reserved.
//  相册-底部内容

#import <UIKit/UIKit.h>
@class WXProfile;

NS_ASSUME_NONNULL_BEGIN

@interface WXPhotoContentView : UIView

/**图片数据模型*/
@property (nonatomic, strong) WXProfile *profile;

@end

NS_ASSUME_NONNULL_END
