//
//  MNAssetSelectView.h
//  MNKit
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  预览时底部选择图

#import <UIKit/UIKit.h>
@class MNAsset, MNAssetSelectView;

@protocol MNAssetSelectViewDelegate <NSObject>

- (void)selectView:(MNAssetSelectView *)selectView didSelectItemAtIndex:(NSInteger)index;

@end

#define MNAssetSelectBottomMinMargin   10.f
#define MNAssetSelectBottomMaxMargin  65.f

@interface MNAssetSelectView : UIView

/**选择索引*/
@property (nonatomic) NSInteger selectIndex;

/**交互代理*/
@property (nonatomic, weak) id<MNAssetSelectViewDelegate> delegate;

/**
 依据资源模型初始化
 @param frame 位置区域
 @param assets 资源模型集合
 */
- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray <MNAsset *>*)assets;

/**更新底部区域*/
- (void)updateBottomMarginIfNeeded;

@end
