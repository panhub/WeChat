//
//  MNCollectionVerticalLayout.m
//  MNKit
//
//  Created by Vincent on 2018/10/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCollectionVerticalLayout.h"

@implementation MNCollectionVerticalLayout
+ (instancetype)layout {
    return [[NSClassFromString(@"MNCollectionVerticalLayout") alloc]init];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) return;
    
    /**可视宽度*/
    CGFloat top = 0.f;
    UICollectionViewLayoutAttributes *attributes;
    CGFloat contentWidth = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size.width;
    
    if (contentWidth <= 0 || self.collectionView.frame.size.height <= 0) return;
    
    NSInteger idx = 0;
    
    /**占位*/
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSUInteger columnCount = [self numberOfFormationInSection:section];
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:columnCount];
        for (idx = 0; idx < columnCount; idx++) {
            [sectionColumnHeights addObject:@(0)];
        }
        [self.formationContents addObject:sectionColumnHeights];
    }

    /**头部*/
    for (NSInteger section = 0; section < numberOfSections; section++) {
        CGFloat headerHeight = [self referenceSizeForHeaderInSection:section].height;
        UIEdgeInsets headerInset = [self headerInsetAtIndex:section];
        top += headerInset.top;
        if (headerHeight > 0.f) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MNCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (headerInset.left + headerInset.right),
                                          headerHeight);
            
            self.headerAttributes[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame);
        }
        top += headerInset.bottom;
        UIEdgeInsets sectionInset = [self sectionInsetAtIndex:section];
        top += sectionInset.top;
        
        NSUInteger columnCount = [self numberOfFormationInSection:section];
        
        for (idx = 0; idx < columnCount; idx++) {
            self.formationContents[section][idx] = @(top);
        }
        
        CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingInSection:section];
        CGFloat width = contentWidth - sectionInset.left - sectionInset.right;
        CGFloat itemWidth = (width - (columnCount - 1)*minimumInteritemSpacing)/columnCount;
        
        NSAssert(itemWidth > 0, @"item width <= 0 unable");
        
        CGFloat minimumLineSpacing = [self minimumLineSpacingInSection:section];
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        /**item*/
        for (idx = 0; idx < itemCount; idx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            NSUInteger nextFormationIndex = [self shortestFormationIndexInSection:section];
            CGFloat x = sectionInset.left + (itemWidth + minimumInteritemSpacing)*nextFormationIndex;
            CGFloat y = [self.formationContents[section][nextFormationIndex] floatValue];
            CGSize itemSize = [self itemSizeOfIndexPath:indexPath];
            CGFloat itemHeight = 0.f;
            /**倍数计算*/
            if (itemSize.height > 0.f && itemSize.width > 0.f) {
                itemHeight = (itemWidth/itemSize.width)*itemSize.height;
            }
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(x, y, itemWidth, itemHeight);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            self.formationContents[section][nextFormationIndex] = @(CGRectGetMaxY(attributes.frame) + minimumLineSpacing);
        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        /**查询最大高度*/
        NSUInteger longestFormationIndex = [self longestFormationIndexInSection:section];
        top = [self.formationContents[section][longestFormationIndex] floatValue];
        if (itemAttributes.count > 0) top -= minimumLineSpacing;
        
        /**尾部*/
        top += sectionInset.bottom;
        
        UIEdgeInsets footerInset = [self footerInsetInSection:section];
        top += footerInset.top;
        
        CGFloat footerHeight = [self referenceSizeForFooterInSection:section].height;
        
        if (footerHeight > 0.f) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MNCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (footerInset.left + footerInset.right),
                                          footerHeight);
            
            self.footerAttributes[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame);
        }
        
        top += footerInset.bottom;
        
        for (idx = 0; idx < columnCount; idx++) {
            self.formationContents[section][idx] = @(top);
        }
    }
    
    /**按固定周期计算范围, 便于后期返回制定范围约束对象*/
    idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = self.allItemAttributes[idx].frame;
        NSInteger rectEndIndex = MIN(idx + MNUnionRectCycleSize, itemCounts);
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, self.allItemAttributes[i].frame);
        }
        idx = rectEndIndex;
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

@end
