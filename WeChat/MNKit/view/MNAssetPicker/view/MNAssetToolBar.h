//
//  MNAssetToolBar.h
//  MNChat
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片选择底部控制栏

#import <UIKit/UIKit.h>
@class MNAssetToolBar;

@protocol MNAssetToolDelegate <NSObject>
@optional;
- (void)assetToolBarLeftBarItemClicked:(MNAssetToolBar *)toolBar;
- (void)assetToolBarRightBarItemClicked:(MNAssetToolBar *)toolBar;
- (void)assetToolBarClearButtonClicked:(MNAssetToolBar *)toolBar;
@end

@interface MNAssetToolBar : UIView

@property (nonatomic) NSUInteger count;

@property (nonatomic, weak) id<MNAssetToolDelegate> delegate;

@end
