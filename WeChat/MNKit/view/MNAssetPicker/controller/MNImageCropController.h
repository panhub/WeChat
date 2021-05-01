//
//  MNImageCropController.h
//  MNKit
//
//  Created by Vincent on 2019/4/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片裁剪 

#import "MNBaseViewController.h"
@class MNImageCropController;

typedef NS_ENUM(NSInteger, MNImageCropTransitionType) {
    MNImageCropTransitionNormal = 0,
    MNImageCropTransitionPortal,
    MNImageCropTransitionFlip,
    MNImageCropTransitionModel
};

NS_ASSUME_NONNULL_BEGIN
@protocol MNImageCropDelegate <NSObject>
@optional;
/**取消裁剪*/
- (void)imageCropControllerDidCancel:(MNImageCropController *)controller;
/**已裁剪图片*/
- (void)imageCropController:(MNImageCropController *)controller didCroppingImage:(UIImage *)image;
@end

/**事件回调*/
typedef void(^MNImageCropCancelHandler)(MNImageCropController *vc);
/**事件回调*/
typedef void(^MNImageCropHandler)(MNImageCropController *vc, UIImage *image);

@interface MNImageCropController : MNBaseViewController
/**裁剪比例*/
@property (nonatomic) CGFloat cropScale;
/**背景颜色*/
@property (nonatomic, copy, nullable) UIColor *backgroundColor;
/**裁剪事件回调*/
@property (nonatomic, copy, nullable) MNImageCropHandler cropHandler;
/**取消事件回调*/
@property (nonatomic, copy, nullable) MNImageCropCancelHandler cancelHandler;
/**事件代理*/
@property (nonatomic, weak, nullable) id<MNImageCropDelegate> delegate;
/**转场类型*/
@property (nonatomic) MNImageCropTransitionType transitionType;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTitle:(NSString *)title UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
/**
 依据图片初始化
 @param image 图片
 @return 图片裁剪控制器
 */
- (instancetype)initWithImage:(UIImage *)image;

/**
 依据图片/代理初始化
 @param image 图片
 @param delegate 代理
 @return 图片裁剪控制器
 */
- (instancetype)initWithImage:(UIImage *)image delegate:(id<MNImageCropDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
