//
//  MNAssetCell.h
//  MNKit
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源Cell

#import "MNCollectionViewCell.h"
@class MNAssetPickConfiguration, MNAsset, MNAssetCell;

NS_ASSUME_NONNULL_BEGIN

@protocol MNAssetCellDelegate <NSObject>
/**获取资源选择配置*/
- (MNAssetPickConfiguration *_Nullable)assetPickingConfiguration;
/**选择了资源*/
- (void)didSelectAsset:(MNAsset *)model;
@end

@interface MNAssetCell : MNCollectionViewCell

/**资源模型*/
@property (nonatomic, strong) MNAsset *asset;

@end

NS_ASSUME_NONNULL_END

