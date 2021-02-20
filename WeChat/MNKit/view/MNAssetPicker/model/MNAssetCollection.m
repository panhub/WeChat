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
    @synchronized (self) {
        if (self.assets.count <= 0 || !self.assets.lastObject.isTakeModel) {
            [self.assets addObject:asset];
        } else {
            [self.assets insertObject:asset atIndex:self.assets.count - 1];
        }
        if (self.assets.firstObject.isTakeModel) {
            self.thumbnail = self.assets[1].thumbnail;
        } else {
            self.thumbnail = self.assets.firstObject.thumbnail;
        }
    }
}

- (void)insertAssetAtFront:(MNAsset *)asset {
    @synchronized (self) {
        if (self.assets.count <= 0 || !self.assets.firstObject.isTakeModel) {
            [self.assets insertObject:asset atIndex:0];
        } else {
            [self.assets insertObject:asset atIndex:1];
        }
        if (self.assets.firstObject.isTakeModel) {
            self.thumbnail = self.assets[1].thumbnail;
        } else {
            self.thumbnail = self.assets.firstObject.thumbnail;
        }
    }
}

- (void)removeAllAssets {
    @synchronized (self) {
        [self.assets removeAllObjects];
    }
}

- (void)removeAssets:(NSArray<MNAsset *> *)assets {
    @synchronized (self) {
        [self.assets removeObjectsInArray:assets];
    }
}

- (void)addAssets:(NSArray <MNAsset *>*)assets {
    @synchronized (self) {
        [self.assets addObjectsFromArray:assets];
    }
}

- (void)removePHAssets:(NSArray <PHAsset *>*)phAssets {
    @synchronized (self) {
        NSArray <MNAsset *>*assets = self.assets.copy;
        NSMutableArray <MNAsset *>*array = @[].mutableCopy;
        [phAssets.copy enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *result = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.asset.localIdentifier == %@", obj.localIdentifier]];
            [array addObjectsFromArray:result];
        }];
        [self.assets removeObjectsInArray:array];
    }
}

#pragma mark - Getter
- (NSMutableArray <MNAsset *>*)assets {
    if (!_assets) {
        _assets = NSMutableArray.new;
    }
    return _assets;
}

@end
