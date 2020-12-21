//
//  MNCollectionViewLayout.h
//  MNKit
//
//  Created by Vincent on 2018/10/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  瀑布流布局

#import <UIKit/UIKit.h>

/**计算区域大小的遍历周期*/
static const NSInteger MNUnionRectCycleSize = 20;

typedef NSString * MNCollectionElementKind;
UIKIT_EXTERN MNCollectionElementKind const MNCollectionElementKindSectionHeader;
UIKIT_EXTERN MNCollectionElementKind const MNCollectionElementKindSectionFooter;

typedef NSString * MNCollectionElementReuseIdentifier;
UIKIT_EXTERN MNCollectionElementReuseIdentifier const MNCollectionElementCellReuseIdentifier;
UIKIT_EXTERN MNCollectionElementReuseIdentifier const MNCollectionElementSectionFooterReuseIdentifier;
UIKIT_EXTERN MNCollectionElementReuseIdentifier const MNCollectionElementSectionHeaderReuseIdentifier;

typedef NS_ENUM(NSInteger, MNCollectionViewScrollDirection) {
    MNCollectionViewScrollDirectionVertical,
    MNCollectionViewScrollDirectionHorizontal
};

@class MNCollectionViewLayout;

@protocol MNCollectionViewLayoutDataSource <UICollectionViewDataSource>
@optional
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout insetForHeaderAtIndex:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout insetForFooterAtIndex:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout numberOfFormationInSection:(NSInteger)section;
@end


@interface MNCollectionViewLayout : UICollectionViewLayout
/**大小*/
@property (nonatomic) CGSize itemSize;
/**滑动方向的间隔*/
@property (nonatomic) CGFloat minimumLineSpacing;
/**滑动相反方向的间隔*/
@property (nonatomic) CGFloat minimumInteritemSpacing;
/**区头大小(竖向取高度, 纵向取宽度)*/
@property (nonatomic) CGSize headerReferenceSize;
/**区尾大小(竖向取高度, 纵向取宽度)*/
@property (nonatomic) CGSize footerReferenceSize;
/**区头间隔*/
@property (nonatomic) UIEdgeInsets headerInset;
/**区尾间隔*/
@property (nonatomic) UIEdgeInsets footerInset;
/**区间隔*/
@property (nonatomic) UIEdgeInsets sectionInset;
/**纵向列数, 横向行数*/
@property (nonatomic) NSUInteger numberOfFormation;
/**指定内容尺寸*/
@property (nonatomic) CGSize contentSize;
/**区内每一列(行)高(宽)缓存*/
@property (nonatomic, strong, readonly) NSMutableArray <NSMutableArray <NSNumber *>*>*formationContents;
/**区内item布局对象缓存*/
@property (nonatomic, strong, readonly) NSMutableArray <NSMutableArray <UICollectionViewLayoutAttributes *>*>*sectionItemAttributes;
/**所有布局对象(包括区头区尾)缓存*/
@property (nonatomic, strong, readonly) NSMutableArray <UICollectionViewLayoutAttributes *>*allItemAttributes;
/**区头布局对象缓存*/
@property (nonatomic, strong, readonly) NSMutableDictionary <NSNumber *, UICollectionViewLayoutAttributes *>*headerAttributes;
/**区尾布局对象缓存*/
@property (nonatomic, strong, readonly) NSMutableDictionary <NSNumber *, UICollectionViewLayoutAttributes *>*footerAttributes;
/**周期内布局对象的范围, 便于后期计算返回*/
@property (nonatomic, strong, readonly) NSMutableArray <NSValue *>*unionRects;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

+ (instancetype)layout;
+ (instancetype)layoutWithScrollDirection:(MNCollectionViewScrollDirection)scrollDirection;

- (void)initialized __attribute__((objc_requires_super));

#pragma mark - 数据获取
/**区列数*/
- (NSInteger)numberOfFormationInSection:(NSInteger)section;
/**滑动相反方向的间隔*/
- (CGFloat)minimumInteritemSpacingInSection:(NSInteger)section;
/**滑动方向上的间隔*/
- (CGFloat)minimumLineSpacingInSection:(NSInteger)section;
/**区 inset*/
- (UIEdgeInsets)sectionInsetAtIndex:(NSInteger)section;
/**Item Size*/
- (CGSize)itemSizeOfIndexPath:(NSIndexPath *)indexPath;
/**区头大小*/
- (CGSize)referenceSizeForHeaderInSection:(NSInteger)section;
/**区尾大小*/
- (CGSize)referenceSizeForFooterInSection:(NSInteger)section;
/**区头 inset*/
- (UIEdgeInsets)headerInsetAtIndex:(NSInteger)section;
/**区尾 inset*/
- (UIEdgeInsets)footerInsetInSection:(NSInteger)section;
/**寻找较短一列*/
- (NSUInteger)shortestFormationIndexInSection:(NSInteger)section;
/**寻找较长一列*/
- (NSUInteger)longestFormationIndexInSection:(NSInteger)section;

@end


