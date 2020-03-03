//
//  MNImageCropController.h
//  MNChat
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

@protocol MNImageCropDelegate <NSObject>

@optional;

- (void)imageCropControllerDidCancel:(MNImageCropController *)controller;

- (void)imageCropController:(MNImageCropController *)controller didCroppingImage:(UIImage *)image;

@end

typedef void(^MNImageCropCancelHandler)(MNImageCropController *vc);

typedef void(^MNImageCropHandler)(MNImageCropController *vc, UIImage *image);

@interface MNImageCropController : MNBaseViewController

@property (nonatomic) CGFloat cropScale;

@property (nonatomic, copy) UIColor *backgroundColor;

@property (nonatomic, copy) MNImageCropHandler cropHandler;

@property (nonatomic, copy) MNImageCropCancelHandler cancelHandler;

@property (nonatomic, weak) id<MNImageCropDelegate> delegate;

@property (nonatomic, assign) MNImageCropTransitionType transitionType;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTitle:(NSString *)title UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithImage:(UIImage *)image delegate:(id<MNImageCropDelegate>)delegate;

@end
