//
//  MNAsset.h
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片/视频资源模型

#import <Foundation/Foundation.h>
@class PHAsset;

/**
 资源类型
 - MNAssetTypePhoto: 图片
 - MNAssetTypeAudio: 音频
 - MNAssetTypeVideo: 视频
 - MNAssetTypeLivePhoto: LivePhoto
 - MNAssetTypeGif: Gif
 - MNAssetTypeTaking: 拍照/录像
 */
typedef NS_ENUM(NSInteger, MNAssetType) {
    MNAssetTypePhoto = 0,
    MNAssetTypeVideo,
    MNAssetTypeLivePhoto,
    MNAssetTypeGif
};

/**
 资源来源
 - MNAssetSourceUnknown: 未知<default>
 - MNAssetSourceCloud: iCloud
 - MNAssetSourceResource: 本地
 */
typedef NS_ENUM(NSInteger, MNAssetSourceType) {
    MNAssetSourceUnknown = 0,
    MNAssetSourceCloud,
    MNAssetSourceResource
};

/**
 下载状态
 - MNAssetStateNormal: 未知
 - MNAssetStateDownloading: 下载中
 - MNAssetStateFailed: 失败
 */
typedef NS_ENUM(NSInteger, MNAssetState) {
    MNAssetStateNormal = 0,
    MNAssetStateDownloading,
    MNAssetStateFailed
};

@interface MNAsset : NSObject
/**
 文件类型
 */
@property (nonatomic) MNAssetType type;
/**
 资源来源
 */
@property (nonatomic) MNAssetSourceType source;
/**
 下载状态
 */
@property (nonatomic) MNAssetState state;
/**
 图片: 调整后的图片
 视频: 路径
 GIF : NSData
 */
@property (nonatomic, strong) id content;
/**
 显示大小
 */
@property (nonatomic) CGSize renderSize;
/**
 时长<仅视频资源有效>
 */
@property (nonatomic, copy) NSString *duration;
/**
 缩略图
 */
@property (nonatomic, strong) UIImage *thumbnail;
/**
 系统资源
 */
@property (nonatomic, strong) PHAsset *asset;
/**
 是否选中
 */
@property (nonatomic, getter=isSelected) BOOL selected;
/**
 是否可选
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;
/**
 标识符
 */
@property (nonatomic, copy) NSString *uuid;
/**
 PHImageRequestID, 请求缩略图id
 */
@property (nonatomic) int32_t requestId;
/**
 PHImageRequestID, 下载原图/Live Photo id
 */
@property (nonatomic) int32_t downloadId;
/**
 下载进度
 */
@property (nonatomic) double progress;
/**
 选择索引
 */
@property (nonatomic) NSUInteger selectIndex;
/**
 标记展示它的imageView<预览时使用>
 */
@property (nonatomic, weak) UIImageView *containerView;
/**
 缩略图回调
 */
@property (nonatomic, copy) void (^thumbnailChangeHandler) (MNAsset *m);
/**
 确定来源回调
 */
@property (nonatomic, copy) void (^sourceChangeHandler) (MNAsset *m);
/**
 下载进度回调
 */
@property (nonatomic, copy) void (^progressChangeHandler) (MNAsset *m);
/**
 下载状态发生变化回调
 */
@property (nonatomic, copy) void (^stateChangeHandler) (MNAsset *m);

/**
 实例化拍照模型
 @return 拍照/录像资源模型<仅供展示使用>
 */
+ (MNAsset *)capturingModel;

/**
 依据资源内容实例化
 @param content 资源内容
 @return 资源模型
 */
+ (MNAsset *)assetWithContent:(id)content;

/**
 依据资源内容实例化
 @param content 资源内容
 @param renderSize 显示大小
 @return 资源模型
 */
+ (MNAsset *)assetWithContent:(id)content renderSize:(CGSize)renderSize;

/**
 修改状态<避免触发setter>
 @param state 指定状态
 */
- (void)changeState:(MNAssetState)state;

/**
 修改来源<避免触发setter>
 @param source 来源
 */
- (void)changeSource:(MNAssetSourceType)source;

/**
 修改进度<避免触发setter>
 @param progress 进度值
 */
- (void)changeProgress:(double)progress;

/**
 修改缩略图<避免触发setter>
 @param thumbnail 缩略图
 */
- (void)changeThumbnail:(UIImage *)thumbnail;

/**
 是否是拍摄模型
 @return 是否拍摄模型
 */
- (BOOL)isCapturingModel;

@end
