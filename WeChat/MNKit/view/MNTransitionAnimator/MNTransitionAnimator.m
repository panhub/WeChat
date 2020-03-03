//
//  MNTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/1/5.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTransitionAnimator.h"
#import "UIView+MNHelper.h"
#import <objc/runtime.h>

static NSString * MNTransitionTabBarAssociatedKey = @"mn.transition.tabbar.associated";
static NSString * MNTransitionSnapshotAssociatedKey = @"mn.transition.snapshot.associated";

@interface MNTransitionAnimator()
@property (nonatomic, readwrite, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, readwrite, weak) UIView *containerView;
@property (nonatomic, readwrite, weak) UIViewController *fromController;
@property (nonatomic, readwrite, weak) UIViewController *toController;
@property (nonatomic, readwrite, weak) UIView *fromView;
@property (nonatomic, readwrite, weak) UIView *toView;
@property (nonatomic, readwrite, weak) UIView *tabBar;
@end

static NSArray <NSString *>*MNTransitionAnimatorSet;

@implementation MNTransitionAnimator
+ (void)load {
    MNTransitionAnimatorSet = @[@"MNSlideTransitionAnimator",
                                        @"MNSolubleTransitionAnimator",
                                        @"MNDistanceTransitionAnimator",
                                        @"MNPortalTransitionAnimator",
                                        @"MNFlipTransitionAnimator",
                                        @"MNPushModelTransitionAnimator",
                                        @"MNDefaultModelTransitionAnimator",
                                        @"MNMenuTransitionAnimator",
                                        @"MN3DMenuTransitionAnimator",
                                        @"MNTransition3DAnimator"];
}

+ (instancetype)animatorWithType:(MNControllerTransitionType)type {
    if (type >= MNTransitionAnimatorSet.count) return nil;
    return [NSClassFromString([MNTransitionAnimatorSet objectAtIndex:type]) new];
}

- (instancetype)init {
    if (self = [super init]) {
        _duration = .5f;
        _tabBarTransitionType = MNTabBarTransitionTypeNone;
        _transitionOperation = MNControllerTransitionOperationPush;
    }
    return self;
}

#pragma mark - Protocol UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [self initializeWithContext:transitionContext];
    if (self.interactive) {
        [self interactiveTransitionAnimation];
    } else if (_transitionOperation == MNControllerTransitionOperationPush) {
        [self pushTransitionAnimation];
    } else {
        [self popTransitionAnimation];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
    if (!_interactive) return;
    if (transitionCompleted) {
        [self finishTabBarTransitionAnimation];
        [_fromView.snapshot_ removeFromSuperview];
        [_fromView setSnapshot_:nil];
        [_fromView removeFromSuperview];
    } else {
        [_toView setTransform:CGAffineTransformIdentity];
        [_toView removeFromSuperview];
        [_fromView setHidden:NO];
        [UIView animateWithDuration:.15f animations:^{
            _fromView.snapshot_.alpha = 0.f;
        } completion:^(BOOL finished) {
            [_fromView.snapshot_ removeFromSuperview];
            [_fromView setSnapshot_:nil];
        }];
    }
    [_containerView setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - 配置所需
- (void)initializeWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    _containerView = [transitionContext containerView];
    _fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    _toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    /**
    view for key 在模态形式的转场中可能为nil
    _fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    _toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    */
    _fromView = _fromController.view;
    _toView = _toController.view;
    /**标记 tabBar*/
    if (_tabBarTransitionType == MNTabBarTransitionTypeNone) return;
    if (!_fromController.tabBarController) return;
    if (_tabView && (_tabView.hidden || _tabView.alpha == 0.f)) return;
    if (_fromController.navigationController.viewControllers.count > (_transitionOperation + 1)) return;
    _tabBar = _tabView ? _tabView : _fromController.tabBarController.tabBar;
}

#pragma mark - 交互处理
- (void)interactiveTransitionAnimation {
    [_toView setHidden:NO];
    _toView.frame = [_transitionContext finalFrameForViewController:_toController];
    _toView.transform = CGAffineTransformMakeScale(.93f, .93f);
    [_containerView insertSubview:_toView belowSubview:_fromView];
    
    UIView *fromView = [_fromView transitionSnapshotView];
    [fromView makeTransitionShadow];
    [_containerView insertSubview:fromView aboveSubview:_fromView];
    _fromView.snapshot_ = fromView;
    
    [_fromView setHidden:YES];
    [_containerView setBackgroundColor:[UIColor blackColor]];
    [UIView animateWithDuration:_duration animations:^{
        _toView.transform = CGAffineTransformIdentity;
        fromView.left_mn = _containerView.width_mn;
    } completion:^(BOOL finished) {
        [self completeTransitionAnimation];
    }];
}

#pragma mark - Overwrite by Subclass
- (void)completeTransitionAnimation {
    [_transitionContext completeTransition:!_transitionContext.transitionWasCancelled];
}
- (void)pushTransitionAnimation {
    [self beginTabBarTransitionAnimation];
}
- (void)popTransitionAnimation {}

#pragma mark - TabBarTransitionAnimation
- (void)beginTabBarTransitionAnimation {
    if (!_tabBar) return;
    if (_tabBarTransitionType == MNTabBarTransitionTypeAdsorb) {
        UIView *snapshot = [_tabBar transitionSnapshotView];
        if (IS_IPAD) {
            snapshot.frame = UIEdgeInsetsInsetRect(_fromView.bounds, UIEdgeInsetsMake(0.f, 0.f, 0.f, _fromView.width_mn - snapshot.width_mn));
        } else {
            snapshot.frame = UIEdgeInsetsInsetRect(_fromView.bounds, UIEdgeInsetsMake(_fromView.height_mn - snapshot.height_mn, 0.f, 0.f, 0.f));
        }
        [_fromView addSubview:snapshot];
        _fromView.tabBar_ = snapshot;
        [_tabBar setHidden:YES];
    } else {
        [self tabBarSlideTransitionAnimation];
    }
}

/**转场时可能使用了TabBar截图, 现在复原*/
- (void)restoreTabBarTransitionSnapshot {
    if (_fromView.tabBar_) {
        [_fromView addSubview:_fromView.tabBar_];
    }
}

/**转场即将结束, 删除TabBar快照, 展现真正的TabBar*/
- (void)finishTabBarTransitionAnimation {
    if (!_tabBar) return;
    if (_tabBarTransitionType == MNTabBarTransitionTypeAdsorb) {
        [_tabBar setHidden:NO];
        [_toView.tabBar_ removeFromSuperview];
        [_toView setTabBar_:nil];
    } else {
        if (_toView.tabBar_) {
            [UIView animateWithDuration:.25f animations:^{
                _toView.tabBar_.alpha = 0.f;
            } completion:^(BOOL finished) {
                [_toView.tabBar_ removeFromSuperview];
                [_toView setTabBar_:nil];
            }];
        }
        [self tabBarSlideTransitionAnimation];
    }
}

- (void)tabBarSlideTransitionAnimation {
    if (IS_IPAD) {
        CGFloat margin = _transitionOperation == MNControllerTransitionOperationPush ? _tabBar.width_mn : 0.f;
        _tabBar.right_mn = margin;
        [_tabBar setHidden:NO];
        [UIView animateWithDuration:.25f animations:^{
            _tabBar.right_mn = _tabBar.width_mn - margin;
        } completion:nil];
    } else {
        CGFloat margin = _transitionOperation == MNControllerTransitionOperationPush ? _tabBar.height_mn : 0.f;
        _tabBar.top_mn = _containerView.height_mn - margin;
        [_tabBar setHidden:NO];
        [UIView animateWithDuration:.25f animations:^{
            _tabBar.top_mn = _containerView.height_mn - (_tabBar.height_mn - margin);
        } completion:nil];
    }
}

- (void)dealloc {
    MNDeallocLog;
}

@end


@implementation UIView (MNTransition)

- (UIView *)tabBar_ {
    return objc_getAssociatedObject(self, &MNTransitionTabBarAssociatedKey);
}

- (void)setTabBar_:(UIView *)tabBar_ {
    objc_setAssociatedObject(self, &MNTransitionTabBarAssociatedKey, tabBar_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)snapshot_ {
    return objc_getAssociatedObject(self, &MNTransitionSnapshotAssociatedKey);
}

- (void)setSnapshot_:(UIView *)snapshot_ {
    objc_setAssociatedObject(self, &MNTransitionSnapshotAssociatedKey, snapshot_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 捕获视图快照
- (UIView *)transitionSnapshotView {
    UIView *snapshot = [self snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = self.frame;
    return snapshot;
}

- (void)makeTransitionShadow {
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.f;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.layer.bounds] CGPath];
}

@end


@implementation UIViewController (MNControllerTransition)

- (MNTransitionAnimator *)pushTransitionAnimator {
    return nil;
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return nil;
}

- (void)mn_transition_viewWillAppear {}

@end
