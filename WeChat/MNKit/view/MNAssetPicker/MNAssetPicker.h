//
//  MNAssetPicker.h
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片选择器 <2019/8/30 - 2019/9/15>

#import "MNNavigationController.h"
#if __has_include(<Photos/Photos.h>)
#import "MNAssetPickConfiguration.h"
#import "MNAssetHelper.h"
#import "MNAssetBrowser.h"

/**
 资源选择器类型
 - MNAssetPickerTypeNormal: 选择器
 - MNAssetPickerTypeCapturing: 录像/照相
 */
typedef NS_ENUM(NSInteger, MNAssetPickerType) {
    MNAssetPickerTypeNormal = 0,
    MNAssetPickerTypeCapturing
};

NS_ASSUME_NONNULL_BEGIN

@interface MNAssetPicker : MNNavigationController
/**
 资源选择器类型
 */
@property (nonatomic, readonly) MNAssetPickerType type;
/**
 资源选择器配置
 */
@property (nonatomic, readonly, weak) MNAssetPickConfiguration *configuration;

/**
 资源选择器实例化入口
 @return 资源选择器
 */
+ (instancetype)picker;

/**
 资源获取器实例化入口
 @return 资源获取器
 */
+ (instancetype)capturer;

/**
 依据类型实例化
 @param type 选择器类型
 @return 资源选择器
 */
- (instancetype)initWithType:(MNAssetPickerType)type;

/**
 弹出选择器
 @param pickingHandler 选择回调
 @param cancelHandler 取消回调
 */
- (void)presentWithPickingHandler:(void(^)(MNAssetPicker *picker, NSArray <MNAsset *>* _Nullable assets))pickingHandler
                    cancelHandler:(void(^_Nullable)(MNAssetPicker *picker))cancelHandler;

/**
 弹出选择器
 @param parentController 容器控制器
 @param pickingHandler 选择回调
 @param cancelHandler 取消回调
 */
- (void)presentInController:(UIViewController * _Nullable)parentController
            pickingHandler:(void(^)(MNAssetPicker *picker, NSArray <MNAsset *>*_Nullable assets))pickingHandler
             cancelHandler:(void(^_Nullable)(MNAssetPicker *picker))cancelHandler;

@end
NS_ASSUME_NONNULL_END
#endif
