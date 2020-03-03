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
@implementation MNBaseViewController
- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
        /**
         当取消Bar的半透明效果时, 非滚动视图的bouns会发生变化, 系统会为滚动视图增加边距和修改contentsize使内容不被遮挡
         */
        /**
         这里我们手动控制BottomBar动画, 故不做操作
         self.hidesBottomBarWhenPushed = ![self isRootViewController];
         */
        /**
         UINavigationBar/UITabBar的translucent属性解释：
         默认为YES，可以通过设置NO来强制使用非透明背景，如果导航条使用自定义背景图片，那么默认情况该属性的值由图片的alpha（透明度）决定，如果alpha的透明度小于1.0值为YES。如果手动设置translucent为YES并且使用自定义不透明图片，那么会自动设置系统透明度（小于1.0）在这个图片上。如果手动设置translucent为NO并且使用自定义带透明度（透明度小于0）的图片，那么系统会展示这张背景图片，只不过这张图片会使用事先确定的barTintColor进行不透明处理，若barTintColor为空，则会使用UIBarStyleBlack（黑色）或者UIBarStyleDefault（白色）。
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
    if (self = [self init]) {
        self.title = title;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        /// 这里使用父类初始化是为了子类在 -initialized 里使用正确的frame
        self->_frame = frame;
        self->_childController = YES;
        [self initialized];
    }
    return self;
}

- (void)initialized {
    self->_firstAppear = YES;
    self->_contentEdges = (self.isChildViewController || !self.transitionAnimationStyle || !self.isRootViewController) ? MNContentEdgeNone : MNContentEdgeBottom;
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
        UIEdgeInsets insets = UIEdgeInsetsMake(0.f, (IS_IPAD ? TAB_BAR_HEIGHT : 0.f), (IS_IPAD ? 0.f : TAB_BAR_HEIGHT), 0.f);
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
    [self loadData];
}

#pragma mark - viewWillAppear
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self->_appear = YES;
    [self reloadDataIfNeeded];
}

- (void)mn_transition_viewWillAppear {
    if ([self isChildViewController]) return;
    [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle] animated:YES];
}

#pragma mark - viewDidAppear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self isChildViewController]) return;
    [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle] animated:NO];
    if ([self transitionAnimationStyle] == MNControllerTransitionStyleModel) return;
    [self.tabBarController.tabView setHidden:![self isRootViewController]];
}

#pragma mark - viewWillDisappear
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    self->_firstAppear = NO;
    self->_appear = NO;
}

#pragma mark - viewDidDisappear
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark - LoadData
- (void)loadData {
    /**基类自行处理的请求, 需要 httpRequest 的支持, 注意循环引用问题*/
    if (!_httpRequest || _httpRequest.isLoading) return;
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
    [_httpRequest cancel];
    [_httpRequest prepareReloadData];
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
    BOOL empty = request.isDataEmpty;
    BOOL succeed = request.isSucceed;
    [self showEmptyViewNeed:empty
                      image:nil
                    message:request.response.message
                      title:@"刷新"
                       type:MNEmptyEventTypeReload];
    if (empty) {
        /// 告知已展示空数据视图
        [self didMoveEmptyViewToSuperview:_dataEmptyView.superview];
    } else {
        /// 数据不为空, 但请求失败了, 弹窗提示错误信息
        if (!succeed) {
            [self.contentView showInfoDialog:request.response.message];
        }
    }
    //无论结果如何都告知请求结束了
    [self didLoadDataWithRequest:request];
    return (succeed && !empty);
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
        //_dataEmptyView.backgroundColor = superview.backgroundColor;
        [superview addSubview:_dataEmptyView];
        [_dataEmptyView show];
    } else {
        [self dismissEmptyView];
    }
}

- (void)dismissEmptyView {
    [_dataEmptyView dismiss];
}

//空数据视图
- (MNEmptyView *)dataEmptyView {
    if (!_dataEmptyView) {
        MNEmptyView *emptyView = [[MNEmptyView alloc]initWithFrame:self.emptyViewFrame];
        emptyView.delegate = self;
        emptyView.buttonTitleColor = TEXT_COLOR;
        _dataEmptyView = emptyView;
    }
    return _dataEmptyView;
}

- (MNEmptyView *)emptyView {
    return _dataEmptyView;
}

#pragma mark - MNEmptyViewDelegate
- (void)dataEmptyViewButtonClicked:(MNEmptyView *)emptyView {
    if (emptyView.type == MNEmptyEventTypeReload) {
        [self reloadData];
        [self.contentView showDotDialog];
    } else if (emptyView.type == MNEmptyEventTypeLoad) {
        [self loadData];
        [self.contentView showDotDialog];
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

#pragma mark - MNDragViewDelegate
- (void)dragViewDidClicking:(MNDragView *)slideView {}

#pragma mark - controller config
- (BOOL)isChildViewController {
    return self.childController;
}
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleStack;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (CGRect)emptyViewFrame {
    return _contentView.bounds;
}
- (UIView *)emptyViewSuperview {
    return _contentView;
}
- (void)prepareLoadData:(__kindof MNHTTPDataRequest *)request {
    [self dismissEmptyView];
    if (self.httpRequest.isFirstLoading) {
        [self.contentView showLoadDialog:MN_LOADING];
    }
}
- (void)didMoveEmptyViewToSuperview:(__kindof UIView *)view {}
- (void)didLoadDataWithRequest:(__kindof MNHTTPDataRequest *)request {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 按钮在底部边缘时不响应的问题
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return  UIRectEdgeBottom;
}

#pragma mark - 屏幕旋转与支持方向
/**YES允许旋转, NO禁止*/
- (BOOL)shouldAutorotate {
    return NO;
}
/**返回支持的方向*/
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return IS_IPAD ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}
/**由模态推出的视图控制器 优先支持的屏幕方向*/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return IS_IPAD ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
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
