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

/**
 右按钮
 - MNAssetTouchEventNone: 没有
 - MNAssetTouchEventDone: 确定
 - MNAssetTouchEventSelect: 选择
 */
typedef NS_OPTIONS(NSInteger, MNAssetTouchEvents) {
    MNAssetTouchEventNone = 0,
    MNAssetTouchEventDone = 1 << 1,
    MNAssetTouchEventSelect = 1 << 2
};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

NS_ASSUME_NONNULL_BEGIN

@protocol MNAssetTouchDelegate <NSObject>
/**导航有按钮点击事件*/
- (void)touchController:(MNAssetTouchController *)touchController rightBarItemTouchUpInside:(UIControl *)sender;
@end

@interface MNAssetTouchController : MNExtendViewController
/**右按钮事件*/
@property (nonatomic) MNAssetTouchEvents events;
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
