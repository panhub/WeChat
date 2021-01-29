//
//  MNAssetPickConfiguration.h
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源选择器配置模型

#import <Foundation/Foundation.h>
#import "MNAsset.h"
@class MNAssetPicker;

@protocol MNAssetPickerDelegate<NSObject>
@optional
/**
 资源选择器取消事件
 @param picker 资源选择器
 */
- (void)assetPickerDidCancel:(MNAssetPicker *_Nonnull)picker;
@required
/**
 资源选择器结束选择事件
 @param picker 资源选择器
 @param assets 资源数组
 */
- (void)assetPicker:(MNAssetPicker *_Nonnull)picker didFinishPickingAssets:(NSArray <MNAsset *>*_Nullable)assets;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MNAssetPickConfiguration : NSObject
/**
 最多数量 <default 1>
 */
@property (nonatomic) NSUInteger maxPickingCount;
/**
 至少选择数量 <0 不限制 default 0>
 */
@property (nonatomic) NSUInteger minPickingCount;
/**
 是否允许编辑<"maxPickingCount==1"有效>
 */
@property (nonatomic, getter=isAllowsEditing) BOOL allowsEditing;
/**
 是否允许拍照/录像 <不完善 default NO>
 */
@property (nonatomic, getter=isAllowsCapturing) BOOL allowsCapturing;
#ifdef __IPHONE_9_0
/**
 是否允许显示文件大小
 */
@property (nonatomic, getter=isAllowsDisplayFileSize) BOOL allowsDisplayFileSize;
#endif
/**
视频拍摄最大长度 <default 60s>
*/
@property (nonatomic) NSTimeInterval maxCaptureDuration;
/**
 是否允许存储拍照/录像到系统相册 <default YES>
 */
@property (nonatomic, getter=isAllowsWritToAlbum) BOOL allowsWritToAlbum;
/**
 是否允许挑选图片 <default YES>
 */
@property (nonatomic, getter=isAllowsPickingPhoto) BOOL allowsPickingPhoto;
/**
 是否允许挑选视频 <default YES>
 */
@property (nonatomic, getter=isAllowsPickingVideo) BOOL allowsPickingVideo;
/**
 是否允许挑选GIF
 */
@property (nonatomic, getter=isAllowsPickingGif) BOOL allowsPickingGif;
/**
 是否允许挑选LivePhoto
 */
@property (nonatomic, getter=isAllowsPickingLivePhoto) BOOL allowsPickingLivePhoto;
/**
 是否允许输出HEIF格式图片
 NS_AVAILABLE_IOS(11_0)
 */
@property (nonatomic, getter=isAllowsExportHEIF) BOOL allowsExportHEIF;
/**
 把GIF当做Image使用<default NO>
 */
@property (nonatomic) BOOL requestGifUseingPhotoPolicy;
/**
 把LivePhoto当做Image使用<default NO>
 */
@property (nonatomic) BOOL requestLivePhotoUseingPhotoPolicy;
/**
 当代理为响应时是否允许自动退出
 */
@property (nonatomic, getter=isAllowsAutoDismiss) BOOL allowsAutoDismiss;
/**
 是否允许混合选择<NO 多种类型可选时, 根据首选资源类型限制 default YES>
 */
@property (nonatomic, getter=isAllowsMixPicking) BOOL allowsMixPicking;
/**
 是否允许滑动选择<default YES>
 */
@property (nonatomic, getter=isAllowsGlidePicking) BOOL allowsGlidePicking;
/**
 是否允许调整视频尺寸<default YES>
 */
@property (nonatomic, getter=isAllowsResizeVideoSize) BOOL allowsResizeVideoSize;
/**
 显示选择索引 <default YES>
 */
@property (nonatomic) BOOL showPickingNumber;
/**
 是否允许预览 <default YES>
 */
@property (nonatomic, getter=isAllowsPreviewing) BOOL allowsPreviewing;
/**
 是否允许切换相册 <default YES>
 */
@property (nonatomic, getter=isAllowsPickingAlbum) BOOL allowsPickingAlbum;
/**
 是否显示空相簿 <default NO>
 */
@property (nonatomic) BOOL showEmptyAlbum;
/**
 列数 <default 3>
 */
@property (nonatomic) NSUInteger numberOfColumns;
/**
 是否升序排列 <default YES>
 */
@property (nonatomic) BOOL sortAscending;
/**
 图片调整比例<仅图片资源有效 <=0 不固定比例, default 0>
 */
@property (nonatomic) CGFloat cropScale;
/**
 导出图片的最大像素<仅图片有效, <=0 代表原图, default 0 优先于'maxExportQuality'>
 */
@property (nonatomic) NSUInteger maxExportPixel;
/**
 导出图片的最大质量<仅图片有效, 单位KB <=0 代表原图, default 0.f>
 */
@property (nonatomic) CGFloat maxExportQuality;
/**
 导出视频的最小时长<仅视频有效 不符合时长要求的视频裁剪或隐藏处理>
 */
@property (nonatomic) NSTimeInterval minExportDuration;
/**
 导出视频的最大时长<仅视频有效 不符合时长要求的视频裁剪或隐藏处理>
 */
@property (nonatomic) NSTimeInterval maxExportDuration;
/**
 视频导出路径<视频裁剪选项>
 */
@property (nonatomic, copy, nullable) NSString *videoExportPath;
/**
 预览图大小<太大会影响性能>
 */
@property (nonatomic) CGSize renderSize;
/**
 事件代理
 */
@property (nonatomic, weak, nullable) id<MNAssetPickerDelegate> delegate;
/**
 是否原图输出<内部判断值>
 */
@property (nonatomic, readonly) BOOL isOriginalExporting;
/**
 是否允许显示选择原图<使用原图则不使用 'maxExportPixel', 'maxExportQuality'>
 */
@property (nonatomic, getter=isAllowsOriginalExporting) BOOL allowsOriginalExporting;

@end

NS_ASSUME_NONNULL_END
