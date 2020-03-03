//
//  UICollectionViewCell+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewCell (MNHelper)

/**
 寻找自身所在的CollectionView
 */
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

/**
 自身的索引
 */
@property (nonatomic, strong, readonly) NSIndexPath *index_path;

@end


