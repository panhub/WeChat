//
//  MNCollectionTextLayout.h
//  MNKit
//
//  Created by Vincent on 2018/10/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  文字约束

#import "MNCollectionViewLayout.h"

typedef NS_ENUM(NSInteger, MNTextLayoutAlignment) {
    MNTextLayoutAlignmentLeft = 0,
    MNTextLayoutAlignmentCenter,
    MNTextLayoutAlignmentRight
};

@class MNCollectionTextLayout;

@protocol MNCollectionTextLayoutDataSource <UICollectionViewDataSource>
@optional
- (MNTextLayoutAlignment)textLayoutAlignmentForCollectionView:(UICollectionView *)collectionView layout:(MNCollectionTextLayout *)collectionViewLayout;
@end

@interface MNCollectionTextLayout : MNCollectionViewLayout

@property (nonatomic) MNTextLayoutAlignment textAlignment;

@end


