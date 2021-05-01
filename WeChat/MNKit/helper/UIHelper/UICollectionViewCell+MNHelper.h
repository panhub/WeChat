//
//  UICollectionViewCell+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (MNHelper)

/**
 寻找自身所在的CollectionView
 */
@property (nonatomic, readonly, nullable) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END


