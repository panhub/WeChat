//
//  UICollectionView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (MNHelper)

/**快速实例化*/
+ (__kindof UICollectionView *)collectionViewWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout;

@end

NS_ASSUME_NONNULL_END

