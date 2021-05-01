//
//  WXPhotoViewController.h
//  WeChat
//
//  Created by Vicent on 2021/4/22.
//  Copyright © 2021 Vincent. All rights reserved.
//  朋友圈预览控制器

#import "MNExtendViewController.h"
@class WXProfile, WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXPhotoViewController : MNExtendViewController

/**指定用户*/
@property (nonatomic, strong) WXUser *user;

/**背景图*/
@property (nonatomic, strong) UIImage *backgroundImage;


/**
 实例化朋友圈预览控制器
 @param photos 图片集合
 @return 朋友圈预览控制器
 */
- (instancetype)initWithPhotos:(NSArray <WXProfile *>*)photos startIndex:(NSInteger)startIndex;

@end

NS_ASSUME_NONNULL_END
