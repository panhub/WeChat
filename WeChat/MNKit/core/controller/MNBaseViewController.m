//
//  MNBaseViewController.m
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNBaseViewController.h"

@interface MNBaseViewController ()
{
    @private
    CGRect _frame;
    BOOL _needReloadData;
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MNDragView *dragView;
@property (nonatomic, strong) MNEmptyView *dataEmptyView;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation MNBaseViewController
- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
         /**
         当取消Bar的半透明效果时, 非滚动视图的bouns会发生变化, 系统会为滚动视图增加边距和修改contentsize使内容不被遮挡
         
         这里我们手动控制BottomBar动画, 故不做操作
         self.hidesBottomBarWhenPushed = ![self isRootViewController];
        
         UINavigationBar/UITabBar的translucent属性解释：
         默认为YES，可以通过设置NO来强制使用非透明背景，如果导航条使用自定义背景图片，那么默认情况该属性的值由图片的alpha（透明度）决定，如果alpha的透明度小于1.0值为YES。如果手动设置translucent为YES并且使用自定义不透明图片，那么会自动设置系统透明度（小于1.0）在这个图片上。如果手动设置translucent为NO并且使用自定义带透明度（透明度小于0）的图片，那么系统会展示这张背景图片，只不过这张图片会使用事先确定的barTintColor进行不透明处理，若barTintColor为空，则会使用UIBarStyleBlack（黑色）或者UIBarStyleDefault（白色）。
        
         UINavigationBar/UITabBar的translucent属性解释：
         默认为YES，可以通过设置NO来强制使用非透明背景，如果导航条使用自定义背景图片，那么默认情况该属性的值由图片的alpha（透明度）决定，如果alpha的透明度小于1.0值为YES。如果手动设置translucent为YES并且使用自定义不透明图片，那么会自动设置系统透明度（小于1.0）在这个图片上。如果手动设置translucent为NO并且使用自定义带透明度（透明度小于0）的图片，那么系统会展示这张背景图片，只不过这张图片会使用事先确定的barTintColor进行不透明处理，若barTintColor为空，则会使用UIBarStyleBlack（黑色）或者UIBarStyleDefault（白色）。
          
         模态转场踩坑笔记:
         如果没有设置Custom在present动画完成后,presentingView会从视图结构中移除(只是移除,并未销毁),在disMiss的动画逻辑中,要把它放回视图结构中(不主动添加,UIKit也会自己添加);如果设置Custom,那么present完成后,它一直都在自己所属的视图结构中.
         UIModalPresentationCustom:转场时 containerView 并不担任 presentingView 的父视图,后者由 UIKit 另行管理. 在 present转场结束后,fromView(presentingView) 未被移出视图结构,在 dismissal 中,不要像其他转场中那样将 toView(presentingView) 加入 containerView 中,否则本来可见的 presentingView 将会被移除出自身所处的视图结构消失不见. 使用 Custom 模式时一定要注意到这一点
         对于 Custom 模式,我们可以参照其他转场里的处理规则来打理:present 转场结束后主动将 fromView(presentingView) 移出它的视图结构,并用一个变量来维护 presentingView 的父视图,以便在 dismissal 转场中恢复;在 dismissal 转场中,presentingView 的角色由原来的 fromView 切换成了 toView,我们再将其重新恢复它原来的视图结构中. 测试表明这样做是可行的. 但是这样一来,需要在转场代理中维护一个动画控制器并且这个动画控制器要维护 presentingView 的父视图,这样的代价也是巨大的.
         建议不要干涉UIKit对 Modal 转场的处理,我们去适应它. 在 Custom 模式下,由于 presentingView 不受 containerView 管理,在 dismissal 转场中不要像其他的转场那样将 toView(presentingView) 加入 containerView,否则 presentingView 将消失不见,而应用则也很可能假死;在 presentation 转场中,最好不要手动将 fromView(presentingView) 移出其父视图,这样就不用特意去维护其父视图。
         */
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.title = title;
        [self initialized];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self->_frame = frame;
        self->_childController = self.transitionAnimationStyle != MNControllerTransitionStyleModal;
        [self initialized];
    }
    return self;
}

- (void)initialized {
    self->_firstAppear = YES;
    self->_contentEdges = (self.isChildViewController || !self.transitionAnimationStyle || !self.isRootViewController) ? MNContentEdgeNone : MNContentEdgeBottom;
    if (self.transitionAnimationStyle == MNControllerTransitionStyleModal) self.transitioningDelegate = self;
    [self layoutExtendAdjustEdges];
}

#pragma mark - Life Cycle
#pragma mark - loadView
- (void)loadView {
    UIView *view = [[UIView alloc]initWithFrame:self.frame];
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    self.view = view;
    [self createView];
}

- (void)createView {
    CGRect frame = self.view.bounds;
    if (self.contentEdges & MNContentEdgeBottom) {
        //不是子控制器 && 不是模态转场 && (预留导航和标签位置 || 预留标签位置)
        UIEdgeInsets insets = UIEdgeInsetsMake(0.f, 0.f, MN_TAB_BAR_HEIGHT, 0.f);
        frame = UIEdgeInsetsInsetRect(self.view.bounds, insets);
    }
    //创建内容视图
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.userInteractionEnabled = YES;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    self.contentView = contentView;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self handEvents];
    [self loadData];
}

#pragma mark - viewWillAppear
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self->_appear = YES;
    [self reloadDataIfNeeded];
    if ([self isChildViewController]) return;
    [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle] animated:YES];
}

#pragma mark - viewDidAppear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self isChildViewController]) return;
    [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle] animated:YES];
    if ([self transitionAnimationStyle] == MNControllerTransitionStyleModal) return;
    [self.tabBarController.tabView setHidden:![self isRootViewController]];
}

#pragma mark - viewWillDisappear
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    self->_firstAppear = NO;
    self->_appear = NO;
}

#pragma mark - LoadData
- (void)loadData {
    /**基类自行处理的请求, 需要 httpRequest 的支持, 注意循环引用问题*/
    if (!_httpRequest) return;
    __weak typeof(self) weakself = self;
    [_httpRequest loadData:^{
        [weakself prepareLoadData:weakself.httpRequest];
    } completion:^(MNURLResponse *response) {
        [weakself.contentView closeDialog];
        [weakself loadDataFinishWithRequest:weakself.httpRequest];
    }];
}

#pragma mark - ReloadData
- (void)reloadData {
    if (_httpRequest) {
        [_httpRequest cancel];
        [_httpRequest prepareReloadData];
    }
    [self loadData];
}

- (void)setNeedsReloadData {
    _needReloadData = YES;
}

- (void)reloadDataIfNeeded {
    if (_needReloadData) {
        _needReloadData = NO;
        [self reloadData];
    }
}

#pragma mark - LoadDataFinish
- (BOOL)loadDataFinishWithRequest:(__kindof MNHTTPDataRequest *)request {
    BOOL isEmpty = request.isDataEmpty;
    BOOL isSucceed = request.isSucceed;
    [self showEmptyViewNeed:isEmpty
                      image:nil
                    message:((isEmpty && isSucceed) ? @"暂无数据" : request.response.message)
                      title:@"刷新"
                       type:MNEmptyEventTypeReload];
    if (isEmpty) {
        /// 告知已展示空数据视图
        [self didMoveEmptyView:_dataEmptyView toView:_dataEmptyView.superview];
    } else if (!isSucceed) {
        /// 数据不为空, 但请求失败了, 弹窗提示错误信息
        [self.contentView showInfoDialog:request.response.message];
    }
    //无论结果如何都告知请求结束了
    [self didLoadDataWithRequest:request];
    return (isSucceed && !isEmpty);
}

//展示无数据视图
- (void)showEmptyViewNeed:(BOOL)isNeed
                    image:(UIImage *)image
                  message:(NSString *)message
                    title:(NSString *)title
                     type:(MNEmptyEventType)type {
    if (isNeed) {
        UIView *superview = [self emptyViewSuperview];
        if (!superview) return;
        self.dataEmptyView.image = image;
        _dataEmptyView.message = message;
        _dataEmptyView.buttonTitle = title;
        _dataEmptyView.type = type;
        [superview addSubview:_dataEmptyView];
        [_dataEmptyView show];
    } else {
        [self dismissEmptyView];
    }
}

- (void)dismissEmptyView {
    [_dataEmptyView dismiss];
}

- (void)updateEmptyView {
    if (!_dataEmptyView || !_dataEmptyView.superview || _dataEmptyView.alpha == 0.f) return;
    CGRect frame = [self emptyViewFrame];
    UIView *superview = [self emptyViewSuperview];
    if (superview == _dataEmptyView.superview && CGRectEqualToRect(frame, _dataEmptyView.frame)) return;
    [_dataEmptyView removeFromSuperview];
    _dataEmptyView.frame = frame;
    [superview addSubview:_dataEmptyView];
    [self didMoveEmptyView:_dataEmptyView toView:superview];
}

//空数据视图
- (MNEmptyView *)dataEmptyView {
    if (!_dataEmptyView) {
        _dataEmptyView = [[MNEmptyView alloc]initWithFrame:self.emptyViewFrame];
        _dataEmptyView.delegate = self;
    }
    return _dataEmptyView;
}

- (MNEmptyView *)emptyView {
    return _dataEmptyView;
}

#pragma mark - MNEmptyViewDelegate
- (void)dataEmptyViewButtonClicked:(MNEmptyView *)emptyView {
    if (emptyView.type != MNEmptyEventTypeOther) [emptyView dismiss];
    if (emptyView.type == MNEmptyEventTypeReload) {
        [self reloadData];
    } else if (emptyView.type == MNEmptyEventTypeLoad) {
        [self loadData];
    }
}

#pragma mark - MNDragView
- (MNDragView *)dragView {
    if (!_dragView) {
        MNDragView *dragView = [[MNDragView alloc] init];
        dragView.delegate = self;
        [self.view addSubview:dragView];
        _dragView = dragView;
    }
    return _dragView;
}

#pragma mark - MNSlideViewMargin
- (void)dragViewDidClicking:(MNDragView *)slideView {}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MNTransitionAnimator *animator = [self pushTransitionAnimator] ? : [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSheetModal];
    animator.transitionOperation = MNControllerTransitionOperationPush;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MNTransitionAnimator *animator = [self popTransitionAnimator] ? : [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeDefaultModal];
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

#pragma mark - controller config
- (void)handEvents {}
- (BOOL)isChildViewController {
    return self.childController;
}
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleStack;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    }
    return UIStatusBarStyleDefault;
}
- (CGRect)emptyViewFrame {
    return _contentView.bounds;
}
- (UIView *)emptyViewSuperview {
    return _contentView;
}
- (void)prepareLoadData:(__kindof MNHTTPDataRequest *)request {
    if (!self.contentView.isDialoging) [self.contentView showLoadDialog:MN_LOADING];
}
- (void)didMoveEmptyView:(MNEmptyView *)emptyView toView:(__kindof UIView *)superview {}
- (void)didLoadDataWithRequest:(__kindof MNHTTPDataRequest *)request {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
/*
#pragma mark - 按钮在底部边缘时不响应的问题
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return  UIRectEdgeBottom;
}
*/
#pragma mark - 屏幕旋转与支持方向
/**YES允许旋转, NO禁止*/
- (BOOL)shouldAutorotate {
    return NO;
}
/**返回支持的方向*/
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
/**由模态推出的视图控制器 优先支持的屏幕方向*/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Lazy Load
- (CGRect)frame {
    return CGSizeEqualToSize(_frame.size, CGSizeZero) ? [[UIScreen mainScreen] bounds] : _frame;
}

#pragma mark - dealloc
- (void)dealloc {
    if (_httpRequest && _httpRequest.isLoading) [_httpRequest cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MNDeallocLog;
}

@end
#pragma clang diagnostic pop
