//
//  MNAssetPicker.m
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetPicker.h"
#import "MNAsset.h"
#import "MNAssetPickController.h"
#import "MNImageCropController.h"
#import "MNCapturingController.h"

@interface MNAssetPicker ()<MNCapturingControllerDelegate, MNAssetPickerDelegate,  MNImageCropDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic) MNAssetPickerType type;
@property (nonatomic, copy) void (^cancelHandler) (void);
@property (nonatomic, copy) void (^pickingHandler) (NSArray <MNAsset *>*assets);
@end

@implementation MNAssetPicker
@synthesize configuration = _configuration;

- (instancetype)init {
    return [self initWithRootViewController:[MNAssetPickController new]];
}

- (instancetype)initWithRootViewController:(UIViewController *)vc {
    if (self == [super initWithRootViewController:vc]) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.type = [vc isKindOfClass:MNAssetPickController.class] ? MNAssetPickerTypeNormal : MNAssetPickerTypeCapturing;
    }
    return self;
}

+ (instancetype)picker {
    return [[self alloc] initWithType:MNAssetPickerTypeNormal];
}

+ (instancetype)capturer {
    return [[self alloc] initWithType:MNAssetPickerTypeCapturing];
}

- (instancetype)initWithType:(MNAssetPickerType)type {
    if (type == MNAssetPickerTypeNormal) return [self init];
    MNCapturingController *vc = [MNCapturingController new];
    vc.delegate = self;
    vc.configuration = [MNAssetPickConfiguration new];
    return [self initWithRootViewController:vc];
}

- (void)presentWithPickingHandler:(void(^)(NSArray <MNAsset *>*assets))pickingHandler cancelHandler:(void(^)(void))cancelHandler {
    self.configuration.delegate = self;
    self.cancelHandler = cancelHandler;
    self.pickingHandler = pickingHandler;
    [UIWindow.presentedViewController presentViewController:self animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - MNCapturingControllerDelegate
- (void)capturingControllerDidCancel:(MNCapturingController *)capturingController {
    if ([self.configuration.delegate respondsToSelector:@selector(assetPickerDidCancel:)]) {
        [self.configuration.delegate assetPickerDidCancel:self];
    } else {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive completion:nil];
        }
    }
}

- (void)capturingController:(MNCapturingController *)capturingController didFinishWithContent:(id)content {
    if ([content isKindOfClass:UIImage.class] && self.configuration.allowsEditing) {
        MNImageCropController *vc = [[MNImageCropController alloc] initWithImage:content delegate:self];
        vc.cropScale = self.configuration.cropScale;
        [self pushViewController:vc animated:YES];
    } else {
        if ([self.configuration.delegate respondsToSelector:@selector(assetPicker:didFinishPickingAssets:)]) {
            if ([content isKindOfClass:UIImage.class] && self.configuration.exportPixel > 0.f) {
                content = [kTransform(UIImage *, content) resizingToPix:self.configuration.exportPixel];
            }
            [self.configuration.delegate assetPicker:self didFinishPickingAssets:@[[MNAsset assetWithContent:content]]];
        }
    }
}

#pragma mark - MNImageCropDelegate
- (void)imageCropControllerDidCancel:(MNImageCropController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropController:(MNImageCropController *)controller didCroppingImage:(UIImage *)image {
    if ([self.configuration.delegate respondsToSelector:@selector(assetPicker:didFinishPickingAssets:)]) {
        if (self.configuration.exportPixel > 0.f) image = [image resizingToPix:self.configuration.exportPixel];
        [self.configuration.delegate assetPicker:self didFinishPickingAssets:@[[MNAsset assetWithContent:image]]];
    }
}

#pragma mark - MNAssetPickerDelegate
- (void)assetPickerDidCancel:(MNAssetPicker *)picker {
    __weak typeof(self) weakself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakself.cancelHandler) {
            weakself.cancelHandler();
        }
    }];
}

- (void)assetPicker:(MNAssetPicker *)picker didFinishPickingAssets:(NSArray<MNAsset *> *)assets {
    __weak typeof(self) weakself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakself.pickingHandler) {
            weakself.pickingHandler(assets);
        }
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeDefaultModel];
    animator.transitionOperation = MNControllerTransitionOperationPush;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType: MNControllerTransitionTypeDefaultModel];
    animator.transitionOperation = MNControllerTransitionOperationPop;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

#pragma mark - Getter
- (MNAssetPickConfiguration *)configuration {
    if (!_configuration && self.viewControllers.count > 0) {
        UIViewController *vc = self.viewControllers.firstObject;
        if ([self.viewControllers.firstObject isKindOfClass:MNAssetPickController.class]) {
            _configuration = ((MNAssetPickController *)vc).configuration;
        } else if ([self.viewControllers.firstObject isKindOfClass:MNCapturingController.class]) {
            _configuration = ((MNCapturingController *)vc).configuration;
        }
    }
    return _configuration;
}

#pragma mark - Super
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeDefaultModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeDefaultModel];
}

#pragma mark - dealloc
- (void)dealloc {
    MNDeallocLog;
}

@end
