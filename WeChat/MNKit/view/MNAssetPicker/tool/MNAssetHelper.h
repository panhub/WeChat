//
//  MNAssetHelper.h
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
// 

#import <Foundation/Foundation.h>
#if __has_include(<Photos/Photos.h>)
@class MNAssetPickConfiguration, MNAssetCollection, MNAsset;

NS_ASSUME_NONNULL_BEGIN

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
+ (void)fetchAssetCollectionsWithConfiguration:(MNAssetPickConfiguration *)configuration completion:(void(^)(NSArray <MNAssetCollection *>*_Nullable))completion;

#pragma mark - Get Thumbnail
/**
 获取资源缩略图
 @param asset 资源模型
 */
- (void)requestAssetProfile:(MNAsset *)asset;

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

#pragma mark - Get Content
/**
 获取一组资源的内容
 @param models 资源模型
 @param configuration 配置信息
 @param progress 当前数量进度值
 @param completion 完成回调
 */
+ (void)requestContentWithAssets:(NSArray <MNAsset *>*)models configuration:(MNAssetPickConfiguration *_Nullable)configuration progress:(void(^_Nullable)(NSInteger total, NSInteger index))progress completion:(void(^)(NSArray <MNAsset *>*_Nullable))completion;

/**
 获取资源原始内容
 @param model 资源模型
 @param configuration 配置信息
 @param completion 完成回调
 */
+ (void)requestAssetContent:(MNAsset *)model configuration:(MNAssetPickConfiguration *_Nullable)configuration completion:(void(^_Nullable)(MNAsset *_Nullable model))completion;

/**
 获取资源原始内容<预览时获取内容, 不记录请求id, 不触发资源下载回调>
 @param model 资源模型
 @param progress 进度回调
 @param completion 完成回调
 */
+ (void)requestAssetContent:(MNAsset *)model progress:(void(^_Nullable)(double, NSError *, MNAsset *))progress completion:(void(^_Nullable)(MNAsset *_Nullable))completion;

/**
 取消资源获取请求
 @param asset 资源模型
 */
+ (void)cancelAssetRequest:(MNAsset *)asset;

/**
 取消资源下载请求
 @param asset 资源模型
 */
+ (void)cancelAssetDownload:(MNAsset *)asset;

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
                  outputPath:(NSString *_Nullable)outputPath
                  presetName:(NSString *_Nullable)presetName
             progressHandler:(void(^_Nullable)(float progress))progressHandler
           completionHandler:(void(^_Nullable)(NSString *_Nullable filePath))completionHandler;
#endif

#pragma mark - Write
/**
 存储图片
 @param image 图片<UIImage, NSData>
 @param completionHandler 完成回调
*/
+ (void)writeImageToAlbum:(id)image completionHandler:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completionHandler;

/**
 存储视频
 @param videoPath 视频路径<NSString, NSURL>
 @param completionHandler 完成回调
 */
+ (void)writeVideoToAlbum:(id)videoPath completionHandler:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completionHandler;

/**
 存储图片/视频
 @param assets 资源集合<UIImage, NSData, NSString, NSURL, NSArray<LivePhoto图片路径, 视频路径>>
 @param albumName 相册名
 @param completion 完成回调
 */
+ (void)writeAssets:(NSArray <id>*)assets toAlbum:(NSString *_Nullable)albumName completion:(void(^_Nullable)(NSArray<NSString *>*_Nullable identifiers, NSError *_Nullable error))completion;

/**
 删除相册资源
 @param assets 资源内容
 @param completion 完成回调
 */
+ (void)deleteAssets:(NSArray <MNAsset *>*)assets
          completion:(void(^_Nullable)(NSError *_Nullable error))completion;

#if __has_include(<Photos/PHLivePhoto.h>)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
/**
  存储LivePhoto
  @param imagePath 图片路径<NSString NSURL>
  @param videoPath 视频路径<NSString NSURL>
  @param completion 结束回调
 */
+ (void)writeLivePhotoWithImagePath:(id)imagePath videoPath:(id)videoPath completion:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable))completion;

/**
 获取LivePhoto的本地文件
 @param livePhoto 动态图
 @param completion 结束回调
 */
+ (void)extractLivePhotoResources:(PHLivePhoto *)livePhoto completion:(void(^_Nullable)(NSString *_Nullable imagePath, NSString *_Nullable videoPath))completion;

/**
 获取LivePhoto的本地文件
 @param livePhoto 动态图
 @param imagePath 图片保存的路径
 @param videoPath 视频保存的路径
 @param completion 结束回调
 */
+ (void)extractLivePhotoResources:(PHLivePhoto *)livePhoto imagePath:(NSString *)imagePath videoPath:(NSString *)videoPath completion:(void(^_Nullable)(BOOL))completion;
#pragma clang diagnostic pop
#endif
@end
NS_ASSUME_NONNULL_END
#endif
