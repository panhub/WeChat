//
//  MNAlbumCell.h
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  相簿Cell

#import "MNTableViewCell.h"
@class MNAssetCollection;

@interface MNAlbumCell : MNTableViewCell

@property (nonatomic, strong) MNAssetCollection *model;

@end
