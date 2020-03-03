//
//  MNAssetCollection.h
//  MNChat
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  相簿

#import <Foundation/Foundation.h>
#import "MNAsset.h"

@interface MNAssetCollection : NSObject
/**
 相簿展示名称
 */
@property (nonatomic, copy) NSString *title;
/**
 原始相簿名称
 */
@property (nonatomic, copy) NSString *localizedTitle;
/**
 相簿标识符
 */
@property (nonatomic, copy) NSString *identifier;
/**
 相簿缩略图
 */
@property (nonatomic, strong) UIImage *thumbnail;
/**
 相簿资源内容
 */
@property (nonatomic, strong) NSArray <MNAsset *>*dataArray;

- (void)addAsset:(MNAsset *)asset;

- (void)insertAssetAtFront:(MNAsset *)asset;

@end
