//
//  MNAssetCollection.m
//  MNChat
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetCollection.h"

@implementation MNAssetCollection
- (instancetype)init {
    if (self = [super init]) {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didReceiveMemoryWarningNotification:)
                                                   name:UIApplicationDidReceiveMemoryWarningNotification
                                                 object:nil];
    }
    return self;
}

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

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    [self.assets setValue:nil forKey:@"content"];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
