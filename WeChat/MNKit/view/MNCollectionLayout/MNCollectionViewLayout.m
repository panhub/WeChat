//
//  MNCollectionViewLayout.m
//  MNKit
//
//  Created by Vincent on 2018/10/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCollectionViewLayout.h"
#import "MNCollectionVerticalLayout.h"
#import "MNCollectionHorizontalLayout.h"

MNCollectionElementKind const MNCollectionElementKindSectionHeader = @"com.mn.collection.element.kind.section.header";
MNCollectionElementKind const MNCollectionElementKindSectionFooter = @"com.mn.collection.element.kind.section.footer";

MNCollectionElementReuseIdentifier const MNCollectionElementCellReuseIdentifier = @"com.mn.collection.element.reuseIdentifier";
MNCollectionElementReuseIdentifier const MNCollectionElementSectionFooterReuseIdentifier = @"com.mn.collection.element.section.footer.reuseIdentifier";
MNCollectionElementReuseIdentifier const MNCollectionElementSectionHeaderReuseIdentifier = @"com.mn.collection.element.section.header.reuseIdentifier";

@interface MNCollectionViewLayout ()
@property (nonatomic, weak) id<MNCollectionViewLayoutDataSource> layout_source;
@property (nonatomic, strong, readwrite) NSMutableArray <NSMutableArray <NSNumber *>*>*formationContents;
@property (nonatomic, strong, readwrite) NSMutableArray <NSMutableArray <UICollectionViewLayoutAttributes *>*>*sectionItemAttributes;
@property (nonatomic, strong, readwrite) NSMutableArray <UICollectionViewLayoutAttributes *>*allItemAttributes;
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSNumber *, UICollectionViewLayoutAttributes *>*headerAttributes;
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSNumber *, UICollectionViewLayoutAttributes *>*footerAttributes;
@property (nonatomic, strong, readwrite) NSMutableArray <NSValue *>*unionRects;
@end

@implementation MNCollectionViewLayout
@synthesize numberOfFormation = _numberOfFormation;

- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialized];
    }
    return self;
}

+ (instancetype)layoutWithScrollDirection:(MNCollectionViewScrollDirection)scrollDirection {
    if (scrollDirection == MNCollectionViewScrollDirectionVertical) {
        return [MNCollectionVerticalLayout layout];
    }
    return [MNCollectionHorizontalLayout layout];
}

+ (instancetype)layout {
    return [MNCollectionVerticalLayout layout];
}

- (void)initialized {
    _numberOfFormation = 2;
    _minimumLineSpacing = 7.f;
    _minimumInteritemSpacing = 7.f;
    _contentSize = CGSizeZero;
    _itemSize = CGSizeZero;
    _headerInset = UIEdgeInsetsZero;
    _footerInset = UIEdgeInsetsZero;
    _sectionInset = UIEdgeInsetsZero;
    _headerReferenceSize = CGSizeZero;
    _footerReferenceSize = CGSizeZero;
}

#pragma mark - Get
- (NSMutableArray <NSMutableArray <NSNumber *>*>*)formationContents {
    if (!_formationContents) {
        _formationContents = [NSMutableArray array];
    }
    return _formationContents;
}

- (NSMutableArray <NSMutableArray <UICollectionViewLayoutAttributes *>*>*)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

- (NSMutableArray <UICollectionViewLayoutAttributes *>*)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableDictionary <NSNumber *, UICollectionViewLayoutAttributes *>*)headerAttributes {
    if (!_headerAttributes) {
        _headerAttributes = [NSMutableDictionary dictionary];
    }
    return _headerAttributes;
}

- (NSMutableDictionary <NSNumber *, UICollectionViewLayoutAttributes *>*)footerAttributes {
    if (!_footerAttributes) {
        _footerAttributes = [NSMutableDictionary dictionary];
    }
    return _footerAttributes;
}

- (NSUInteger)numberOfFormation {
    return _numberOfFormation;
}

#pragma mark - Set
- (void)setNumberOfFormation:(NSUInteger)numberOfFormation {
    if (numberOfFormation == _numberOfFormation) return;
    _numberOfFormation = numberOfFormation;
    [self invalidateLayout];
}

- (void)setItemSize:(CGSize)itemSize {
    if (CGSizeEqualToSize(itemSize, _itemSize)) return;
    _itemSize = itemSize;
    [self invalidateLayout];
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    if (minimumLineSpacing == _minimumLineSpacing) return;
    _minimumLineSpacing = minimumLineSpacing;
    [self invalidateLayout];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    if (minimumInteritemSpacing == _minimumInteritemSpacing) return;
    _minimumInteritemSpacing = minimumInteritemSpacing;
    [self invalidateLayout];
}

- (void)setHeaderReferenceSize:(CGSize)headerReferenceSize {
    if (CGSizeEqualToSize(headerReferenceSize, _headerReferenceSize)) return;
    _headerReferenceSize = headerReferenceSize;
    [self invalidateLayout];
}

- (void)setFooterReferenceSize:(CGSize)footerReferenceSize {
    if (CGSizeEqualToSize(footerReferenceSize, _footerReferenceSize)) return;
    _footerReferenceSize = footerReferenceSize;
    [self invalidateLayout];
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(headerInset, _headerInset)) return;
    _headerInset = headerInset;
    [self invalidateLayout];
}

- (void)setFooterInset:(UIEdgeInsets)footerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(footerInset, _footerInset)) return;
    _footerInset = footerInset;
    [self invalidateLayout];
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (UIEdgeInsetsEqualToEdgeInsets(sectionInset, _sectionInset)) return;
    _sectionInset = sectionInset;
    [self invalidateLayout];
}

#pragma mark -  数据获取
- (NSInteger)numberOfFormationInSection:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:numberOfFormationInSection:)]) {
        return [_layout_source collectionView:self.collectionView layout:self numberOfFormationInSection:section];
    }
    return self.numberOfFormation;
}

- (CGFloat)minimumInteritemSpacingInSection:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        return [_layout_source collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return _minimumInteritemSpacing;
}

- (CGFloat)minimumLineSpacingInSection:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        return [_layout_source collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return _minimumLineSpacing;
}

- (UIEdgeInsets)sectionInsetAtIndex:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        return [_layout_source collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return _sectionInset;
}

- (CGSize)itemSizeOfIndexPath:(NSIndexPath *)indexPath {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [_layout_source collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    }
    return _itemSize;
}

- (CGSize)referenceSizeForHeaderInSection:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        return [_layout_source collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
    };
    return _headerReferenceSize;
}

- (CGSize)referenceSizeForFooterInSection:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        return [_layout_source collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
    };
    return _footerReferenceSize;
}

- (UIEdgeInsets)headerInsetAtIndex:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:insetForHeaderAtIndex:)]) {
        return [_layout_source collectionView:self.collectionView layout:self insetForHeaderAtIndex:section];
    }
    return _headerInset;
}

- (UIEdgeInsets)footerInsetInSection:(NSInteger)section {
    if ([_layout_source respondsToSelector:@selector(collectionView:layout:insetForFooterAtIndex:)]) {
        return [_layout_source collectionView:self.collectionView layout:self insetForFooterAtIndex:section];
    }
    return _footerInset;
}

#pragma mark - 寻找较短一列
- (NSUInteger)shortestFormationIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    [self.formationContents[section] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    return index;
}

#pragma mark - 寻找较长一列
- (NSUInteger)longestFormationIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    [self.formationContents[section] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    return index;
}

#pragma mark - super class
/**即将重载*/
- (void)prepareLayout {
    [super prepareLayout];
    [self.headerAttributes removeAllObjects];
    [self.footerAttributes removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.formationContents removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    if (!_layout_source && [self.collectionView.dataSource conformsToProtocol:@protocol(MNCollectionViewLayoutDataSource)]) {
        _layout_source = (id<MNCollectionViewLayoutDataSource>)(self.collectionView.dataSource);
    }
}

/**内容尺寸*/
- (CGSize)collectionViewContentSize {
    CGSize contentSize = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size;
    if (self.formationContents.count <= 0) {
        if ([self isKindOfClass:[MNCollectionHorizontalLayout class]]) {
            contentSize.width = self.contentSize.width;
        } else {
            contentSize.height = self.contentSize.height;
        }
    } else {
        if ([self isKindOfClass:[MNCollectionHorizontalLayout class]]) {
            CGFloat contentWidth = [[[self.formationContents lastObject] firstObject] floatValue];
            contentSize.width = MAX(contentWidth, self.contentSize.width);
        } else {
            CGFloat contentHeight = [[[self.formationContents lastObject] firstObject] floatValue];
            contentSize.height = MAX(contentHeight, self.contentSize.height);
        }
    }
    return contentSize;
}

/**指定item的约束对象*/
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= [self.sectionItemAttributes count]) return nil;
    if (indexPath.item >= [self.sectionItemAttributes[indexPath.section] count]) return nil;
    return (self.sectionItemAttributes[indexPath.section])[indexPath.item];
}

/**追加视图*/
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes;
    if ([kind isEqualToString:MNCollectionElementKindSectionHeader]) {
        attributes = self.headerAttributes[@(indexPath.section)];
    } else if ([kind isEqualToString:MNCollectionElementKindSectionFooter]) {
        attributes = self.footerAttributes[@(indexPath.section)];
    }
    return attributes;
}

/**指定范围的约束对象集合*/
- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableDictionary *cellAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *footerAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *decorAttributes = [NSMutableDictionary dictionary];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i*MNUnionRectCycleSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1)*MNUnionRectCycleSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attributes = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            switch (attributes.representedElementCategory) {
                case UICollectionElementCategorySupplementaryView:
                    if ([attributes.representedElementKind isEqualToString:MNCollectionElementKindSectionHeader]) {
                        headerAttributes[attributes.indexPath] = attributes;
                    } else if ([attributes.representedElementKind isEqualToString:MNCollectionElementKindSectionFooter]) {
                        footerAttributes[attributes.indexPath] = attributes;
                    }
                    break;
                case UICollectionElementCategoryDecorationView:
                    decorAttributes[attributes.indexPath] = attributes;
                    break;
                case UICollectionElementCategoryCell:
                    cellAttributes[attributes.indexPath] = attributes;
                    break;
            }
        }
    }
    
    NSArray *result = [cellAttributes.allValues arrayByAddingObjectsFromArray:headerAttributes.allValues];
    result = [result arrayByAddingObjectsFromArray:footerAttributes.allValues];
    result = [result arrayByAddingObjectsFromArray:decorAttributes.allValues];
    return result;
}

/**装饰视图*/
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForDecorationViewOfKind:decorationViewKind atIndexPath:indexPath];
}

/**Bounds变化是否重载*/
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size);
}

@end
