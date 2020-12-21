//
//  UICollectionView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UICollectionView+MNHelper.h"
#import "UIScrollView+MNHelper.h"

@implementation UICollectionView (MNHelper)
#pragma mark - 快速实例化
+ (UICollectionView *)collectionViewWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout {
    if (!layout) return nil;
    UICollectionView *collectionView = [[self alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView adjustContentInset];
    return collectionView;
}

@end
