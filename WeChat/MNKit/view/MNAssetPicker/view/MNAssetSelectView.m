//
//  MNAssetSelectView.m
//  MNFoundation
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetSelectView.h"
#import "MNAssetSelectCell.h"
#import "MNAsset.h"

@interface MNAssetSelectView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, copy) NSArray <MNAsset *>*assets;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation MNAssetSelectView
- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray <MNAsset *>*)assets {
    if (self = [super initWithFrame:frame]) {
        
        self.assets = assets;
        
        self.backgroundColor = UIColorWithRGBA(32.f, 32.f, 35.f, .45f);
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 13.f;
        layout.minimumInteritemSpacing = 0.f;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.headerReferenceSize = CGSizeZero;
        layout.footerReferenceSize = CGSizeZero;
        layout.sectionInset = UIEdgeInsetWith(13.f);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.height_mn - 26.f, self.height_mn - 26.f);
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView adjustContentInset];
        [collectionView registerClass:[MNAssetSelectCell class]
           forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return self;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MNAssetSelectCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.asset = self.assets[indexPath.item];
    cell.select = indexPath.item == self.selectIndex;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.selectIndex) return;
    if ([self.delegate respondsToSelector:@selector(selectView:didSelectItemAtIndex:)]) {
        [self.delegate selectView:self didSelectItemAtIndex:indexPath.item];
    }
}

#pragma mark - Setter
- (void)setSelectIndex:(NSInteger)selectIndex {
    NSInteger lastSelectIndex = self.selectIndex;
    _selectIndex = selectIndex;
    [self updateBottomMarginIfNeeded];
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:lastSelectIndex inSection:0], [NSIndexPath indexPathForItem:selectIndex inSection:0]]];
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) self.delegate = (id<MNAssetSelectViewDelegate>)self.viewController;
}

#pragma mark - Method
- (void)updateBottomMarginIfNeeded {
    MNAsset *asset = self.assets[self.selectIndex];
    if (asset.type == MNAssetTypeVideo) {
        if (self.bottom_mn < self.superview.height_mn) return;
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.height_mn = self.collectionView.height_mn;
            self.bottom_mn = self.superview.height_mn - UITabSafeHeight() - MNAssetSelectBottomMaxMargin;
        } completion:nil];
    } else {
        if (self.bottom_mn == self.superview.height_mn) return;
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.height_mn = self.collectionView.height_mn + UITabSafeHeight() + MNAssetSelectBottomMinMargin;
            self.bottom_mn = self.superview.height_mn;
        } completion:nil];
    }
}


@end
