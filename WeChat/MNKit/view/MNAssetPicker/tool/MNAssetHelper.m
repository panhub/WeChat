//
//  MNAssetHelper.m
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetHelper.h"
#if __has_include(<Photos/Photos.h>)
#import "MNAssetPickConfiguration.h"
#import "MNAssetCollection.h"
#import <Photos/Photos.h>
#import "UIImage+MNAnimated.h"
#import "PHAsset+MNAssetResource.h"
#if __has_include(<CoreImage/CoreImage.h>)
#import <CoreImage/CoreImage.h>
#endif
#if __has_include(<AVFoundation/AVFoundation.h>)
#import "MNAssetExportSession.h"
#import "MNAssetExporter+MNExportMetadata.h"
#endif
#if __has_include("SDWebImageManager.h")
#import "SDWebImageManager.h"
#endif
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        if (!configuration.isAllowsPickingVideo) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        } else if (!configuration.isAllowsPickingPhoto && !configuration.isAllowsPickingLivePhoto && !configuration.isAllowsPickingGif) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        } else {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        }
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
        if (!configuration.isAllowsPickingAlbum) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(collections.count > 0 ? collections.copy : nil);
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
            collection.title = obj.localizedTitle ? : @"未知相簿";
            [collections addObject:collection];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(collections.count > 0 ? collections.copy : nil);
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
            NSTimeInterval duration = floor(asset.duration);
            if ((configuration.minExportDuration > 0.f && duration < configuration.minExportDuration) || (configuration.maxExportDuration > 0.f && (!configuration.isAllowsEditing || configuration.maxPickingCount > 1) && duration > configuration.maxExportDuration)) return;
        } else if (type == MNAssetTypeGif) {
            // 不允许选择Gif
            if (!configuration.isAllowsPickingGif) return;
            // 以普通图片的请求方式请求Gif
            if (configuration.requestGifUseingPhotoPolicy) type = MNAssetTypePhoto;
        } else if (type == MNAssetTypeLivePhoto) {
            // 不允许选择LivePhoto
            if (!configuration.isAllowsPickingLivePhoto) return;
            // 以普通图片的请求方式请求LivePhoto
            if (configuration.requestLivePhotoUseingPhotoPolicy) type = MNAssetTypePhoto;
        }
        MNAsset *model = [MNAsset new];
        model.type = type;
        model.asset = asset;
        model.enabled = YES;
        model.renderSize = renderSize;
        if (type == MNAssetTypeVideo) {
            model.duration = asset.duration;
            model.durationString = [NSDate timeStringWithInterval:@(asset.duration)];
        }
        [dataArray addObject:model];
    }];
#if !TARGET_IPHONE_SIMULATOR
    /// 判断是否需要添加拍照模型<仅全部照片需要添加>
    if ([self isCameraCollection:collection] && configuration.isAllowsCapturing && (configuration.isAllowsPickingPhoto || configuration.isAllowsPickingVideo)) {
        MNAsset *model = [MNAsset capturingModel];
        if (configuration.isAllowsPickingVideo && !configuration.isAllowsPickingPhoto) {
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
            if ([[[asset valueForKey:@"filename"] lowercaseString] containsString:@"gif"]) {
                type = MNAssetTypeGif;
            } else if (@available(iOS 9.1, *)) {
                if ((asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive)) {
                    type = MNAssetTypeLivePhoto;
                }
            }
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
- (void)requestAssetProfile:(MNAsset *)model {
    /// 获取缩略图
    if (model.thumbnail) {
        if (model.thumbnailChangeHandler) {
            model.thumbnailChangeHandler(model);
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            self.imageOptions.networkAccessAllowed = NO;
            self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:model.renderSize contentMode:PHImageContentModeAspectFill options:self.imageOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && result);
                if (succeed) {
                    result = [result resizingOrientation];
                    model.thumbnail = result;
                }
            }];
        });
    }
    /// 获取来源
    if (model.source == MNAssetSourceUnknown) {
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
    /// 获取文件大小
    if (model.fileSizeString.length <= 0 && !model.isCapturingModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (model.asset) {
                NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:model.asset];
                model.fileSize = resources.count ? [[resources.firstObject valueForKey:@"fileSize"] longLongValue] : 0;
            } else {
                model.fileSize = 0;
            }
        });
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
        if (succeed && result) {
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
    self.imageOptions.networkAccessAllowed = NO;
    self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    CGSize targetSize =  CGSizeIsEmpty(model.renderSize) ?  CGSizeMake(200.f, 200.f) : model.renderSize;
    [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:self.imageOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (succeed && result) {
            result = [result resizingOrientation];
            collection.thumbnail = result;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(collection);
            });
        }
    }];
}

#pragma mark - Get Content
+ (void)requestContentWithAssets:(NSArray <MNAsset *>*)models configuration:(MNAssetPickConfiguration *)configuration progress:(void(^)(NSInteger total, NSInteger index))progress completion:(void(^)(NSArray <MNAsset *>*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (models.count <= 0) {
            if (completion) completion(nil);
            return;
        }
        [self requestContentWithAssets:models atIndex:0 configuration:configuration container:[NSMutableArray new] progress:progress completion:completion];
    });
}

+ (void)requestContentWithAssets:(NSArray <MNAsset *>*)models atIndex:(NSInteger)index configuration:(MNAssetPickConfiguration *)configuration container:(NSMutableArray <MNAsset *>*)container progress:(void(^)(NSInteger total, NSInteger index))progress completion:(void(^)(NSArray <MNAsset *>*))completion {
    if (index >= models.count) {
        if (completion) completion(container.copy);
        return;
    }
    if (progress) progress(models.count, index);
    MNAsset *model = models[index];
    [self requestAssetContent:model configuration:configuration completion:^(MNAsset *m) {
        if (m) [container addObject:m];
        [self requestContentWithAssets:models atIndex:index + 1 configuration:configuration container:container progress:progress completion:completion];
    }];
}

+ (void)requestAssetContent:(MNAsset *)model configuration:(MNAssetPickConfiguration *)configuration completion:(void(^)(MNAsset *))completion {
    if (model.content) {
        if (completion) completion(model);
        return;
    }
    if (model.source == MNAssetSourceCloud) {
        model.status = MNAssetStatusDownloading;
    }
    if (model.type == MNAssetTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            model.progress = progress;
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
            model.downloadId = PHInvalidImageRequestID;
            if (completion) completion(model);
        }];
    } else if (model.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            CGSize targetSize = CGSizeIsEmpty(model.asset.pixelSize) ? PHImageManagerMaximumSize : model.asset.pixelSize;
            if (!configuration.isOriginalExporting && configuration.maxExportPixel > 0.f) {
                if (targetSize.width/targetSize.height > 1.f) {
                    targetSize = CGSizeMultiplyToWidth(targetSize, configuration.maxExportPixel);
                } else {
                    targetSize = CGSizeMultiplyToHeight(targetSize, configuration.maxExportPixel);
                }
            }
            PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                model.progress = progress;
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
                model.downloadId = PHInvalidImageRequestID;
                if (completion) completion(model);
            }];
        }
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            model.progress = progress;
        };
        model.downloadId = [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image;
            if (model.type == MNAssetTypePhoto) {
                if (configuration.isAllowsExportHEIF) {
                    image = [UIImage imageWithData:imageData];
                } else {
                    if (model.asset.isHEIFAsset) {
#ifdef __IPHONE_11_0
                        if (@available(iOS 11.0, *)) {
                            CIImage *ciImage = [CIImage imageWithData:imageData];
                            NSData *jpgData = [CIContext.context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{(__bridge NSString *)kCGImageDestinationLossyCompressionQuality: @1}];
                            if (jpgData.length) image = [UIImage imageWithData:jpgData];
                        } else {
                            image = [UIImage imageWithData:imageData];
                        }
#else
                        image = [UIImage imageWithData:imageData];
#endif
                    } else {
                        image = [UIImage imageWithData:imageData];
                    }
                }
            } else {
                image = [UIImage animatedImageWithData:imageData];
            }
            if (image) {
                if (image.isAnimatedImage == NO) {
                    image = [image resizingOrientation];
                    if (configuration && !configuration.isOriginalExporting) {
                        if (configuration.maxExportPixel > 0) {
                            image = [image resizingToMaxPix:configuration.maxExportPixel];
                        }
                        if (configuration.maxExportQuality > 0.f) {
                            image = [image resizingToQuality:configuration.maxExportQuality];
                        }
                    }
                }
                model.content = image;
                model.status = MNAssetStatusCompleted;
                model.source = MNAssetSourceResource;
            } else {
                model.status = MNAssetStatusFailed;
                model.source = MNAssetSourceCloud;
            }
            model.downloadId = PHInvalidImageRequestID;
            if (completion) completion(model);
        }];
    }
}

+ (void)requestAssetContent:(MNAsset *)model progress:(void(^)(double, NSError *, MNAsset *))progress completion:(void(^)(MNAsset *))completion {
    if (model.content) {
        if (completion) completion(model);
        return;
    }
    if (model.url.length && model.type == MNAssetTypePhoto) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
        [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:model.url] options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (expectedSize <= 0) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress) progress(receivedSize*1.f/(expectedSize*1.f), nil, model);
            });
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (finished == NO) return;
            if (image) {
                model.url = nil;
                model.content = image;
                model.status = MNAssetStatusCompleted;
                model.source = MNAssetSourceResource;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(model);
                });
            } else {
                model.status = MNAssetStatusFailed;
                model.source = MNAssetSourceCloud;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(nil);
                });
            }
        }];
#else
        if (completion) completion(nil);
#endif
        return;
    }
    if (!model.asset) {
        if (progress) progress(0.f, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"相册资源项为空"}], model);
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
        model.requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            model.requestId = PHInvalidImageRequestID;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(nil);
                });
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
            model.requestId = [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                model.requestId = PHInvalidImageRequestID;
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) completion(nil);
                    });
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
        model.requestId = [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            model.requestId = PHInvalidImageRequestID;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(nil);
                });
            }
        }];
    }
}

+ (void)cancelAssetRequest:(MNAsset *)asset {
    if (!asset) return;
    PHImageRequestID requestId = asset.requestId;
    if (requestId == PHInvalidImageRequestID) return;
    asset.requestId = PHInvalidImageRequestID;
    if (asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            [PHLivePhoto cancelLivePhotoRequestWithRequestID:requestId];
        }
    } else {
        [[PHImageManager defaultManager] cancelImageRequest:requestId];
    }
}

+ (void)cancelAssetDownload:(MNAsset *)asset {
    if (!asset) return;
    PHImageRequestID downloadId = asset.downloadId;
    if (downloadId == PHInvalidImageRequestID) return;
    asset.downloadId = PHInvalidImageRequestID;
    if (asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            [PHLivePhoto cancelLivePhotoRequestWithRequestID:downloadId];
        }
    } else {
        [[PHImageManager defaultManager] cancelImageRequest:downloadId];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(nil);
            });
            return;
        }
        if ([NSFileManager.defaultManager copyItemAtPath:m.content toPath:outputPath error:nil]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(outputPath);
            });
            return;
        }
        NSData *videoData = [NSData dataWithContentsOfFile:m.content];
        if (videoData.length && [videoData writeToFile:outputPath atomically:YES]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(outputPath);
            });
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
+ (void)writeImageToAlbum:(id)image completionHandler:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completionHandler
{
    if (image && [image isKindOfClass:NSString.class] && [NSFileManager.defaultManager fileExistsAtPath:(NSString *)image]) {
        image = [UIImage imageWithContentsOfFile:(NSString *)image];
    }
    if (!image || (![image isKindOfClass:UIImage.class] && ![image isKindOfClass:NSString.class] && ![image isKindOfClass:NSData.class])) {
        if (completionHandler) completionHandler(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"图片不存在"}]);
        return;
    }
    [self writeAssets:@[image] toAlbum:nil completion:^(NSArray<NSString *> * _Nullable identifiers, NSError * _Nullable error) {
        if (completionHandler) completionHandler(identifiers ? identifiers.firstObject : nil, error);
    }];
}

+ (void)writeVideoToAlbum:(id)videoPath completionHandler:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completionHandler
{
    if (!videoPath || (![videoPath isKindOfClass:NSString.class] && ![videoPath isKindOfClass:NSURL.class])) {
        if (completionHandler) completionHandler(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"视频文件不存在"}]);
        return;
    }
    NSString *filePath = [videoPath isKindOfClass:NSString.class] ? videoPath : ((NSURL *)videoPath).path;
    if ([NSFileManager.defaultManager fileExistsAtPath:filePath] == NO) {
        if (completionHandler) completionHandler(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"视频文件不存在"}]);
        return;
    }
    [self writeAssets:@[videoPath] toAlbum:nil completion:^(NSArray<NSString *> * _Nullable identifiers, NSError * _Nullable error) {
        if (completionHandler) completionHandler(identifiers ? identifiers.firstObject : nil, error);
    }];
}

+ (void)writeAssets:(NSArray <id>*)assets toAlbum:(NSString *)albumName completion:(void(^)(NSArray<NSString *>*, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (assets.count <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"文件不存在"}]);
            });
            return;
        }
        [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (allowed) {
                NSMutableArray <NSString *>*identifiers = @[].mutableCopy;
                NSMutableArray <PHObjectPlaceholder *>*placeholders = @[].mutableCopy;
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        PHObjectPlaceholder *placeholder;
                        if ([obj isKindOfClass:NSString.class]) obj = [NSURL fileURLWithPath:(NSString *)obj];
                        if ([obj isKindOfClass:NSData.class]) obj = [UIImage imageWithData:(NSData *)obj];
                        if ([obj isKindOfClass:NSURL.class] && ![NSFileManager.defaultManager fileExistsAtPath:((NSURL*)obj).path]) return;
                        if ([obj isKindOfClass:NSURL.class]) {
                            placeholder = [[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:(NSURL *)obj] placeholderForCreatedAsset];
                        } else if ([obj isKindOfClass:UIImage.class]) {
                            placeholder = [[PHAssetChangeRequest creationRequestForAssetFromImage:(UIImage *)obj] placeholderForCreatedAsset];
                        }
    #if __has_include(<Photos/PHLivePhoto.h>)
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunguarded-availability"
                        else if ([obj isKindOfClass:NSArray.class] && [obj count] == 2) {
                            NSArray *array = (NSArray *)obj;
                            NSURL *firstURL = [array.firstObject isKindOfClass:NSURL.class] ? array.firstObject : [NSURL fileURLWithPath:array.firstObject];
                            NSURL *lastURL = [array.lastObject isKindOfClass:NSURL.class] ? array.lastObject : [NSURL fileURLWithPath:array.lastObject];
                            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                            [request addResourceWithType:([firstURL.pathExtension.lowercaseString isEqualToString:@"mov"] ? PHAssetResourceTypePairedVideo : PHAssetResourceTypePhoto) fileURL:firstURL options:nil];
                            [request addResourceWithType:([lastURL.pathExtension.lowercaseString isEqualToString:@"mov"] ? PHAssetResourceTypePairedVideo : PHAssetResourceTypePhoto) fileURL:lastURL options:nil];
                            placeholder = [request placeholderForCreatedAsset];
                        }
    #pragma clang diagnostic pop
    #endif
                        if (placeholder) {
                            [identifiers addObject:placeholder.localIdentifier];
                            [placeholders addObject:placeholder];
                        }
                    }];
                    if (placeholders.count) {
                        PHAssetCollectionChangeRequest *collectionRequest = [self creationRequestForAssetCollectionWithTitle:albumName];
                        if (collectionRequest) {
                            [collectionRequest addAssets:placeholders];
                        }
                    }
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(success ? identifiers : nil, success ? nil : error);
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获得系统相册权限"}]);
                });
            }
        }];
    });
}

+ (PHAssetCollectionChangeRequest *)creationRequestForAssetCollectionWithTitle:(NSString *)title {
    if (!title) return nil;
    if (title.length <= 0) title = [[NSBundle mainBundle] infoDictionary][(__bridge NSString*)kCFBundleNameKey];
    if (title.length <= 0) return nil;
    // 从用户相簿集合查找
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

+ (void)deleteAssets:(NSArray <MNAsset *>*)assets
          completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray <PHAsset *>*array = @[].mutableCopy;
        [assets enumerateObjectsUsingBlock:^(MNAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.asset) [array addObject:obj.asset];
        }];
        if (array.count <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion([NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"文件不存在"}]);
            });
            return;
        }
        [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (!allowed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion([NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获得系统相册权限"}]);
                });
                return;
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:array];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(error);
                });
            }];
        }];
    });
}

#if __has_include(<Photos/PHLivePhoto.h>)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
+ (void)writeLivePhotoWithImagePath:(id)imagePath videoPath:(id)videoPath completion:(void(^)(NSString *, NSError *))completion {
    NSURL *videoURL = [videoPath isKindOfClass:NSURL.class] ? videoPath : [NSURL fileURLWithPath:videoPath];
    NSURL *imageURL = [imagePath isKindOfClass:NSURL.class] ? imagePath : [NSURL fileURLWithPath:imagePath];
    if (![NSFileManager.defaultManager fileExistsAtPath:imageURL.path] || ![NSFileManager.defaultManager fileExistsAtPath:videoURL.path]) {
        if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"LivePhoto文件不存在"}]);
        return;
    }
    [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            __block NSString *identifier;
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imageURL options:nil];
                [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoURL options:nil];
                identifier = [[request placeholderForCreatedAsset] localIdentifier];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(success ? identifier : nil, success ? nil : error);
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获得系统相册权限"}]);
            });
        }
    }];
}

+ (void)extractLivePhotoResources:(PHLivePhoto *)livePhoto completion:(void(^_Nullable)(NSString *_Nullable, NSString *_Nullable))completion {
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", NSUUID.UUID.UUIDString, @(__COUNTER__)];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheDirectory = [cachePath stringByAppendingPathComponent:@"live-extract"];
    NSString *imagePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fileName]];
    NSString *videoPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]];
    [self extractLivePhotoResources:livePhoto imagePath:imagePath videoPath:videoPath completion:^(BOOL result) {
        if (!result) {
            [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
            [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
        }
        if (completion) completion((result ? imagePath : nil), (result ? videoPath : nil));
    }];
}

+ (void)extractLivePhotoResources:(PHLivePhoto *)livePhoto imagePath:(NSString *)imagePath videoPath:(NSString *)videoPath completion:(void(^_Nullable)(BOOL))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!livePhoto || imagePath.length <= 0 || videoPath.length <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO);
            });
            return;
        }
        NSString *imageDirectory = imagePath.stringByDeletingLastPathComponent;
        NSString *videoDirectory = imagePath.stringByDeletingLastPathComponent;
        if ([NSFileManager.defaultManager fileExistsAtPath:imagePath]) [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
        if ([NSFileManager.defaultManager fileExistsAtPath:videoPath]) [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
        if ((![NSFileManager.defaultManager fileExistsAtPath:imageDirectory] && ![NSFileManager.defaultManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil]) || (![NSFileManager.defaultManager fileExistsAtPath:videoDirectory] && ![NSFileManager.defaultManager createDirectoryAtPath:videoDirectory withIntermediateDirectories:YES attributes:nil error:nil])) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(NO);
            });
            return;
        }
        if ([NSFileManager.defaultManager fileExistsAtPath:imagePath]) [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
        if ([NSFileManager.defaultManager fileExistsAtPath:videoPath]) [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
        dispatch_group_t group = dispatch_group_create();
        NSArray <PHAssetResource *>*liveResource = [PHAssetResource assetResourcesForLivePhoto:livePhoto];
        for (PHAssetResource *resource in liveResource) {
            dispatch_group_enter(group);
            NSMutableData *buffer = NSMutableData.data;
            PHAssetResourceType type = resource.type;
            PHAssetResourceRequestOptions *options = [[PHAssetResourceRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            [PHAssetResourceManager.defaultManager requestDataForAssetResource:resource options:options dataReceivedHandler:^(NSData * _Nonnull data) {
                [buffer appendData:data];
            } completionHandler:^(NSError * _Nullable error) {
                if (!error) {
                    if (type == PHAssetResourceTypePairedVideo) {
                        [buffer writeToFile:videoPath options:NSDataWritingAtomic error:nil];
                    } else {
                        [buffer writeToFile:imagePath options:NSDataWritingAtomic error:nil];
                    }
                }
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completion) completion(([NSFileManager.defaultManager fileExistsAtPath:imagePath] && [NSFileManager.defaultManager fileExistsAtPath:videoPath]));
        });
    });
}
#pragma clang diagnostic pop
#endif
@end
#endif
