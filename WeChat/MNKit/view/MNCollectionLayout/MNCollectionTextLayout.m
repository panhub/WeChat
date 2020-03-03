//
//  MNCollectionTextLayout.m
//  MNKit
//
//  Created by Vincent on 2018/10/22.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCollectionTextLayout.h"

@interface MNCollectionTextLayout ()
@property (nonatomic, weak) id<MNCollectionTextLayoutDataSource> text_layout_source;
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *>*lineItems;
@end

@implementation MNCollectionTextLayout

+ (instancetype)layout {
    return [[NSClassFromString(@"MNCollectionTextLayout") alloc]init];
}

- (void)initialized {
    [super initialized];
    _lineItems = [NSMutableArray arrayWithCapacity:0];
    _textAlignment = MNTextLayoutAlignmentLeft;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    if (!_text_layout_source && [self.collectionView.dataSource conformsToProtocol:@protocol(MNCollectionTextLayoutDataSource)]) {
        _text_layout_source = (id<MNCollectionTextLayoutDataSource>)(self.collectionView.dataSource);
    }
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) return;

    /**占位*/
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:1];
        [sectionColumnHeights addObject:@(0.f)];
        [self.formationContents addObject:sectionColumnHeights];
    }
    
    NSInteger idx = 0;
    CGFloat top = 0.f;
    UICollectionViewLayoutAttributes *attributes;
    /**内容最大宽度*/
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat contentWidth = UIEdgeInsetsInsetRect(self.collectionView.bounds, contentInset).size.width;
    for (NSInteger section = 0; section < numberOfSections; section++) {
        CGFloat headerHeight = [self referenceSizeForHeaderInSection:section].height;
        UIEdgeInsets headerInset = [self headerInsetAtIndex:section];
        top += headerInset.top;
        if (headerHeight > 0.f) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:MNCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left,
                                          top,
                                          contentWidth - (headerInset.left + headerInset.right),
                                          headerHeight);
            
            self.headerAttributes[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame);
        }
        top += headerInset.bottom;
        UIEdgeInsets sectionInset = [self sectionInsetAtIndex:section];
        top += sectionInset.top;
        
        CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingInSection:section];
        CGFloat minimumLineSpacing = [self minimumLineSpacingInSection:section];
        
        CGFloat left = sectionInset.left, right = sectionInset.right;
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        [_lineItems removeAllObjects];
        
        /**下一个item*/
        CGFloat x = left;
        CGFloat _top = top;
        /**最大长度*/
        CGFloat max = contentWidth - left - right;
        /** item 约束*/
        for (idx = 0; idx < itemCount; idx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            CGSize itemSize = [self itemSizeOfIndexPath:indexPath];
            /**大于最大长度时无法添加*/
            NSString *des = [NSString stringWithFormat:@"beyond line max width %.2f, \n section'%ld' item'%ld'",max,(long)section,(long)idx];
            NSAssert(itemSize.width <= max, des);
            /**实时查询剩余宽度, 寻求换行*/
            if (itemSize.width > (contentWidth - x - right)) {
                /**检查自适应*/
                [self itemAdaptLayoutHorizontal:(contentWidth - right - x + minimumInteritemSpacing)
                                       vertical:(_top - minimumLineSpacing - top)];
                /**更新下一行起始值*/
                top = _top;
                x = left;
            }
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(x, top, itemSize.width, itemSize.height);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            [_lineItems addObject:attributes];
            /**更新x值*/
            x += (itemSize.width + minimumInteritemSpacing);
            /**计算若此时换行的y(top)值*/
            _top = MAX(_top, CGRectGetMaxY(attributes.frame) + minimumLineSpacing);
        }
        
        /**检查自适应*/
        [self itemAdaptLayoutHorizontal:(contentWidth - right - x + minimumInteritemSpacing)
                               vertical:(_top - minimumLineSpacing - top)];
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        /**只要添加, 最后要减去行间隔*/
        if (itemAttributes.count > 0) top = _top - minimumLineSpacing;
        
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
        
        /**添加高度, 便于后期计算内容视图大小*/
        self.formationContents[section][0] = @(top);
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

#pragma mark - 自适应处理
- (void)itemAdaptLayoutHorizontal:(CGFloat)horizontal vertical:(CGFloat)vertical {
    MNTextLayoutAlignment alignment = self.textAlignment;
    if (alignment == MNTextLayoutAlignmentCenter) {
        [_lineItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = attribute.frame;
            frame.origin.x += horizontal/2.f;
            if (frame.size.height != vertical) {
                frame.origin.y += (vertical - frame.size.height)/2.f;
            }
            attribute.frame = frame;
        }];
    } else if (alignment == MNTextLayoutAlignmentRight) {
        [_lineItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = attribute.frame;
            frame.origin.x += horizontal;
            attribute.frame = frame;
        }];
    }
    [_lineItems removeAllObjects];
}

- (MNTextLayoutAlignment)textAlignment {
    if ([_text_layout_source respondsToSelector:@selector(textLayoutAlignmentForCollectionView:layout:)]) {
        return [_text_layout_source textLayoutAlignmentForCollectionView:self.collectionView layout:self];
    }
    return _textAlignment;
}

@end
