//
//  MNAssetBrowser.h
//  MNKit
//
//  Created by Vincent on 2019/9/7.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  资源浏览器

#import <UIKit/UIKit.h>
#import "MNAlertProtocol.h"
@class MNAssetBrowser;

NS_ASSUME_NONNULL_BEGIN

@protocol MNAssetBrowseDelegate <NSObject>
@optional;
- (void)assetBrowserWillPresent:(MNAssetBrowser *)assetBrowser;
- (void)assetBrowserDidPresent:(MNAssetBrowser *)assetBrowser;
- (void)assetBrowserWillDismiss:(MNAssetBrowser *)assetBrowser;
- (void)assetBrowserDidDismiss:(MNAssetBrowser *)assetBrowser;
- (void)assetBrowser:(MNAssetBrowser *)assetBrowser didSelectAsset:(MNAsset *)asset;
- (void)assetBrowser:(MNAssetBrowser *)assetBrowser didScrollToIndex:(NSInteger)index;
@end

UIKIT_EXTERN const NSInteger MNAssetBrowserTag;
UIKIT_EXTERN const CGFloat MNAssetBrowsePresentAnimationDuration;
UIKIT_EXTERN const CGFloat MNAssetBrowseDismissAnimationDuration;

@interface MNAssetBrowser : UIView<MNAlertProtocol>
/**
 是否允许选择
 */
@property (nonatomic) BOOL allowsSelect;
/**
 是否允许自动播放<针对视频/LivePhoto>
 */
@property (nonatomic, getter=isAllowsAutoPlaying) BOOL allowsAutoPlaying;
/**
 是否隐藏状态栏
 */
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
/**
 释放时同时清理资源缓存
 */
@property (nonatomic, getter=isCleanAssetWhenDealloc) BOOL cleanAssetWhenDealloc;
/**
 状态栏颜色
 */
@property (nonatomic) UIStatusBarStyle statusBarStyle;
/**
 浏览资源, 不可为空
 */
@property (nonatomic, copy) NSArray <MNAsset *>*assets;
/**
 交互代理
 */
@property (nonatomic, weak, nullable) id<MNAssetBrowseDelegate> delegate;

/**
 资源浏览器构造方法
 @param assets 资源数组
 @return 资源浏览器
 */
- (instancetype)initWithAssets:(NSArray <MNAsset *>*)assets;
/**
 从指定资源处展示
 @param index 指定起始索引
 */
- (void)presentFromIndex:(NSInteger)index;
/**
 从指定资源处展示
 @param index 指定起始索引
 @param animated 是否动态展示
 */
- (void)presentFromIndex:(NSInteger)index animated:(BOOL)animated;
/**
 从指定资源处展示
 @param index 指定起始索引
 @param animated 是否动态展示
 @param completion 展示结束回调
 */
- (void)presentFromIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
/**
 在指定父视图中展示资源浏览器
 @param superview 指定父视图
 @param index 指定起始索引
 @param animated 是否动态展示
 @param completion 展示结束回调
 */
- (void)presentInView:(UIView *_Nullable)superview fromIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
/**
 展示图片
 @param containerView 图片视图
*/
+ (void)presentContainer:(UIView *)containerView;
/**
 展示图片
 @param containerView 起始视图
 @param animatedImage 使用的图片
 */
+ (void)presentContainer:(UIView *)containerView usingImage:(UIImage *_Nullable)animatedImage;
/**
 展示图片
 @param containerView 起始视图
 @param animatedImage 使用的图片
 @param animated 是否动态展示
 @param completionHandler 展示结束回调
 */
+ (void)presentContainer:(UIView *)containerView usingImage:(UIImage *_Nullable)animatedImage animated:(BOOL)animated completion:(void (^_Nullable)(void))completionHandler;
/**
 取消资源浏览器的展示
 */
- (void)dismiss;
/**
 取消资源浏览器的展示
 @param animated 是否动态展示
 @param completion 展示结束回调
 */
- (void)dismissWithAnimated:(BOOL)animated completion:(void (^_Nullable)(void))completion;

@end
NS_ASSUME_NONNULL_END
