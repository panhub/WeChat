//
//  MNBaseViewController.h
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//  控制器基类

#import <UIKit/UIKit.h>
#import "MNLoadDialog.h"
#import "MNEmptyView.h"
#import "MNHTTPDataRequest.h"
#import "UIDevice+MNHelper.h"
#import "NSString+MNHelper.h"
#import "UIView+MNLayout.h"
#import "UIView+MNHelper.h"
#import "MNConfiguration.h"
#import "MNExtern.h"
#import "UIViewController+MNInterface.h"
#import "UIViewController+MNHelper.h"
#import "MNDragView.h"

/**
 内容视图扩展类型
 - MNContentEdgeNone: 不预留<即self.view.bounds>
 - MNContentEdgeTop: 预留顶部导航栏
 - MNContentEdgeBottom: 预留底部标签栏
 */
typedef NS_OPTIONS(NSUInteger, MNContentEdges) {
    MNContentEdgeNone = 0,
    MNContentEdgeTop = 1 << 0,
    MNContentEdgeBottom = 1 << 1
};

@interface MNBaseViewController : UIViewController<MNEmptyViewDelegate, MNDragViewDelegate, UIViewControllerTransitioningDelegate>
/**
 标记视图是否在显示状态
 */
@property (nonatomic, readonly, getter=isAppear) BOOL appear;
/**
 是否第一次Appear
 */
@property (nonatomic, readonly, getter=isFirstAppear) BOOL firstAppear;
/**
 view坐标尺寸
 */
@property (nonatomic, readonly) CGRect frame;
/**
 内容视图约束
 */
@property (nonatomic) MNContentEdges contentEdges;
/**
 标记是否是加载在其它控制器上的子控制器
 便于直接实例化的子控制指定值
 */
@property (nonatomic) BOOL childController;
/**
 内容视图
 */
@property (nonatomic, strong, readonly) UIView *contentView;
/**
 浮窗视图
 */
@property (nonatomic, readonly, strong) MNDragView *dragView;
/**
 空数据视图
 */
@property (nonatomic, readonly, strong) MNEmptyView *emptyView;
/**
 父类请求实例
 */
@property (nonatomic, strong) __kindof MNHTTPDataRequest *httpRequest;


#pragma mark - initialize
- (instancetype)initWithTitle:(NSString *)title __attribute__((objc_requires_super));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((objc_requires_super));
- (void)initialized __attribute__((objc_requires_super));
- (void)createView __attribute__((objc_requires_super));

#pragma mark - request
/**
 数据请求
 */
- (void)loadData;

/**
 处理事件
 */
- (void)handEvents;

/**
 重载数据
 */
- (void)reloadData;

/**
 需要重载数据flag, 视图即将出现时会检查重载
 */
- (void)setNeedsReloadData;

/**
 检查重载数据flag, 立即重载数据
 */
- (void)reloadDataIfNeeded;

/**
 即将开始请求数据
 @param request 请求体
 */
- (void)prepareLoadData:(__kindof MNHTTPDataRequest *)request;

/**
 * 数据请求结束
 *@param request 请求对象
 *@return  是否需要处理结果<请求失败且数据为空则返回NO>
 */
- (BOOL)loadDataFinishWithRequest:(__kindof MNHTTPDataRequest *)request;

/**
 已经添加空数据视图
 @param emptyView 空视图
 @param superview 空视图的父视图
 */
- (void)didMoveEmptyView:(MNEmptyView *)emptyView toView:(__kindof UIView *)superview;

/**
 数据请求结束<无论是否成功>
 @param request 请求体
 */
- (void)didLoadDataWithRequest:(__kindof MNHTTPDataRequest *)request;

#pragma mark - view set
/**
 * 显示空数据视图
 *@param isNeed 判断条件
 *@param image 显示的图片
 *@param message   提示信息
 *@param title 按钮标题
 *@param type   按钮需要操作的类型
 */
- (void)showEmptyViewNeed:(BOOL)isNeed
                    image:(UIImage *)image
                  message:(NSString *)message
                    title:(NSString *)title
                     type:(MNEmptyEventType)type;

/**
 为空数据提示图提供父视图
 @return 空数据视图父视图
 */
- (UIView *)emptyViewSuperview;

/**
 空数据视图的位置
 @return 坐标,大小
 */
- (CGRect)emptyViewFrame;

/**
 删除空数据视图
 */
- (void)dismissEmptyView;

/**
 更新空数据视图
 */
- (void)updateEmptyView;

@end
