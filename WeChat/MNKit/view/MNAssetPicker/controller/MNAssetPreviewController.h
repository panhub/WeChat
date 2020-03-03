//
//  MNAssetPreviewController.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  图片/视频资源预览

#import "MNListViewController.h"
@class MNAsset, MNAssetPreviewController;

@protocol MNAssetPreviewDelegate <NSObject>

- (void)didSelectAsset:(MNAsset *)model;

- (void)previewControllerDoneButtonClicked:(MNAssetPreviewController *)previewController;

@end

@interface MNAssetPreviewController : MNListViewController

@property (nonatomic) BOOL allowsSelect;

@property (nonatomic, copy) NSArray <MNAsset *>*assets;

@property (nonatomic, weak) id<MNAssetPreviewDelegate> delegate;

- (instancetype)initWithAssets:(NSArray <MNAsset *>*)assets;

@end
