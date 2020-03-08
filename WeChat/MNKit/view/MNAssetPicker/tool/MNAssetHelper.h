//
//  MNAssetHelper.h
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
// 

#import <Foundation/Foundation.h>
@class MNAssetPickConfiguration, MNAssetCollection, MNAsset;

@interface MNAssetHelper : NSObject
/**
 唯一实例化入口
 @return 实例
 */
+ (instancetype)helper;

#pragma mark - Get Collection
/**
 获取相簿数据
 @param configuration 配置信息
 @param completion 完成回调
 */
+ (void)fetchAssetCollectionsWithConfiguration:(MNAssetPickConfiguration *)configuration completion:(void(^)(NSArray <MNAssetCollection *>*))completion;

#pragma mark - Get Thumbnail
/**
 获取资源缩略图
 @param asset 资源模型
 */
- (void)requestAssetThumbnail:(MNAsset *)asset;

/**
 获取资源缩略图<预览时获取缩略图, 不记录请求id>
 @param model 资源模型
 @param completion 结束回调
 */
- (void)requestAssetThumbnail:(MNAsset *)model completion:(void(^)(MNAsset *))completion;

/**
 获取相簿缩略图
 @param collection 相簿
 @param completion 完成回调
 */
- (void)requestCollectionThumbnail:(MNAssetCollection *)collection completion:(void(^)(MNAssetCollection *))completion;

/**
 取消资源缩略图获取请求
 @param asset 资源模型
 */
+ (void)cancelThumbnailRequestWithAsset:(MNAsset *)asset;

#pragma mark - Get Content
/**
 获取一组资源的内容
 @param models 资源模型
 @param configuration 配置信息<nil 则不考虑exportPixel, 下载时显示下载进度>
 @param completion 完成回调
 */
+ (void)requestContentWithAssets:(NSArray <MNAsset *>*)models configuration:(MNAssetPickConfiguration *)configuration completion:(void(^)(NSArray <MNAsset *>*))completion;

/**
 获取资源原始内容
 @param model 资源模型
 @param configuration 配置信息
 @param completion 完成回调
 */
+ (void)requestAssetContent:(MNAsset *)model configuration:(MNAssetPickConfiguration *)configuration completion:(void(^)(MNAsset *model))completion;

/**
 获取资源原始内容<预览时获取内容, 不记录请求id, 不触发资源下载回调>
 @param model 资源模型
 @param progress 进度回调
 @param completion 完成回调
 */
+ (void)requestAssetContent:(MNAsset *)model progress:(void(^)(double, NSError *, MNAsset *))progress completion:(void(^)(MNAsset *))completion;

/**
 取消资源下载请求
 @param asset 资源模型
 */
+ (void)cancelContentRequestWithAsset:(MNAsset *)asset;

#pragma mark - Export Video
#if __has_include(<AVFoundation/AVFoundation.h>)
/**
 导出视频资源
 @param asset 资源模型
 @param outputPath 导出路径
 @param presetName 视频质量<AVAssetExportPresetHighestQuality>
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 */
+ (void)exportVideoWithAsset:(MNAsset *)asset
                  outputPath:(NSString *)outputPath
                  presetName:(NSString *)presetName
             progressHandler:(void(^)(float progress))progressHandler
           completionHandler:(void(^)(NSString *filePath))completionHandler;
#endif

#pragma mark - Write
/**
 往相簿存储图片
 @param images 图片集合
 @param albumName 相册名
 @param completion 完成回调
 */
+ (void)writeImages:(NSArray <UIImage *>*)images toAlbum:(NSString *)albumName completion:(void(^)(NSArray<NSString *>*identifiers, NSError *error))completion;

/**
 往相簿存储视频
 @param URLs 视频路径
 @param albumName 相册名
 @param completion 完成回调
 */
+ (void)writeVideos:(NSArray <NSURL *>*)URLs toAlbum:(NSString *)albumName completion:(void(^)(NSArray<NSString *>*identifiers, NSError *error))completion;

/**
 往相簿存储内容
 @param content 内容
 @param albumName 相册名
 @param completion 完成回调
 */
+ (void)writeContent:(id)content toAlbum:(NSString *)albumName completion:(void(^)(NSString *, NSError *error))completion;

#if __has_include(<Photos/PHLivePhoto.h>)
/**
  往相簿存储LivePhoto
  @param imageURL 图片路径
  @param videoURL 视频路径
  @param completion 结束回调
 */
+ (void)writeLivePhotoWithImage:(NSURL *)imageURL video:(NSURL *)videoURL completion:(void(^)(BOOL success, NSError *error))completion;
#endif

@end
