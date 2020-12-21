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

@protocol MNAssetPreviewDelegate <NSObject>
/**选择了资源*/
- (void)didSelectAsset:(MNAsset *)model;
/**导航有按钮点击事件*/
- (void)previewControllerDoneButtonClicked:(MNAssetPreviewController *)previewController;
@end

@interface MNAssetPreviewController : MNListViewController

/**是否允许选择*/
@property (nonatomic) BOOL allowsSelect;

/**释放时同时清理资源缓存*/
@property (nonatomic, getter=isCleanAssetWhenDealloc) BOOL cleanAssetWhenDealloc;

/**预览资源*/
@property (nonatomic, copy) NSArray <MNAsset *>*assets;

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
