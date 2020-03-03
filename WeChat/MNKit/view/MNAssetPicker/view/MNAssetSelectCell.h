//
//  MNAssetSelectCell.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  预览时底部选择Cell

#import "MNCollectionViewCell.h"
@class MNAsset;

@interface MNAssetSelectCell : MNCollectionViewCell

@property (nonatomic, getter=isSelect) BOOL select;

@property (nonatomic, strong) MNAsset *asset;

@end
