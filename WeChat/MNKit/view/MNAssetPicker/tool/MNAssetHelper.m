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
        NSMutableArray <MNAssetCollection *>*collections = [NSMutableArray arrayWithCapacity:1];
        /// 获取全部相册数据
        PHFetchResult<PHAssetCollection *> *smartResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [smartResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:PHAssetCollection.class] || obj.estimatedAssetCount <= 0) return;
            if ([MNAssetHelper isCameraCollection:obj]) {
                MNAssetCollection *collection = [MNAssetHelper fetchAssetCollection:obj configuration:configuration];
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
            MNAssetCollection *collection = [MNAssetHelper fetchAssetCollection:obj configuration:configuration];
            if (collection.assets.count <= 0 && !configuration.isShowEmptyAlbum) return;
            [collections addObject:collection];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(collections.count > 0 ? collections.copy : nil);
        });
    });
}

+ (MNAssetCollection *)fetchAssetCollection:(PHAssetCollection *)collection configuration:(MNAssetPickConfiguration *)configuration {
    // 检索选项
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!configuration.isAllowsPickingVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    } else if (!configuration.isAllowsPickingPhoto && !configuration.isAllowsPickingLivePhoto && !configuration.isAllowsPickingGif) {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    } else {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:configuration.isSortAscending]];
    // 检索数据
    NSMutableArray <MNAsset *>*assets = [NSMutableArray arrayWithCapacity:0];
    PHFetchResult<PHAsset *>*result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    [assets addObjectsFromArray:[self fetchAssetsInResult:result configuration:configuration]];
#if !TARGET_IPHONE_SIMULATOR
    /// 判断是否需要添加拍照模型<仅全部照片需要添加>
    if ([self isCameraCollection:collection] && configuration.isAllowsTakeAsset && (configuration.isAllowsPickingPhoto || configuration.isAllowsPickingVideo)) {
        MNAsset *model = [MNAsset takeModel];
        if (configuration.isAllowsPickingVideo && !configuration.isAllowsPickingPhoto) {
            model.thumbnail = [MNBundle imageForResource:@"icon_takevideoHL"];
        }
        if (configuration.isSortAscending) {
            [assets addObject:model];
        } else {
            [assets insertObject:model atIndex:0];
        }
    }
#endif
    MNAssetCollection *assetCollection = [MNAssetCollection new];
    assetCollection.result = result;
    assetCollection.collection = collection;
    assetCollection.title = collection.localizedTitle ? : @"未知相簿";
    if ([MNAssetHelper isCameraCollection:collection]) assetCollection.title = @"相机胶卷";
    [assetCollection addAssets:assets];
    return assetCollection;
}

+ (NSArray <MNAsset *>*)fetchAssetsInResult:(PHFetchResult<PHAsset *>*)result configuration:(MNAssetPickConfiguration *)configuration {
    NSMutableArray <MNAsset *>*assets = [NSMutableArray arrayWithCapacity:0];
    CGSize renderSize = (!configuration || CGSizeIsEmpty(configuration.renderSize)) ? CGSizeMake(350.f, 350.f) : configuration.renderSize;
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        MNAssetType type = [self assetTypeWithPHAsset:asset];
        if (type == MNAssetTypeVideo) {
            // 不符合视频选择时长
            NSTimeInterval duration = floor(asset.duration);
            if ((configuration.minExportDuration > 0.f && duration < configuration.minExportDuration) || (configuration.maxExportDuration > 0.f && duration > configuration.maxExportDuration && (!configuration.isAllowsEditing || configuration.maxPickingCount > 1))) return;
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
        model.renderSize = renderSize;
        if (type == MNAssetTypeVideo) {
            model.duration = asset.duration;
            model.durationString = [NSDate timeStringWithInterval:@(asset.duration)];
        }
        [assets addObject:model];
    }];
    return assets.copy;
}

+ (MNAssetType)assetTypeWithPHAsset:(PHAsset *)asset {
    MNAssetType type = MNAssetTypePhoto;
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage:
        {
            if ([[[((NSString *)[asset valueForKey:@"filename"]) pathExtension] lowercaseString] containsString:@"gif"]) {
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

+ (BOOL)isCameraCollection:(PHAssetCollection *)collection {
    if (collection.assetCollectionType != PHAssetCollectionTypeSmartAlbum) return NO;
    PHAssetCollectionSubtype subtype = (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_2) ? PHAssetCollectionSubtypeSmartAlbumRecentlyAdded : PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    return collection.assetCollectionSubtype == subtype;
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
                    [model updateThumbnail:result];
                }
            }];
        });
    }
    /// 获取来源
    if (model.source == MNAssetSourceUnknown) {
        if (model.type == MNAssetTypeVideo) {
            self.videoOptions.networkAccessAllowed = NO;
            [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:self.videoOptions resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info){
                [model updateSource:avasset ? MNAssetSourceResource : MNAssetSourceCloud];
            }];
        } else {
            /// 请求data 才会准确返回 PHImageResultIsInCloudKey 值
            self.imageOptions.networkAccessAllowed = NO;
            self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:self.imageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                [model updateSource:[[info objectForKey:PHImageResultIsInCloudKey] boolValue] ? MNAssetSourceCloud : MNAssetSourceResource];
            }];
        }
    }
    /// 获取文件大小
    if (model.fileSizeString.length <= 0 && !model.isTakeModel) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (model.asset) {
                if (@available(iOS 9.0, *)) {
                    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:model.asset];
                    long long fileSize = 0;
                    for (PHAssetResource *resource in resources) {
                        fileSize += [[resource valueForKey:@"fileSize"] longLongValue];
                    }
                    [model updateFileSize:fileSize];
                } else {
                    [model updateFileSize:0];
                }
            } else {
                [model updateFileSize:0];
            }
        });
    }
}

+ (void)requestThumbnailWithAssets:(NSArray <MNAsset *>*)models atIndex:(NSInteger)index container:(NSMutableArray <MNAsset *>*)container completion:(void(^)(NSArray <MNAsset *>*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (index >= models.count) {
            if (completion) completion(container.copy);
            return;
        }
        MNAsset *model = models[index];
        [[MNAssetHelper helper] requestAssetThumbnail:model completion:^(MNAsset * _Nullable asset) {
            if (asset) [container addObject:asset];
            [MNAssetHelper requestThumbnailWithAssets:models atIndex:index + 1 container:container completion:completion];
        }];
    });
}

- (void)requestAssetThumbnail:(MNAsset *)model completion:(void(^)(MNAsset *))completion {
    if (model.thumbnail) {
        if (completion) completion(model);
        return;
    }
    self.imageOptions.networkAccessAllowed = NO;
    self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:model.renderSize contentMode:PHImageContentModeAspectFill options:self.imageOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        BOOL succeed = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue] && result);
        if (succeed && result) {
            result = [result resizingOrientation];
            [model updateThumbnail:result];
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
    if (model.isTakeModel) {
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
            [model updateThumbnail:result];
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
        [model updateStatus:MNAssetStatusDownloading];
    }
    if (model.type == MNAssetTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            [model updateProgress:progress];
        };
        model.downloadId = [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if (asset && [asset isKindOfClass:AVURLAsset.class]) {
                AVURLAsset *avasset = (AVURLAsset *)asset;
                model.content = avasset.URL.path;
                [model updateStatus:MNAssetStatusCompleted];
                [model updateSource:MNAssetSourceResource];
            } else {
                [model updateStatus:MNAssetStatusFailed];
                [model updateSource:MNAssetSourceCloud];
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
                [model updateProgress:progress];
            };
            model.downloadId = [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                if (livePhoto) {
                    model.content = livePhoto;
                    [model updateStatus:MNAssetStatusCompleted];
                    [model updateSource:MNAssetSourceResource];
                } else {
                    [model updateStatus:MNAssetStatusFailed];
                    [model updateSource:MNAssetSourceCloud];
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
            [model updateProgress:progress];
        };
        model.downloadId = [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image;
            if (model.type == MNAssetTypePhoto) {
                if (configuration.isAllowsExportHEIF) {
                    image = [UIImage imageWithData:imageData];
                } else {
                    if (model.asset.isHEIF) {
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
                [model updateStatus:MNAssetStatusCompleted];
                [model updateSource:MNAssetSourceResource];
            } else {
                [model updateStatus:MNAssetStatusFailed];
                [model updateSource:MNAssetSourceCloud];
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
        [model updateStatus:MNAssetStatusDownloading];
        [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:model.url] options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (expectedSize <= 0) return;
            double pro = receivedSize*1.f/(expectedSize*1.f);
            [model updateProgress:pro];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress) progress(pro, nil, model);
            });
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (finished == NO) return;
            if (image) {
                model.url = nil;
                model.content = image;
                [model updateStatus:MNAssetStatusCompleted];
                [model updateSource:MNAssetSourceResource];
            } else {
                [model updateStatus:MNAssetStatusFailed];
                [model updateSource:MNAssetSourceCloud];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(model);
            });
        }];
#else
        if (completion) completion(model);
#endif
        return;
    }
    if (!model.asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(0.f, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"相册资源项为空"}], model);
            if (completion) completion(model);
        });
        return;
    }
    if (model.type == MNAssetTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.progressHandler = ^(double pro, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            [model updateProgress:pro];
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
                [model updateStatus:MNAssetStatusCompleted];
                [model updateSource:MNAssetSourceResource];
            } else {
                [model updateStatus:MNAssetStatusFailed];
                [model updateSource:MNAssetSourceCloud];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(model);
            });
        }];
    } else if (model.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            CGSize targetSize = CGSizeIsEmpty(model.asset.pixelSize) ? PHImageManagerMaximumSize : model.asset.pixelSize;
            PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.progressHandler = ^(double pro, NSError *error, BOOL *stop, NSDictionary *info) {
                [model updateProgress:pro];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress) progress(pro, error, model);
                });
            };
            model.requestId = [[PHImageManager defaultManager] requestLivePhotoForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                model.requestId = PHInvalidImageRequestID;
                if (livePhoto) {
                    model.content = livePhoto;
                    [model updateStatus:MNAssetStatusCompleted];
                    [model updateSource:MNAssetSourceResource];
                } else {
                    [model updateStatus:MNAssetStatusFailed];
                    [model updateSource:MNAssetSourceCloud];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(model);
                });
            }];
        }
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.progressHandler = ^(double pro, NSError *error, BOOL *stop, NSDictionary *info) {
            [model updateProgress:pro];
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
                [model updateStatus:MNAssetStatusCompleted];
                [model updateSource:MNAssetSourceResource];
            } else {
                [model updateStatus:MNAssetStatusFailed];
                [model updateSource:MNAssetSourceCloud];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(model);
            });
        }];
    }
}

+ (void)requestAssetWithLocalIdentifiers:(NSArray <NSString *>*)identifiers configuration:(MNAssetPickConfiguration *)configuration completion:(void(^)(NSArray <MNAsset *>*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!identifiers || identifiers.count <= 0) {
            if (completion) completion(nil);
            return;
        }
        PHFetchResult<PHAsset *>*result = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
        NSArray <MNAsset *>*assets = [self fetchAssetsInResult:result configuration:configuration];
        if (assets.count <= 0) {
            if (completion) completion(nil);
            return;
        }
        [self requestThumbnailWithAssets:assets atIndex:0 container:NSMutableArray.new completion:completion];
    });
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
+ (void)exportLivePhotoResources:(PHLivePhoto *)livePhoto completion:(void(^_Nullable)(NSString *_Nullable, NSString *_Nullable))completion {
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", NSUUID.UUID.UUIDString, @(__COUNTER__)];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheDirectory = [cachePath stringByAppendingPathComponent:@"live-extract"];
    NSString *imagePath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fileName]];
    NSString *videoPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]];
    [self exportLivePhotoResources:livePhoto imagePath:imagePath videoPath:videoPath completion:^(BOOL result) {
        if (!result) {
            [NSFileManager.defaultManager removeItemAtPath:imagePath error:nil];
            [NSFileManager.defaultManager removeItemAtPath:videoPath error:nil];
        }
        if (completion) completion((result ? imagePath : nil), (result ? videoPath : nil));
    }];
}

+ (void)exportLivePhotoResources:(PHLivePhoto *)livePhoto imagePath:(NSString *)imagePath videoPath:(NSString *)videoPath completion:(void(^_Nullable)(BOOL))completion {
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

#pragma mark - Write
+ (void)writeImageToAlbum:(id)image completion:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completionHandler
{
    if ([image isKindOfClass:NSString.class] && [NSFileManager.defaultManager fileExistsAtPath:(NSString *)image]) {
        if ([((NSString *)image).pathExtension.lowercaseString isEqualToString:@"gif"]) {
            image = [NSURL fileURLWithPath:(NSString *)image];
        } else {
            image = [UIImage imageWithContentsOfFile:(NSString *)image];
        }
    } else if ([image isKindOfClass:NSURL.class] && [NSFileManager.defaultManager fileExistsAtPath:((NSURL *)image).path]) {
        if (![((NSURL *)image).path.pathExtension.lowercaseString isEqualToString:@"gif"]) {
            image = [UIImage imageWithContentsOfFile:((NSURL *)image).path];
        }
    } else if ([image isKindOfClass:NSData.class]) {
        image = [UIImage imageWithData:(NSData *)image];
    }
    if (!image || (![image isKindOfClass:UIImage.class] && ![image isKindOfClass:NSURL.class])) {
        if (completionHandler) completionHandler(nil, [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"图片不存在"}]);
        return;
    }
    [self writeAssets:@[image] toAlbum:nil completion:^(NSArray<NSString *> * _Nullable identifiers, NSError * _Nullable error) {
        if (completionHandler) completionHandler(identifiers ? identifiers.firstObject : nil, error);
    }];
}

+ (void)writeVideoToAlbum:(id)videoPath completion:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completionHandler
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
                NSMutableArray <NSString *>*identifiers = [NSMutableArray arrayWithCapacity:assets.count];
                NSMutableArray <PHObjectPlaceholder *>*placeholders = [NSMutableArray arrayWithCapacity:assets.count];
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        PHObjectPlaceholder *placeholder;
                        if ([obj isKindOfClass:NSString.class]) {
                            if ([NSFileManager.defaultManager fileExistsAtPath:(NSString *)obj]) {
                                obj = [NSURL fileURLWithPath:(NSString *)obj];
                            } else return;
                        } else if ([obj isKindOfClass:NSData.class]) {
                            obj = [UIImage imageWithData:(NSData *)obj];
                        } else if ([obj isKindOfClass:NSURL.class] && ((NSURL *)obj).isFileURL && ![NSFileManager.defaultManager fileExistsAtPath:((NSURL*)obj).path]) return;
                        if ([obj isKindOfClass:NSURL.class]) {
                            if ([((NSURL *)obj).path.pathExtension.lowercaseString isEqualToString:@"gif"]) {
                                placeholder = [[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:(NSURL *)obj] placeholderForCreatedAsset];
                            } else {
                                placeholder = [[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:(NSURL *)obj] placeholderForCreatedAsset];
                            }
                        } else if ([obj isKindOfClass:UIImage.class]) {
                            placeholder = [[PHAssetChangeRequest creationRequestForAssetFromImage:(UIImage *)obj] placeholderForCreatedAsset];
                        }
    #if __has_include(<Photos/PHLivePhoto.h>)
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunguarded-availability"
                        else if ([obj isKindOfClass:PHLivePhoto.class]) {
                            NSURL *videoURL = [obj valueForKey:@"videoURL"];
                            NSURL *imageURL = [obj valueForKey:@"imageURL"];
                            if ([NSFileManager.defaultManager fileExistsAtPath:videoURL.path] && [NSFileManager.defaultManager fileExistsAtPath:imageURL.path]) {
                                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imageURL options:nil];
                                [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoURL options:nil];
                                placeholder = [request placeholderForCreatedAsset];
                            }
                        } else if ([obj isKindOfClass:NSArray.class] && ((NSArray *)obj).count == 2) {
                            NSArray *array = (NSArray *)obj;
                            NSURL *firstURL = [array.firstObject isKindOfClass:NSURL.class] ? array.firstObject : ([array.firstObject isKindOfClass:NSString.class] ? [NSURL fileURLWithPath:array.firstObject] : nil);
                            NSURL *lastURL = [array.lastObject isKindOfClass:NSURL.class] ? array.lastObject : ([array.lastObject isKindOfClass:NSString.class] ? [NSURL fileURLWithPath:array.lastObject] : nil);
                            NSURL *videoURL = [firstURL.path.pathExtension.lowercaseString isEqualToString:@"mov"] ? firstURL : lastURL;
                            NSURL *imageURL = videoURL == firstURL ? lastURL : firstURL;
                            if (videoURL.isFileURL && imageURL.isFileURL && [NSFileManager.defaultManager fileExistsAtPath:videoURL.path] && [NSFileManager.defaultManager fileExistsAtPath:imageURL.path]) {
                                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
                                [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imageURL options:nil];
                                [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoURL options:nil];
                                placeholder = [request placeholderForCreatedAsset];
                            }
                        }
    #pragma clang diagnostic pop
    #endif
                        if (placeholder) {
                            [placeholders addObject:placeholder];
                            [identifiers addObject:placeholder.localIdentifier];
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

#if __has_include(<Photos/PHLivePhoto.h>)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
+ (void)writeLivePhoto:(PHLivePhoto *)livePhoto completion:(void(^_Nullable)(NSString *_Nullable identifier, NSError *_Nullable error))completion {
    [self writeLivePhotoWithImagePath:[livePhoto valueForKey:@"imageURL"] videoPath:[livePhoto valueForKey:@"videoURL"] completion:completion];
}

+ (void)writeLivePhotoWithImagePath:(id)imagePath videoPath:(id)videoPath completion:(void(^)(NSString *, NSError *))completion {
    NSURL *videoURL = [videoPath isKindOfClass:NSString.class] ? [NSURL fileURLWithPath:videoPath] : ([videoPath isKindOfClass:NSURL.class] ? videoPath : nil);
    NSURL *imageURL = [imagePath isKindOfClass:NSString.class] ? [NSURL fileURLWithPath:imagePath] : ([imagePath isKindOfClass:NSURL.class] ? imagePath : nil);
    if (!videoURL.isFileURL || !imageURL.isFileURL || ![NSFileManager.defaultManager fileExistsAtPath:videoURL.path] || ![NSFileManager.defaultManager fileExistsAtPath:imageURL.path]) {
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
#pragma clang diagnostic pop
#endif

#pragma mark - Delete
+ (void)deleteAssets:(NSArray <PHAsset *>*)assets completion:(void(^)(NSError *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (assets.count <= 0) {
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
                [PHAssetChangeRequest deleteAssets:assets.copy];
            } completionHandler:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion(error);
                });
            }];
        }];
    });
}
@end
#endif
