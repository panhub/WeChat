//
//  MNAssetHelper.m
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetHelper.h"
#import "MNAssetPickConfiguration.h"
#import "MNAssetCollection.h"
#import <Photos/Photos.h>
#import "UIImage+MNAnimated.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import "MNAssetExportSession.h"
#import "MNAssetExporter+MNExportMetadata.h"
#endif

static MNAssetHelper *_helper;
@interface MNAssetHelper ()
@property (nonatomic, strong) PHVideoRequestOptions *videoOptions;
@property (nonatomic, strong) PHImageRequestOptions *imageOptions;
@end

@implementation MNAssetHelper
+ (instancetype)helper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_helper) {
            _helper = [MNAssetHelper new];
        }
    });
    return _helper;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [super allocWithZone:zone];
    });
    return _helper;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [super init];
        if (_helper) {
            PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
            imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
            _helper.imageOptions = imageOptions;
            
            PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
            videoOptions.version = PHVideoRequestOptionsVersionOriginal;
            videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            _helper.videoOptions = videoOptions;
        }
    });
    return _helper;
}

#pragma mark - Get Collection
+ (void)fetchAssetCollectionsWithConfiguration:(MNAssetPickConfiguration *)configuration completion:(void(^)(NSArray <MNAssetCollection *>*))completion {
    dispatch_async(dispatch_get_high_queue(), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        if (!configuration.allowsPickingPhoto) options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        if (!configuration.allowsPickingVideo) options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:configuration.sortAscending]];
        NSMutableArray <MNAssetCollection *>*collections = [NSMutableArray arrayWithCapacity:1];
        /// 获取全部相册数据
        PHFetchResult<PHAssetCollection *> *smartResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [smartResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:PHAssetCollection.class] || obj.estimatedAssetCount <= 0) return;
            if ([MNAssetHelper isCameraCollection:obj]) {
                MNAssetCollection *collection = [MNAssetCollection new];
                collection.title = @"相机胶卷";
                collection.localizedTitle = obj.localizedTitle;
                collection.identifier = obj.localIdentifier;
                collection.assets = [MNAssetHelper fetchAssetsInAssetCollection:obj options:options configuration:configuration];
                [collections addObject:collection];
                *stop = YES;
            }
        }];
        if (!configuration.allowsPickingAlbum) {
            dispatch_async_main(^{
                if (completion) completion(collections.copy);
            });
            return;
        }
        PHFetchResult<PHAssetCollection *>*fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger i, BOOL * _Nonnull s) {
            if (![obj isKindOfClass:PHAssetCollection.class]) return;
            NSArray <MNAsset *>*dataArray = [MNAssetHelper fetchAssetsInAssetCollection:obj options:options configuration:configuration];
            if (dataArray.count <= 0 && !configuration.showEmptyAlbum) return;
            MNAssetCollection *collection = [MNAssetCollection new];
            collection.identifier = obj.localIdentifier;
            collection.assets = dataArray;
            collection.localizedTitle = obj.localizedTitle;
            collection.title = [NSString replacingBlankCharacter:obj.localizedTitle withCharacter:@"未命名相簿"];
            [collections addObject:collection];
        }];
        dispatch_async_main(^{
            if (completion) completion(collections.copy);
        });
    });
}

+ (BOOL)isCameraCollection:(PHAssetCollection *)collection {
    PHAssetCollectionSubtype subtype = (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_2) ? PHAssetCollectionSubtypeSmartAlbumRecentlyAdded : PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    return collection.assetCollectionSubtype == subtype;
}

#pragma mark - Get Asset
+ (NSMutableArray <MNAsset *>*)fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:(PHFetchOptions *)options configuration:(MNAssetPickConfiguration *)configuration {
    NSMutableArray <MNAsset *>*dataArray = [NSMutableArray arrayWithCapacity:0];
    PHFetchResult<PHAsset *>*result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    CGSize renderSize = CGSizeIsEmpty(configuration.renderSize) ? CGSizeMake(350.f, 350.f) : configuration.renderSize;
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        MNAssetType type = [self assetTypeWithPHAsset:asset];
        if (type == MNAssetTypeVideo) {
            // 不符合视频选择时长
            if ((configuration.minVideoDuration > 0.f && asset.duration < configuration.minVideoDuration) || (configuration.maxVideoDuration > 0.f && asset.duration > configuration.maxVideoDuration)) return;
        } else if (type == MNAssetTypeGif) {
            // 不允许选择Gif
            if (!configuration.allowsPickingGif) return;
            // 以普通图片的请求方式请求Gif
            if (configuration.requestGifUseingPhotoPolicy) type = MNAssetTypePhoto;
        } else if (type == MNAssetTypeLivePhoto) {
            // 不允许选择LivePhoto
            if (!configuration.allowsPickingLivePhoto) return;
            // 以普通图片的请求方式请求LivePhoto
            if (configuration.requestLivePhotoUseingPhotoPolicy) type = MNAssetTypePhoto;
        }
        MNAsset *model = [MNAsset new];
        model.type = type;
        model.asset = asset;
        model.enabled = YES;
        model.renderSize = renderSize;
        if (type == MNAssetTypeVideo) {
            model.duration = [NSDate playTimeStringWithInterval:@(asset.duration)];
        }
        [dataArray addObject:model];
    }];
#if !TARGET_IPHONE_SIMULATOR
    /// 判断是否需要添加拍照模型<仅全部照片需要添加>
    if ([self isCameraCollection:collection] && configuration.allowsCapturing && (configuration.allowsPickingPhoto || configuration.allowsPickingVideo)) {
        MNAsset *model = [MNAsset capturingModel];
        if (configuration.allowsPickingVideo && !configuration.allowsPickingPhoto) {
            model.thumbnail = [MNBundle imageForResource:@"icon_takevideoHL"];
        }
        if (configuration.sortAscending) {
            [dataArray addObject:model];
        } else {
            [dataArray insertObject:model atIndex:0];
        }
    }
#endif
    return dataArray.copy;
}

+ (MNAssetType)assetTypeWithPHAsset:(PHAsset *)asset {
    MNAssetType type = MNAssetTypePhoto;
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage:
        {
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                type = MNAssetTypeGif;
            }
#if __has_include(<Photos/PHLivePhoto.h>)
            else if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                    type = MNAssetTypeLivePhoto;
                }
            }
#endif
        } break;
        case PHAssetMediaTypeVideo:
        {
            type = MNAssetTypeVideo;
        } break;
        default:
            break;
    }
    return type;
}

#pragma mark - Get Thumbnail
- (void)requestAssetThumbnail:(MNAsset *)model {
    /// 获取缩略图
    if (model.thumbnail) {
        if (model.thumbnailChangeHandler) {
            model.thumbnailChangeHandler(model);
        }
    } else {
        dispatch_async(dispatch_get_high_queue(), ^{
            self.imageOptions.networkAccessAllowed = NO;
            self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            model.requestId = [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:model.renderSize contentMode:PHImageContentModeAspectFill options:self.imageOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                model.requestId = INT_MIN;
                BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && result);
                if (succeed) {
                    result = [result resizingOrientation];
                    model.thumbnail = result;
                }
            }];
        });
    }
    /// 获取来源
    if (model.source != MNAssetSourceUnknown) return;
    if (model.type == MNAssetTypeVideo) {
        self.videoOptions.networkAccessAllowed = NO;
        [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:self.videoOptions resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info){
            model.source = avasset ? MNAssetSourceResource : MNAssetSourceCloud;
        }];
    } else {
        /// 请求data 才会准确返回 PHImageResultIsInCloudKey 值
        self.imageOptions.networkAccessAllowed = NO;
        self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:self.imageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            model.source = [[info objectForKey:PHImageResultIsInCloudKey] boolValue] ? MNAssetSourceCloud : MNAssetSourceResource;
        }];
    }
}

- (void)requestAssetThumbnail:(MNAsset *)model completion:(void(^)(MNAsset *))completion {
    if (model.thumbnail) {
        if (completion) completion(model);
        return;
    }
    self.imageOptions.networkAccessAllowed = NO;
    self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:model.renderSize contentMode:PHImageContentModeAspectFill options:self.imageOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && result);
        if (succeed) {
            result = [result resizingOrientation];
            model.thumbnail = result;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(model);
            });
        }
    }];
}

- (void)requestCollectionThumbnail:(MNAssetCollection *)collection completion:(void(^)(MNAssetCollection *))completion {
    if (collection.assets.count <= 0 || collection.thumbnail) {
        if (completion) completion(collection);
        return;
    }
    MNAsset *model = collection.assets.firstObject;
    if ([model isCapturingModel]) {
        if (collection.assets.count <= 1) return;
        model = collection.assets[1];
    }
    if (model.thumbnail) {
        collection.thumbnail = model.thumbnail;
        if (completion) completion(collection);
        return;
    }
    dispatch_async(dispatch_get_high_queue(), ^{
        self.imageOptions.networkAccessAllowed = NO;
        self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        CGSize targetSize =  CGSizeIsEmpty(model.renderSize) ?  CGSizeMake(200.f, 200.f) : model.renderSize;
        [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:self.imageOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (succeed && result) {
                result = [result resizingOrientation];
                collection.thumbnail = result;
                dispatch_async_main(^{
                    if (completion) completion(collection);
                });
            }
        }];
    });
}

+ (void)cancelThumbnailRequestWithAsset:(MNAsset *)asset {
    if (asset.requestId == INT_MIN) return;
    asset.requestId = INT_MIN;
    [[PHImageManager defaultManager] cancelImageRequest:asset.requestId];
}

#pragma mark - Get Content
+ (void)requestContentWithAssets:(NSArray <MNAsset *>*)models configuration:(MNAssetPickConfiguration *)configuration completion:(void(^)(NSArray <MNAsset *>*))completion {
    if (models.count <= 0) {
        if (completion) completion(nil);
        return;
    }
    [self requestContentWithAssets:models atIndex:0 configuration:configuration container:[NSMutableArray new] completion:completion];
}

+ (void)requestContentWithAssets:(NSArray <MNAsset *>*)models atIndex:(NSInteger)index configuration:(MNAssetPickConfiguration *)configuration container:(NSMutableArray <MNAsset *>*)container completion:(void(^)(NSArray <MNAsset *>*))completion {
    if (index >= models.count) {
        if (completion) completion(container.copy);
        return;
    }
    MNAsset *model = models[index];
    [self requestAssetContent:model configuration:configuration completion:^(MNAsset *m) {
        if (m.content) {
            if (m.type == MNAssetTypePhoto && configuration.exportPixel > 0.f) {
                m.content = [kTransform(UIImage *, m.content) resizingToPix:configuration.exportPixel];
            }
            [container addObject:m];
        }
        [self requestContentWithAssets:models atIndex:index + 1 configuration:configuration container:container completion:completion];
    }];
}

+ (void)requestAssetContent:(MNAsset *)model configuration:(MNAssetPickConfiguration *)configuration completion:(void(^)(MNAsset *))completion {
    if (model.content) {
        if (completion) completion(model);
        return;
    }
    /// configuration有值时表示此时挑选完成, 一般会退出, 不需要显示下载
    if (model.source == MNAssetSourceCloud) {
        if (configuration) {
            [model updateStatus:MNAssetStatusDownloading];
        } else {
            model.status = MNAssetStatusDownloading;
        }
    }
    if (model.type == MNAssetTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            model.progress = progress;
            if (error) model.status = MNAssetStatusFailed;
        };
        model.downloadId = [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if (asset && [asset isKindOfClass:AVURLAsset.class]) {
                AVURLAsset *avasset = (AVURLAsset *)asset;
                model.content = avasset.URL.path;
                model.status = MNAssetStatusCompleted;
                model.source = MNAssetSourceResource;
            } else {
                model.status = MNAssetStatusFailed;
                model.source = MNAssetSourceCloud;
            }
            model.downloadId = INT_MIN;
            if (completion) completion(model);
        }];
    } else if (model.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            CGSize targetSize = CGSizeIsEmpty(model.asset.pixelSize) ? PHImageManagerMaximumSize : model.asset.pixelSize;
            if (configuration.exportPixel > 0.f) {
                if (targetSize.width/targetSize.height > 1.f) {
                    targetSize = CGSizeMultiplyToWidth(targetSize, configuration.exportPixel);
                } else {
                    targetSize = CGSizeMultiplyToHeight(targetSize, configuration.exportPixel);
                }
            }
            PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                model.progress = progress;
                if (error) model.status = MNAssetStatusFailed;
            };
            model.downloadId = [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                if (livePhoto) {
                    model.content = livePhoto;
                    model.status = MNAssetStatusCompleted;
                    model.source = MNAssetSourceResource;
                } else {
                    model.status = MNAssetStatusFailed;
                    model.source = MNAssetSourceCloud;
                }
                model.downloadId = INT_MIN;
                if (completion) completion(model);
            }];
        }
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            model.progress = progress;
            if (error) model.status = MNAssetStatusFailed;
        };
        model.downloadId = [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = model.type == MNAssetTypePhoto ? [UIImage imageWithData:imageData] : [UIImage animatedImageWithData:imageData];
            if (image) {
                if (image.isAnimatedImage == NO) {
                    image = [image resizingOrientation];
                    if (configuration.exportPixel > 0) {
                        image = [image resizingToPix:configuration.exportPixel];
                    }
                }
                model.content = image;
                model.status = MNAssetStatusCompleted;
                model.source = MNAssetSourceResource;
            } else {
                model.status = MNAssetStatusFailed;
                model.source = MNAssetSourceCloud;
            }
            model.downloadId = INT_MIN;
            if (completion) completion(model);
        }];
    }
}

+ (void)requestAssetContent:(MNAsset *)model progress:(void(^)(double, NSError *, MNAsset *))progress completion:(void(^)(MNAsset *))completion {
    if (model.content) {
        if (completion) completion(model);
        return;
    }
    if (model.type == MNAssetTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.progressHandler = ^(double pro, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress) progress(pro, error, model);
            });
        };
        [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if (asset && [asset isKindOfClass:AVURLAsset.class]) {
                AVURLAsset *avasset = (AVURLAsset *)asset;
                UIImage *thumbnail = [MNAssetExporter exportThumbnailOfVideoAtPath:avasset.URL.path];
                if (thumbnail) model.thumbnail = thumbnail;
                model.content = avasset.URL.path;
                model.source = MNAssetSourceResource;
                model.status = MNAssetStatusCompleted;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(model);
                });
            } else {
                model.status = MNAssetStatusFailed;
                model.source = MNAssetSourceCloud;
            }
        }];
    } else if (model.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            CGSize targetSize = CGSizeIsEmpty(model.asset.pixelSize) ? PHImageManagerMaximumSize : model.asset.pixelSize;
            PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.progressHandler = ^(double pro, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress) progress(pro, error, model);
                });
            };
            [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                if (livePhoto) {
                    model.content = livePhoto;
                    model.status = MNAssetStatusCompleted;
                    model.source = MNAssetSourceResource;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(model);
                    });
                } else {
                    model.status = MNAssetStatusFailed;
                    model.source = MNAssetSourceCloud;
                }
            }];
        }
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.progressHandler = ^(double pro, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress) progress(pro, error, model);
            });
        };
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = model.type == MNAssetTypePhoto ? [UIImage imageWithData:imageData] : [UIImage animatedImageWithData:imageData];
            if (image) {
                if (image.isAnimatedImage == NO) image = [image resizingOrientation];
                model.content = image;
                model.status = MNAssetStatusCompleted;
                model.source = MNAssetSourceResource;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(model);
                });
            } else {
                model.status = MNAssetStatusFailed;
                model.source = MNAssetSourceCloud;
            }
        }];
    }
}

+ (void)cancelContentRequestWithAsset:(MNAsset *)asset {
    if (asset.downloadId == INT_MIN) return;
    asset.downloadId = INT_MIN;
    if (asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            [PHLivePhoto cancelLivePhotoRequestWithRequestID:asset.downloadId];
        }
    } else {
        [[PHImageManager defaultManager] cancelImageRequest:asset.downloadId];
    }
}

#pragma mark - Export Video
#if __has_include(<AVFoundation/AVFoundation.h>)
+ (void)exportVideoWithAsset:(MNAsset *)asset  outputPath:(NSString *)outputPath presetName:(NSString *)presetName progressHandler:(void(^)(float progress))progressHandler completionHandler:(void(^)(NSString *filePath))completionHandler {
    if (asset.type != MNAssetTypeVideo) {
        if (completionHandler) completionHandler(nil);
        return;
    }
    if (outputPath.length <= 0) outputPath = MNCacheDirectoryAppending(MNFileMP4Name);
    [MNAssetHelper requestAssetContent:asset configuration:nil completion:^(MNAsset *m) {
        if (!m.content) {
            if (completionHandler) completionHandler(nil);
            return;
        }
        [MNAssetExportSession exportAsynchronouslyOfVideoAtPath:m.content outputPath:outputPath presetName:presetName progressHandler:progressHandler completionHandler:^(AVAssetExportSessionStatus status, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(status == AVAssetExportSessionStatusCompleted ? outputPath : nil);
            });
        }];
    }];
}
#endif

#pragma mark - Write
+ (void)writeImages:(NSArray <UIImage *>*)images toAlbum:(NSString *)albumName completion:(void(^)(NSArray<NSString *>*, NSError *error))completion {
    if (images.count <= 0) {
        if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"图片不存在"}]);
        return;
    }
    [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            NSMutableArray <NSString *>*identifiers = @[].mutableCopy;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *collectionRequest = [self creationRequestForAssetCollectionWithTitle:albumName];
                NSMutableArray <PHObjectPlaceholder *>*assets = @[].mutableCopy;
                [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:obj];
                    PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
                    [identifiers addObject:placeholder.localIdentifier];
                }];
                [collectionRequest addAssets:assets.copy];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        if (error) {
                            completion(nil, error);
                        } else {
                            completion(identifiers.copy, nil);
                        }
                    }
                });
            }];
        } else {
            if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获得系统相册权限"}]);
        }
    }];
}

+ (void)writeVideos:(NSArray <NSURL *>*)URLs toAlbum:(NSString *)albumName completion:(void(^)(NSArray<NSString *>*, NSError *))completion {
    if (URLs.count <= 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"视频文件不存在"}]);
        }
        return;
    }
    [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            NSMutableArray <NSString *>*identifiers = @[].mutableCopy;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *collectionRequest = [self creationRequestForAssetCollectionWithTitle:albumName];
                NSMutableArray <PHObjectPlaceholder *>*assets = @[].mutableCopy;
                [URLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:obj];
                    PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
                    [identifiers addObject:placeholder.localIdentifier];
                }];
                [collectionRequest addAssets:assets.copy];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        if (error) {
                            completion(nil, error);
                        } else {
                            completion(identifiers, nil);
                        }
                    }
                });
            }];
        } else {
            if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获得系统相册权限"}]);
        }
    }];
}

+ (void)writeContent:(id)content toAlbum:(NSString *)albumName completion:(void(^)(NSString *, NSError *))completion {
    if ([content isKindOfClass:UIImage.class]) {
        [self writeImages:@[content] toAlbum:albumName completion:^(NSArray<NSString *> *identifiers, NSError *error) {
            NSString *identifier = identifiers.count > 0 ? identifiers.firstObject : nil;
            if (completion) completion(identifier, error);
        }];
    } else if ([content isKindOfClass:NSString.class] || [content isKindOfClass:NSURL.class]) {
        if ([content isKindOfClass:NSString.class]) content = [NSURL fileURLWithPath:content];
        [self writeVideos:@[content] toAlbum:albumName completion:^(NSArray<NSString *> *identifiers, NSError *error) {
            NSString *identifier = identifiers.count > 0 ? identifiers.firstObject : nil;
            if (completion) completion(identifier, error);
        }];
    } else {
        if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"文件类型不匹配"}]);
    }
}

#if __has_include(<Photos/PHLivePhoto.h>)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
+ (void)writeLivePhotoWithImage:(NSURL *)imageURL video:(NSURL *)videoURL completion:(void(^)(BOOL success, NSError *error))completion {
    if (![NSFileManager.defaultManager fileExistsAtPath:imageURL.path isDirectory:nil] || ![NSFileManager.defaultManager fileExistsAtPath:videoURL.path isDirectory:nil]) {
        if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"LivePhoto文件不存在"}]);
        return;
    }
    [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imageURL options:nil];
                [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoURL options:nil];
            } completionHandler:completion];
        } else {
            if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获得系统相册权限"}]);
        }
    }];
}
#pragma clang diagnostic pop
#endif

+ (PHAssetCollectionChangeRequest  *)creationRequestForAssetCollectionWithTitle:(NSString *)title {
    if (title.length <= 0) return [PHAssetCollectionChangeRequest  creationRequestForAssetCollectionWithTitle:[NSBundle displayName]];
    /// 从用户相簿集合查找
    __block PHAssetCollection *collection;
    PHFetchResult<PHAssetCollection *>*fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.localizedTitle isEqualToString:title]) {
            collection = obj;
            *stop = YES;
        }
    }];
    /// 创建相册变动请求
    if (collection) return [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
    /// 根据title创建相簿
    return [PHAssetCollectionChangeRequest  creationRequestForAssetCollectionWithTitle:title];
}

@end
