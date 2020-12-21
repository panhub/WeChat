//
//  MNAssetToolBar.h
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片选择底部控制栏

#import <UIKit/UIKit.h>
@class MNAssetToolBar, MNAsset, MNAssetPickConfiguration;

@protocol MNAssetToolDelegate <NSObject>
@optional;
- (void)assetToolBarLeftBarItemClicked:(MNAssetToolBar *)toolBar;
- (void)assetToolBarRightBarItemClicked:(MNAssetToolBar *)toolBar;
- (void)assetToolBarClearButtonClicked:(MNAssetToolBar *)toolBar;
@end

@interface MNAssetToolBar : UIView

/**配置信息*/
@property (nonatomic, weak) MNAssetPickConfiguration *configuration;

/**选择的资源*/
@property (nonatomic, copy) NSArray <MNAsset *>*assets;

/**交互代理*/
@property (nonatomic, weak) id<MNAssetToolDelegate> delegate;

@end
