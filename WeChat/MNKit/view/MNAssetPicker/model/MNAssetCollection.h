//
//  MNAssetCollection.h
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  相簿

#import <Foundation/Foundation.h>
#import "MNAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNAssetCollection : NSObject
/**
 相簿展示名称
 */
@property (nonatomic, copy, nullable) NSString *title;
/**
 原始相簿名称
 */
@property (nonatomic, copy, nullable) NSString *localizedTitle;
/**
 相簿标识符
 */
@property (nonatomic, copy, nullable) NSString *identifier;
/**
 相簿缩略图
 */
@property (nonatomic, strong, nullable) UIImage *thumbnail;
/**
 相簿资源内容
 */
@property (nonatomic, strong, nullable) NSArray <MNAsset *>*assets;

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

@end
NS_ASSUME_NONNULL_END
