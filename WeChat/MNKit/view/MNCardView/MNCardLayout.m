//
//  MNCardLayout.m
//  MNKit
//
//  Created by Vincent on 2018/3/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCardLayout.h"

@interface MNCardLayout()

@end

@implementation MNCardLayout
- (instancetype)init {
    if (self = [super init]) {
        self.type = MNCardLayoutTypeZoom;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    UIEdgeInsets sectionInset = self.sectionInset;
    CGFloat margin = (self.collectionView.frame.size.height - sectionInset.top - sectionInset.bottom - self.itemSize.height)/2.f;
    sectionInset.top += margin;
    sectionInset.bottom += margin;
    self.sectionInset = sectionInset;
}

#pragma mark - 重新修改布局对象
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    /**宽度*/
    CGFloat width = self.collectionView.bounds.size.width;
    /**屏幕中线*/
    CGFloat centerX = self.collectionView.contentOffset.x + width/2.f;
    /**扩大控制范围，防止出现闪屏现象*/
    CGRect newRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0.f, -width, 0.f, -width));
    /**避免不必要的bug, 先copy一份*/
    NSArray <UICollectionViewLayoutAttributes *>*attributes = [[super layoutAttributesForElementsInRect:newRect] copy];
    if (self.type == MNCardLayoutTypeZoom) {
        [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
            /**计算间距*/
            CGFloat distance = fabs(attribute.center.x - centerX);
            /**间距占宽比 0 - 1*/
            CGFloat scale = distance/width;
            /**设置cell的缩放 按照余弦函数曲线 越居中越趋近于1*/
            /**固定到 -π/3到 +π/3范围内*/
            scale = fabs(cos(M_PI/3.f*scale));
            attribute.transform = CGAffineTransformMakeScale(scale, scale);
        }];
    } else {
        [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat distance = attribute.center.x - centerX;
            CGFloat scale = distance/width;
            scale = scale > 0.f ? MIN(scale, 1.f) : MAX(-1.f, scale);
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = -1.f/300.f;
            transform = CATransform3DMakeRotation(M_PI_2*scale, 0, 1, 0);
            attribute.transform3D = transform;
        }];
    }
    return attributes;
}

#pragma mark - 刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(self.collectionView.bounds, newBounds);
}

@end
