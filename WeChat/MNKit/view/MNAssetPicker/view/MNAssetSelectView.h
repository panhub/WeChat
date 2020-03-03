//
//  MNAssetSelectView.h
//  MNFoundation
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

@property (nonatomic) NSInteger selectIndex;

@property (nonatomic, weak) id<MNAssetSelectViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray <MNAsset *>*)assets;

- (void)updateBottomMarginIfNeeded;

@end
