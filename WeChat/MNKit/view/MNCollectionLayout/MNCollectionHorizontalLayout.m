//
//  MNCollectionHorizontalLayout.m
//  MNKit
//
//  Created by Vincent on 2018/10/22.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCollectionHorizontalLayout.h"

@implementation MNCollectionHorizontalLayout

+ (instancetype)layout {
    return [[NSClassFromString(@"MNCollectionHorizontalLayout") alloc] init];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) return;
    
    NSUInteger formation = [self numberOfFormationInSection:0];
    if (formation == 0) return;
    
    CGSize contentSize = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size;
    CGFloat contentHeight = contentSize.height;
    if (contentHeight <= 0.f || self.collectionView.frame.size.width <= 0.f) return;
    
    UIEdgeInsets headerInset = [self headerInsetAtIndex:0];
    CGSize headerSize = [self referenceSizeForHeaderInSection:0];
    UIEdgeInsets footerInset = [self footerInsetInSection:0];
    CGSize footerSize = [self referenceSizeForFooterInSection:0];
    UIEdgeInsets sectionInset = [self sectionInsetAtIndex:0];
    CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingInSection:0];
    
    /**计算item高度*/
    CGFloat height = contentHeight - headerInset.top - headerSize.height - headerInset.bottom - sectionInset.top - sectionInset.bottom - footerInset.top - footerSize.height - footerInset.bottom;
    CGFloat itemHeight = (height - (formation - 1)*minimumInteritemSpacing)/formation;
    
    NSAssert(itemHeight > 0, @"item height is 0 unable");
    
    CGFloat top = headerInset.top;
    UICollectionViewLayoutAttributes *attributes;
    
    if (headerSize.width > 0 && headerSize.height > 0) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MNCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        /**这里的宽度,后面还要根据item修改*/
        attributes.frame = CGRectMake(headerInset.left,
                                      top,
                                      headerSize.width,
                                      headerSize.height);
        
        self.headerAttributes[@(0)] = attributes;
        [self.allItemAttributes addObject:attributes];
        
        top = CGRectGetMaxY(attributes.frame);
    }

    top += headerInset.bottom;
    top += sectionInset.top;
    
    NSInteger idx = 0, left = sectionInset.left;
    
    /**占位*/
    NSMutableArray *formationWidth = [NSMutableArray arrayWithCapacity:formation];
    for (idx = 0; idx < formation; idx++) {
        [formationWidth addObject:@(left)];
    }
    [self.formationContents addObject:formationWidth];
    
    CGFloat minimumLineSpacing = [self minimumLineSpacingInSection:0];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
    for (idx = 0; idx < itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        NSUInteger shortestLineIndex = [self shortestFormationIndexInSection:0];
        CGFloat x = [self.formationContents[0][shortestLineIndex] floatValue];
        CGFloat y = top + (itemHeight + minimumInteritemSpacing)*shortestLineIndex;
        CGSize itemSize = [self itemSizeOfIndexPath:indexPath];
        CGFloat itemWidth = 0.f;
        /**倍数计算*/
        if (itemSize.height > 0.f && itemSize.width > 0.f) {
            itemWidth = (itemHeight/itemSize.height)*itemSize.width;
        }
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(x, y, itemWidth, itemHeight);
        [itemAttributes addObject:attributes];
        [self.allItemAttributes addObject:attributes];
        self.formationContents[0][shortestLineIndex] = @(CGRectGetMaxX(attributes.frame) + minimumLineSpacing);
    }
    
    [self.sectionItemAttributes addObject:itemAttributes];
    
    NSUInteger longestLineIndex = [self longestFormationIndexInSection:0];
    left = [self.formationContents[0][longestLineIndex] floatValue];
    if (itemAttributes.count > 0) left -= minimumLineSpacing;
    
    left += sectionInset.right;
    
    /**修改最大宽度*/
    CGFloat contentWidth = contentSize.width;
    CGFloat max = MAX(contentWidth, left);
    max = MAX(max, headerInset.left + headerInset.right);
    max = MAX(max, footerInset.left + footerInset.right);
    
    /**保存最大一行宽度*/
    [[self.formationContents firstObject] removeAllObjects];
    [self.formationContents removeAllObjects];
    formationWidth = [NSMutableArray arrayWithCapacity:formation];
    for (idx = 0; idx < formation; idx++) {
        [formationWidth addObject:@(max)];
    }
    [self.formationContents addObject:formationWidth];
    
    /**判断是否需要修改区头宽度*/
    attributes = self.headerAttributes[@(0)];
    if (attributes) {
        CGRect frame = attributes.frame;
        frame.size.width = max - headerInset.left - headerInset.right;
        attributes.frame = frame;
    }
    
    /**实际行数*/
    NSInteger line = MIN(itemCount, 3);
    if (line > 0) {
        top += ((line - 1)*minimumInteritemSpacing + itemHeight*line);
    }
    
    top += sectionInset.bottom;
    top += footerInset.top;
    
    if (footerSize.width > 0.f && footerSize.height > 0.f) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MNCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        attributes.frame = CGRectMake(footerInset.left,
                                      top,
                                      max - footerInset.left - footerInset.right,
                                      footerSize.height);
        
        self.footerAttributes[@(0)] = attributes;
        [self.allItemAttributes addObject:attributes];
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
