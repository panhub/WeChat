//
//  MNAssetTouchController.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/6.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNExtendViewController.h"
@class MNAsset, MNAssetTouchController;

typedef NS_ENUM(NSInteger, MNAssetTouchState) {
    MNAssetTouchStateNormal = 0,
    MNAssetTouchStateWeight
};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@protocol MNAssetTouchDelegate <NSObject>

- (void)didSelectAsset:(MNAsset *)model;

- (void)touchControllerDoneButtonClicked:(MNAssetTouchController *)touchController;

@end

@interface MNAssetTouchController : MNExtendViewController

@property (nonatomic) BOOL allowsSelect;

@property (nonatomic, strong) MNAsset *asset;

@property (nonatomic, assign) MNAssetTouchState  state;

@property (nonatomic, copy) NSArray<id<UIPreviewActionItem>>*actions;

@property (nonatomic, weak) id<MNAssetTouchDelegate> delegate;

@end

#pragma clang diagnostic pop

