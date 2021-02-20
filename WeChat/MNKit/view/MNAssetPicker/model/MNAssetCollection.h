//
//  MNAssetCollection.h
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  相簿

#import <Foundation/Foundation.h>
@class PHAsset, PHAssetCollection, MNAsset;

NS_ASSUME_NONNULL_BEGIN

@interface MNAssetCollection : NSObject
/**
 相簿展示名称
 */
@property (nonatomic, copy, nullable) NSString *title;
/**
 系统相簿
 */
@property (nonatomic, strong) PHAssetCollection *collection;
/**
 相簿缩略图
 */
@property (nonatomic, strong, nullable) UIImage *thumbnail;
/**
 相簿检索结果
 */
@property (nonatomic, strong) PHFetchResult *result;
/**
 相簿资源内容
 */
@property (nonatomic, strong) NSMutableArray <MNAsset *>*assets;

/**
 添加资源
 @param asset 资源模型
 */
- (void)addAsset:(MNAsset *)asset;
/**
 插入资源
 @param asset 资源模型
 */
- (void)insertAssetAtFront:(MNAsset *)asset;
/**
 删除所有资源
 */
- (void)removeAllAssets;
/**
 删除指定资源
 @param assets 指定资源
 */
- (void)removeAssets:(NSArray <MNAsset *>*)assets;
/**
 添加指定资源
 @param assets 指定资源
 */
- (void)addAssets:(NSArray <MNAsset *>*)assets;
#if __has_include(<Photos/Photos.h>)
/**
 删除相册资源
 @param assets 指定资源
 */
- (void)removePHAssets:(NSArray <PHAsset *>*)assets;
#endif

@end
NS_ASSUME_NONNULL_END
