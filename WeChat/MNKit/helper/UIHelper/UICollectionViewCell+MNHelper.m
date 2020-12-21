//
//  UICollectionViewCell+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UICollectionViewCell+MNHelper.h"

@implementation UICollectionViewCell (MNHelper)

#pragma mark - 寻找自身所在的CollectionView
- (UICollectionView *)collectionView {
    UIResponder *responder = self.nextResponder;
    while (responder && ![responder isKindOfClass:[UICollectionView class]]) {
        responder = [responder nextResponder];
    }
    return responder ? (UICollectionView *)responder : nil;
}

@end
