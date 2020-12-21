//
//  MNAssetCollection.m
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetCollection.h"

@implementation MNAssetCollection
- (void)addAsset:(MNAsset *)asset {
    NSMutableArray *dataArray = self.assets.mutableCopy;
    if (dataArray.count) {
        MNAsset *model = [dataArray lastObject];
        if (model.isCapturingModel) {
            [dataArray insertObject:asset atIndex:[dataArray indexOfObject:model]];
        } else {
            [dataArray addObject:asset];
        }
    } else {
        [dataArray addObject:asset];
    }
    self.assets = dataArray.copy;
    MNAsset *model = [dataArray firstObject];
    if (model.isCapturingModel) {
        self.thumbnail = self.assets[1].thumbnail;
    } else {
        self.thumbnail = model.thumbnail;
    }
}

- (void)insertAssetAtFront:(MNAsset *)asset {
    NSMutableArray *dataArray = self.assets.mutableCopy;
    if (dataArray.count) {
        MNAsset *model = [dataArray firstObject];
        if (model.isCapturingModel) {
            [dataArray insertObject:asset atIndex:1];
        } else {
            [dataArray insertObject:asset atIndex:0];
        }
    } else {
        [dataArray insertObject:asset atIndex:0];
    }
    self.assets = dataArray.copy;
    MNAsset *model = [dataArray firstObject];
    if (model.isCapturingModel) {
        self.thumbnail = self.assets[1].thumbnail;
    } else {
        self.thumbnail = model.thumbnail;
    }
}

- (void)removeAllAssets {
    self.assets = @[];
}

- (void)removeAssets:(NSArray <MNAsset *>*)assets {
    if (!self.assets) return;
    NSMutableArray <MNAsset *>*temp = NSMutableArray.array;
    [temp addObjectsFromArray:self.assets];
    [temp removeObjectsInArray:assets];
    self.assets = temp.copy;
}

@end
