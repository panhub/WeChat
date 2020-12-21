//
//  MNTailorHandler.h
//  MNKit
//
//  Created by Vicent on 2020/8/10.
//  视频裁剪控制

#import <UIKit/UIKit.h>
#import "MNVideoKeyfram.h"
@class MNTailorHandler;

UIKIT_EXTERN const CGFloat MNTailorHandlerAnimationDuration;

@protocol MNTailorHandlerDelegate <NSObject>
@optional
/**左滑手开始拖拽*/
- (void)tailorLeftHandlerBeginDragging:(MNTailorHandler *_Nonnull)tailorHandler;
/**左滑手拖拽中*/
- (void)tailorLeftHandlerDidDragging:(MNTailorHandler *_Nonnull)tailorHandler;
/**左滑手停止拖拽*/
- (void)tailorLeftHandlerEndDragging:(MNTailorHandler *_Nonnull)tailorHandler;
/**右滑手开始拖拽*/
- (void)tailorRightHandlerBeginDragging:(MNTailorHandler *_Nonnull)tailorHandler;
/**右滑手拖拽中*/
- (void)tailorRightHandlerDidDragging:(MNTailorHandler *_Nonnull)tailorHandler;
/**右滑手拖拽中*/
- (void)tailorRightHandlerEndDragging:(MNTailorHandler *_Nonnull)tailorHandler;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MNTailorHandler : UIView
/**正常颜色*/
@property (nonatomic, copy) UIColor *normalColor;
/**高亮颜色*/
@property (nonatomic, copy) UIColor *highlightedColor;
/**滑手上路径颜色*/
@property (nonatomic, copy) UIColor *pathColor;
/**控件大小约束*/
@property (nonatomic) UIEdgeInsets borderInset;
/**滑手的路径宽度*/
@property (nonatomic) CGFloat lineWidth;
/**是否是高亮状态*/
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
/**左滑手*/
@property (nonatomic, strong, readonly) UIView *leftHandler;
/**右滑手*/
@property (nonatomic, strong, readonly) UIView *rightHandler;
/**顶部分割线*/
@property (nonatomic, strong, readonly) UIView *topSeparator;
/**底部分割线*/
@property (nonatomic, strong, readonly) UIView *bottomSeparator;
/**滑手扩大区域*/
@property (nonatomic) UIEdgeInsets handlerTouchInset;
/**最小间隔*/
@property (nonatomic) CGFloat minHandlerInterval;
/**圆角*/
@property (nonatomic) CGFloat handlerRadius;
/**是否在拖拽滑手*/
@property (nonatomic, getter=isDragging) BOOL dragging;
/**建议最初状态*/
@property (nonatomic, weak) id<MNTailorHandlerDelegate> delegate;

/**
 加载子视图
 */
- (void)reloadSubviews;

/**
 设置高亮状态
 @param highlighted 是否高亮
 @param animated 是否动态
 */
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

/**
 检查是否需要高亮
 @param animated 是否动态
 */
- (void)inspectHighlightedAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
