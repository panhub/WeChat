//
//  MNAsset.h
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  图片/视频资源模型

#import <Foundation/Foundation.h>
@class PHAsset, CLLocation, MNAssetPickConfiguration;

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
 状态
 - MNAssetStatusUnknown: 未知<默认>
 - MNAssetStatusCompleted: 成功获取资源
 - MNAssetStatusDownloading: iCloud资源下载中
 - MNAssetStatusFailed: iCloud资源下载失败
 */
typedef NS_ENUM(NSInteger, MNAssetStatus) {
    MNAssetStatusUnknown = 0,
    MNAssetStatusCompleted,
    MNAssetStatusDownloading,
    MNAssetStatusFailed
};

NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic) MNAssetStatus status;
/**
 图片: 调整后的图片
 视频: 路径
 LivePhoto : PHLivePhoto
 */
@property (nonatomic, strong, nullable) id content;
/**
 外界加载图片<仅图片有效>
 */
@property (nonatomic, copy, nullable) NSString *url;
/**
 显示大小
 */
@property (nonatomic) CGSize renderSize;
/**
 时长<仅视频资源有效>
 */
@property (nonatomic) NSTimeInterval duration;
/**
 时长字符串形式<仅视频资源有效>
 */
@property (nonatomic, copy, nullable) NSString *durationString;
/**
 文件大小
 */
@property (nonatomic) long long fileSize;
/**
 文件大小<字符串输出>
 */
@property (nonatomic, copy, readonly) NSString *fileSizeString;
/**
 缩略图
 */
@property (nonatomic, strong, nullable) UIImage *thumbnail;
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
@property (nonatomic, copy, nullable) NSString *uuid;
#if __has_include(<Photos/Photos.h>)
/**
 系统资源
 */
@property (nonatomic, strong, nullable) PHAsset *asset;
#endif
/**
 PHImageRequestID, 请求内容id
 */
@property (nonatomic) int32_t requestId;
/**
 PHImageRequestID, 下载原图/Live Photo id
 */
@property (nonatomic) int32_t downloadId;
/**
 用户扩展信息
 */
@property (nonatomic, strong, nullable) id userInfo;
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
@property (nonatomic, weak, nullable) UIView *containerView;
/**
 缩略图回调
 */
@property (nonatomic, copy, nullable) void (^thumbnailChangeHandler) (MNAsset *m);
/**
 确定来源回调
 */
@property (nonatomic, copy, nullable) void (^sourceChangeHandler) (MNAsset *m);
/**
 下载进度回调
 */
@property (nonatomic, copy, nullable) void (^progressChangeHandler) (MNAsset *m);
/**
 下载状态发生变化回调
 */
@property (nonatomic, copy, nullable) void (^statusChangeHandler) (MNAsset *m);
/**
 文件大小变化回调
 */
@property (nonatomic, copy, nullable) void (^fileSizeChangeHandler) (MNAsset *m);

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
+ (MNAsset *_Nullable)assetWithContent:(id)content;

/**
 依据资源内容实例化
 @param content 资源内容
 @param configuration 资源选择器配置信息
 @return 资源模型
 */
+ (MNAsset *_Nullable)assetWithContent:(id)content configuration:(MNAssetPickConfiguration *_Nullable)configuration;

/**
 修改状态<避免触发setter>
 @param status 指定状态
 */
- (void)updateStatus:(MNAssetStatus)status;

/**
 修改来源<避免触发setter>
 @param source 来源
 */
- (void)updateSource:(MNAssetSourceType)source;

/**
 修改进度<避免触发setter>
 @param progress 进度值
 */
- (void)updateProgress:(double)progress;

/**
 修改缩略图<避免触发setter>
 @param thumbnail 缩略图
 */
- (void)updateThumbnail:(UIImage *)thumbnail;

/**
 修改文件大小<避免触发setter>
 @param fileSize 文件大小
 */
- (void)updateFileSize:(long long)fileSize;

/**
 是否是拍摄模型
 @return 是否拍摄模型
 */
- (BOOL)isCapturingModel;

/**
 文件内存大小字符串表示法
 @return 字符串表示法
 */
- (NSString *)fileSizeStringValue;

/**
 取消内容请求
 */
- (void)cancelRequest;

/**
 取消内容下载请求
 */
- (void)cancelDownload;

@end

NS_ASSUME_NONNULL_END
