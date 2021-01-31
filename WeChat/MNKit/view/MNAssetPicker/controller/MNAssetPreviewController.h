//
//  MNAssetPreviewController.h
//  MNKit
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  图片/视频资源预览

#import "MNListViewController.h"
@class MNAsset, MNAssetPreviewController;

NS_ASSUME_NONNULL_BEGIN

/**
 右按钮
 - MNAssetPreviewEventNone: 没有
 - MNAssetPreviewEventDone: 确定
 - MNAssetPreviewEventSelect: 选择
 */
typedef NS_OPTIONS(NSInteger, MNAssetPreviewEvents) {
    MNAssetPreviewEventNone = 0,
    MNAssetPreviewEventDone = 1 << 1,
    MNAssetPreviewEventSelect = 1 << 2
};

@protocol MNAssetPreviewDelegate <NSObject>
/**导航有按钮点击事件*/
- (void)previewController:(MNAssetPreviewController *)previewController rightBarItemTouchUpInside:(UIControl *)sender;
@end

@interface MNAssetPreviewController : MNListViewController

/**右按钮事件*/
@property (nonatomic) MNAssetPreviewEvents events;

/**释放时同时清理资源缓存*/
@property (nonatomic, getter=isCleanAssetWhenDealloc) BOOL cleanAssetWhenDealloc;

/**预览资源*/
@property (nonatomic, copy) NSArray <MNAsset *>*assets;

/**当前展示索引*/
@property (nonatomic, readonly) NSInteger currentDisplayIndex;

/**是否允许自动播放*/
@property (nonatomic, getter=isAllowsAutoPlaying) BOOL allowsAutoPlaying;

/**交互代理*/
@property (nonatomic, weak, nullable) id<MNAssetPreviewDelegate> delegate;

/**
 依据预览资源初始化
 @param assets 预览资源
 @return 预览控制器
 */
- (instancetype)initWithAssets:(NSArray <MNAsset *>*)assets;

@end

NS_ASSUME_NONNULL_END
