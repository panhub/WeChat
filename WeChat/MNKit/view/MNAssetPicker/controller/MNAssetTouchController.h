//
//  MNAssetTouchController.h
//  MNKit
//
//  Created by Vincent on 2019/9/6.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNExtendViewController.h"
@class MNAsset, MNAssetTouchController;

typedef NS_ENUM(NSInteger, MNAssetTouchState) {
    MNAssetTouchStateNormal = 0, // 轻压
    MNAssetTouchStateWeight // 重压
};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@protocol MNAssetTouchDelegate <NSObject>
/**回调资源选择器*/
- (void)didSelectAsset:(MNAsset *_Nonnull)model;
/**确定按钮点击*/
- (void)touchControllerDoneButtonClicked:(MNAssetTouchController *_Nonnull)touchController;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MNAssetTouchController : MNExtendViewController
/**是否允许选择*/
@property (nonatomic) BOOL allowsSelect;
/**资源选项*/
@property (nonatomic, strong) MNAsset *asset;
/**展示状态*/
@property (nonatomic) MNAssetTouchState state;
/**释放时同时清理资源缓存*/
@property (nonatomic, getter=isCleanAssetWhenDealloc) BOOL cleanAssetWhenDealloc;
/**交互代理*/
@property (nonatomic, weak, nullable) id<MNAssetTouchDelegate> delegate;
#ifdef NSFoundationVersionNumber_iOS_9_0
/**按钮选项*/
@property (nonatomic, copy, nullable) NSArray<id<UIPreviewActionItem>>*actions;
#endif
@end

NS_ASSUME_NONNULL_END
#pragma clang diagnostic pop
