//
//  MNAssetPickConfiguration.h
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源选择器配置模型

#import <Foundation/Foundation.h>
#import "MNAssetPickProtocol.h"
#import "MNAsset.h"

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
 是否允许编辑<图片类型, 且"maxCount==1"有效>
 */
@property (nonatomic) BOOL allowsEditing;
/**
 是否允许拍照/录像 <default YES>
 */
@property (nonatomic) BOOL allowsCapturing;
/**
视频拍摄最大长度 <default 60s>
*/
@property (nonatomic) NSTimeInterval maxCaptureDuration;
/**
 视频最大长度 <不符合时长要求的视频隐藏处理>
 */
@property (nonatomic) NSTimeInterval maxVideoDuration;
/**
 视频最小长度 <不符合时长要求的视频隐藏处理>
 */
@property (nonatomic) NSTimeInterval minVideoDuration;
/**
 是否允许存储拍照/录像到系统相册 <default YES>
 */
@property (nonatomic) BOOL allowsWritToAlbum;
/**
 是否允许挑选图片 <default YES>
 */
@property (nonatomic) BOOL allowsPickingPhoto;
/**
 是否允许挑选视频 <default YES>
 */
@property (nonatomic) BOOL allowsPickingVideo;
/**
 是否允许挑选GIF
 */
@property (nonatomic) BOOL allowsPickingGif;
/**
 是否允许挑选LivePhoto
 */
@property (nonatomic) BOOL allowsPickingLivePhoto;
/**
 把GIF当做Image使用<default NO>
 */
@property (nonatomic) BOOL requestGifUseingPhotoPolicy;
/**
 把LivePhoto当做Image使用<default NO>
 */
@property (nonatomic) BOOL requestLivePhotoUseingPhotoPolicy;
/**
 是否允许自动退出<当"maxCount == 1"有效 default NO>
 */
@property (nonatomic) BOOL allowsAutoDismiss;
/**
 是否允许混合选择<NO 多种类型可选时, 根据首选资源类型限制 default YES>
 */
@property (nonatomic) BOOL allowsMixPicking;
/**
 显示选择索引 <default YES>
 */
@property (nonatomic) BOOL showPickingNumber;
/**
 是否允许预览 <default YES>
 */
@property (nonatomic) BOOL allowsPreviewing;
/**
 是否允许切换相册 <default YES>
 */
@property (nonatomic) BOOL allowsPickingAlbum;
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
 导出图片的最大像素<仅图片有效, <=0 代表原图, default 0.f>
 */
@property (nonatomic) NSUInteger exportPixel;
/**
 预览图大小<太大会影响性能, 也没必要太大>
 */
@property (nonatomic) CGSize renderSize;
/**
 事件代理
 */
@property (nonatomic, weak) id<MNAssetPickerDelegate> delegate;

@end
