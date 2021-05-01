//
//  MNCardView.m
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCardView.h"
#import "MNCardLayout.h"

@interface MNCardView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, weak) UICollectionView *collectionView;
@end

NSString * const MNCardItemReuseIdentifier = @"com.mn.card.item.identifier";

@implementation MNCardView
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    [self initialized];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self initialized];
    return self;
}

- (void)initialized {
    _currentIndex = 0;
    _numberOfCards = 0;
    _initializedIndex = 0;
    _minimumLineSpacing = 15.f;
    //_transitionType = MNCardViewTransitionTypeZoom;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!_collectionView) [self createView];
}

- (void)createView {
    Class itemClass = self.itemClass;
    if (!itemClass) return;
    
    MNCardLayout *collectionLayout = [MNCardLayout new];
    collectionLayout.minimumLineSpacing = self.minimumLineSpacing;
    collectionLayout.itemSize = self.itemSize;
    collectionLayout.type = MNCardLayoutTypeZoom;//(MNCardLayoutType)(self.transitionType);
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = NO;
    collectionView.userInteractionEnabled = YES;
    collectionView.contentInset = UIEdgeInsetsZero;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [collectionView registerClass:itemClass forCellWithReuseIdentifier:MNCardItemReuseIdentifier];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfCards;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCardItemReuseIdentifier forIndexPath:indexPath];
    if ([_dataSource respondsToSelector:@selector(cardView:dequeueReusableCard:atIndexPath:)]) {
        [_dataSource cardView:self dequeueReusableCard:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:0];
    if (indexPath.item >= numberOfItems) return;
    _currentIndex = indexPath.item;
    [self scrollCurrentItemToCenter:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(cardView:didSelectCardAtIndexPath:)]) {
            [_delegate cardView:self didSelectCardAtIndexPath:indexPath];
        }
    });
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.isDragging) return;
    [self updateCurrentIndexIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentIndexIfNeeded];
    if (self.isPagingEnabled) {
        [self fixCurrentItemToCenter];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isPagingEnabled && !decelerate) {
        [self fixCurrentItemToCenter];
    }
}

#pragma mark - 更新当前索引
- (void)updateCurrentIndexIfNeeded {
    if (_collectionView.visibleCells.count <= 0) return;
    __block CGFloat margin = CGFLOAT_MAX;
    __block UICollectionViewCell *item;
    [_collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect = [obj.superview convertRect:obj.frame toView:self];
        CGFloat _margin = fabs(CGRectGetMidX(rect) - self.frame.size.width/2.f);
        if (_margin < margin) {
            margin = _margin;
            item = obj;
        }
    }];
    if (!item) return;
    _currentIndex = [[_collectionView indexPathForCell:item] item];
}

#pragma mark - 移动卡片到中间位置
- (void)fixCurrentItemToCenter {
    if (_collectionView.visibleCells.count <= 0) return;
    __block UICollectionViewCell *item;
    [_collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[_collectionView indexPathForCell:obj] item] == _currentIndex) {
            item = obj;
            *stop = YES;
            return;
        }
    }];
    if (!item) return;
    CGRect rect = [item.superview convertRect:item.frame toView:self];
    if (fabs(CGRectGetMidX(rect) - self.frame.size.width/2.f) <= rect.size.width/2.f) {
        [self scrollCurrentItemToCenter:YES];
        return;
    }
    if ((CGRectGetMidX(rect) - self.frame.size.width/2.f) > rect.size.width/2.f) {
        /// 向前滚动
        _currentIndex --;
    } else if ((CGRectGetMidX(rect) - self.frame.size.width/2.f) < -rect.size.width/2.f) {
        /// 向后滚动
        _currentIndex ++;
    }
    /**保证数组不能越界*/
    _currentIndex = MIN(MAX(0, _currentIndex), MAX(0, [_collectionView numberOfItemsInSection:0] - 1));
    [self scrollCurrentItemToCenter:YES];
}

#pragma mark - 滚动当前卡片到中心位置
- (void)scrollCurrentItemToCenter:(BOOL)animated {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

#pragma mark - Reload Data
- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_collectionView reloadData];
        NSUInteger numberOfItems = [_collectionView numberOfItemsInSection:0];
        if (numberOfItems <= 0) return;
        _currentIndex =  _initializedIndex < numberOfItems ? _initializedIndex : 0;
        [self scrollCurrentItemToCenter:NO];
    });
}

#pragma mark - 移动制定卡片索引到中间位置
- (void)scrollCardToCenterOfIndex:(NSInteger)index animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger numberOfCards = [_collectionView numberOfItemsInSection:0];
        if (numberOfCards <= 0 || index >= numberOfCards) return;
        _currentIndex = index;
        [self scrollCurrentItemToCenter:animated];
    });
}

#pragma mark - Getter
- (CGFloat)minimumLineSpacing {
    if ([_dataSource respondsToSelector:@selector(cardViewMinimumLineSpacing:)]) {
        return [_dataSource cardViewMinimumLineSpacing:self];
    }
    return _minimumLineSpacing;
}

- (CGSize)itemSize {
    if ([_dataSource respondsToSelector:@selector(cardViewItemSize:)]) {
        return [_dataSource cardViewItemSize:self];
    }
    return _itemSize;
}

- (Class)itemClass {
    if ([_dataSource respondsToSelector:@selector(cardViewItemClass:)]) {
        return [_dataSource cardViewItemClass:self];
    }
    return _itemClass;
}

- (NSUInteger)numberOfCards {
    if ([_dataSource respondsToSelector:@selector(numberOfCardsInView:)]) {
        return [_dataSource numberOfCardsInView:self];
    }
    return _numberOfCards;
}

- (NSString *)reuseIdentifier {
    return MNCardItemReuseIdentifier;
}

@end
