//
//  MNImageCropController.m
//  MNKit
//
//  Created by Vincent on 2019/4/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNImageCropController.h"
#import "JPImageresizerView.h"

@interface MNImageCropController ()
{
    BOOL StatusBarHidden;
    BOOL NavigationBarHidden;
}
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) UIButton *clipButton;
@property (nonatomic, weak) UIButton *resetButton;
@property (nonatomic, strong) NSArray <NSNumber *>*ratios;
@property (nonatomic, weak) JPImageresizerView *imageView;
@end

@implementation MNImageCropController
- (instancetype)initWithImage:(UIImage *)image delegate:(id<MNImageCropDelegate>)delegate {
    if (self = [self initWithImage:image]) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (!image) return nil;
    if (self = [super init]) {
        self.image = image;
    }
    return self;
}

- (void)initialized {
    [super initialized];
    self.cropScale = 0.f;
    self.ratios = @[@(2.f/3.f), @(3.f/2.f), @(3.f/5.f), @(5.f/3.f), @(9.f/16.f), @(16.f/9.f), @(0.f), @(1.f)];
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    @weakify(self);
    JPImageresizerView *imageView = [[JPImageresizerView alloc] initWithResizeImage:self.image
                                                                              frame:self.contentView.bounds
                                                                           maskType:JPDarkBlurMaskType
                                                                          frameType:JPClassicFrameType
                                                                     animationCurve:JPAnimationCurveLinear
                                                                        strokeColor:[UIColor whiteColor]
                                                                            bgColor:[UIColor clearColor]
                                                                          maskAlpha:0.3
                                                                      verBaseMargin:10
                                                                      horBaseMargin:10
                                                                      resizeWHScale:fabs(self.cropScale)
                                                                      contentInsets:UIEdgeInsetsMake(MN_STATUS_BAR_HEIGHT + 10.f, 0.f, 50.f + MN_TAB_SAFE_HEIGHT, 0.f)
                                                          imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
                                                              @strongify(self);
                                                              self.resetButton.selected = !isCanRecovery;
                                                            }
                                                       imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
                                                           @strongify(self);
                                                           self.clipButton.selected = isPrepareToScale;
                                                        }];
    imageView.isClockwiseRotation = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    NSArray <NSNumber *>*tags = @[@(0), @(1), @(2), @(3), @(4)];
    NSArray <NSString *>*imgs = @[@"image_edit_cancel", @"image_edit_revoke", @"image_edit_rotation", @"image_edit_crop", @"image_edit_confirm"];
    if (fabs(self.cropScale) != 0.f) {
        tags = @[@(0), @(1), @(2), @(4)];
        imgs = @[@"image_edit_cancel", @"image_edit_revoke", @"image_edit_rotation", @"image_edit_confirm"];
    }
    CGFloat wh = 23.f;
    CGFloat interval = (self.contentView.width_mn - wh*imgs.count)/(imgs.count + 1);
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(interval + (wh + interval)*idx, self.contentView.height_mn - MN_TAB_SAFE_HEIGHT - wh - 13.f, wh, wh);
        button.tag = [tags[idx] integerValue];
        button.touchInset = UIEdgeInsetWith(-7.f);
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[MNBundle imageForResource:img inDirectory:@"editing"] forState:UIControlStateNormal];
        [self.contentView addSubview:button];
        if (button.tag == 1) {
            [button setBackgroundImage:[MNBundle imageForResource:[img stringByAppendingString:@"_disable"] inDirectory:@"editing"] forState:UIControlStateSelected];
            button.selected = YES;
            self.resetButton = button;
        } else if (button.tag == 4) {
            self.clipButton = button;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstAppear) {
        StatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        NavigationBarHidden = self.navigationController.navigationBar.hidden;
    }
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NavigationBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:StatusBarHidden withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Event
- (void)buttonClicked:(UIButton *)button {
    if (button.selected) return;
    if (button.tag == 0) {
        if (self.cancelHandler) {
            self.cancelHandler(self);
        }
        if ([self.delegate respondsToSelector:@selector(imageCropControllerDidCancel:)]) {
            [self.delegate imageCropControllerDidCancel:self];
        }
    } else if (button.tag == 1) {
        [self.imageView recovery];
    } else if (button.tag == 2) {
        [self.imageView rotation];
    } else if (button.tag == 3) {
        __weak typeof(self) weakself = self;
        [[MNActionSheet actionSheetWithTitle:@"选择裁剪比例" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex || buttonIndex >= weakself.ratios.count) return;
            [weakself.imageView setResizeWHScale:[weakself.ratios[buttonIndex] floatValue] animated:YES];
        } otherButtonTitles:@"2:3", @"3:2", @"3:5", @"5:3", @"9:16", @"16:9",  @"任意尺寸", @"正方形", nil] showInView:self.view];
    } else {
        __weak typeof(self) weakself = self;
        [self.imageView originImageresizerWithComplete:^(UIImage *resizeImage) {
            if (!resizeImage) {
                [weakself.view showInfoDialog:@"图片资源错误"];
                return;
            }
            if (weakself.cropHandler) {
                weakself.cropHandler(weakself, resizeImage);
            }
            if ([weakself.delegate respondsToSelector:@selector(imageCropController:didCroppingImage:)]) {
                [weakself.delegate imageCropController:weakself didCroppingImage:resizeImage];
            }
        }];
    }
}

#pragma mark - Setter
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor.copy;
    self.view.backgroundColor = backgroundColor;
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    if (self.transitionType == MNImageCropTransitionNormal) return nil;
    if (self.transitionType == MNImageCropTransitionPortal) {
        return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePortal];
    } else if (self.transitionType == MNImageCropTransitionFlip) {
        return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeFlip];
    }
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    if (self.transitionType == MNImageCropTransitionNormal) return nil;
    if (self.transitionType == MNImageCropTransitionPortal) {
        return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePortal];
    } else if (self.transitionType == MNImageCropTransitionFlip) {
        return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeFlip];
    }
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
