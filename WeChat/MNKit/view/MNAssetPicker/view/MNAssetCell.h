//
//  MNAssetCell.h
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源Cell

#import "MNCollectionViewCell.h"
#import "MNAssetPickProtocol.h"
@class MNAssetPickConfiguration, MNAsset, MNAssetCell;

@protocol MNAssetCellDelegate <NSObject>

- (BOOL)assetCellShouldDisplaySelectControl;

- (void)didSelectAsset:(MNAsset *)model;

@end

@interface MNAssetCell : MNCollectionViewCell

@property (nonatomic, strong) MNAsset *asset;

@end

