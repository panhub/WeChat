//
//  MNSegmentView.m
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentView.h"
#import "MNSegmentCell.h"
#import "UIView+MNLayout.h"
#import "UIImage+MNHelper.h"

@interface MNSegmentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) BOOL scrollPositionEnabled;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *shadow;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSNumber *>*widthCache;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSString *>*titleCache;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSValue *> *frameCache;
@end

#define kMNSegmentItemIdentifier   @"com.mn.segment.item.identifier"

@implementation MNSegmentView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

#pragma mark - initialized
- (void)initialized {
    self.selectedIndex = 0;
    self.scrollEnabled = YES;
    self.selectEnabled = YES;
    self.scrollPositionEnabled = YES;
    self.updateSelectedIndexEnabled = YES;
    self.titleCache = [NSMutableDictionary dictionary];
    self.widthCache = [NSMutableDictionary dictionary];
    self.frameCache = [NSMutableDictionary dictionary];
}

- (void)createView {
    
    CGFloat h = UIScreen.mainScreen.scale >= 3.f ? .5f : 1.f;

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 0.f;
    layout.minimumInteritemSpacing = 0.f;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, self.height_mn - h) collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:[MNSegmentCell class]
       forCellWithReuseIdentifier:kMNSegmentItemIdentifier];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    UIView *shadow = [UIView new];
    shadow.clipsToBounds = YES;
    [collectionView addSubview:shadow];
    self.shadow = shadow;
    
    UIView *separator = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, h)];
    separator.clipsToBounds = YES;
    [self addSubview:separator];
    self.separator = separator;
}

- (void)reloadRightView {
    [_rightView removeFromSuperview];
    _rightView = nil;
    if ([_dataSource respondsToSelector:@selector(segmentViewShouldLoadRightView)]) {
        _rightView = [_dataSource segmentViewShouldLoadRightView];
        if (_rightView) {
            _rightView.right_mn = self.width_mn;
            _rightView.centerY_mn = self.height_mn/2.f;
            [self insertSubview:_rightView belowSubview:self.separator];
            _collectionView.width_mn = self.width_mn - _rightView.width_mn;
        }
    }
}

- (void)layoutSubviews {
    self.separator.bottom_mn = self.height_mn;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titleCache.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:kMNSegmentItemIdentifier
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MNSegmentCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.title = _titleCache[@(indexPath.item)];
    cell.titleFont = (indexPath.item == _selectedIndex) ? (_configuration.selectedTitleFont ? : _configuration.titleFont) : _configuration.titleFont;
    cell.titleColor = (indexPath.item == _selectedIndex) ? _configuration.selectedColor : _configuration.titleColor;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_updateSelectedIndexEnabled || !_scrollEnabled || !_selectEnabled || indexPath.item == _selectedIndex || indexPath.item >= _titleCache.count) return;
    if ([_delegate respondsToSelector:@selector(segmentView:didSelectItemAtIndex:)]) {
        [_delegate segmentView:self didSelectItemAtIndex:indexPath.item];
    }
    [self scrollShadowToIndex:indexPath.item];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *number = _widthCache[@(indexPath.item)];
    return CGSizeMake([number floatValue], collectionView.height_mn);
}

#pragma mark - 滑动到指定索引<触发外部Page变动>
- (void)selectItemAtIndex:(NSInteger)index {
    if (index == _selectedIndex) return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - Reload Titles
- (void)reloadTitles {
    NSArray <NSString *>*titles;
    if ([_dataSource respondsToSelector:@selector(segmentViewShouldLoadTitles)]) {
        titles = [_dataSource segmentViewShouldLoadTitles];
    }
    if (titles.count <= 0) return;
    [_titleCache removeAllObjects];
    [_widthCache removeAllObjects];
    [_frameCache removeAllObjects];
    __block CGFloat x = 0.f;
    CGFloat h = _configuration.shadowSize.height;
    CGFloat w = _configuration.shadowSize.width;
    UIOffset offset = _configuration.shadowOffset;
    CGFloat y = 0.f;
    if (_configuration.shadowVerticalAlignment == MNSegmentShadowVerticalAlignmentCenter) {
        y = self.collectionView.height_mn/2.f - h/2.f;
    } else if (_configuration.shadowVerticalAlignment == MNSegmentShadowVerticalAlignmentBottom) {
        y = self.collectionView.height_mn - h;
    }
    y += offset.vertical;
    UIFont *font = _configuration.titleFont;
    CGFloat margin = _configuration.titleMargin;
    [_collectionView setContentInset:UIEdgeInsetsZero];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat titleWidth = [title sizeWithAttributes:@{NSFontAttributeName: font}].width;
        CGFloat width = titleWidth + margin;
        [_titleCache setObject:title forKey:@(idx)];
        [_widthCache setObject:@(width) forKey:@(idx)];
        CGRect frame;
        frame.origin.y = y;
        frame.size.height = h;
        if (_configuration.shadowMask == MNSegmentShadowMaskFit) {
            frame.origin.x = x + margin/2.f;
            frame.size.width = titleWidth;
        } else if (_configuration.shadowMask == MNSegmentShadowMaskFill) {
            frame.origin.x = x;
            frame.size.width = width;
        } else if (_configuration.shadowMask == MNSegmentShadowMaskAspectFit) {
            frame.size.width = titleWidth/2.f;
            if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentLeft) {
                frame.origin.x = x + margin/2.f;
            } else if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentRight) {
                frame.origin.x = x + margin/2.f + titleWidth/2.f;
            } else {
                frame.origin.x = x + (width - titleWidth/2.f)/2.f;
            }
        } else {
            frame.size.width = w;
            if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentLeft) {
                frame.origin.x = x + margin/2.f;
            } else if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentRight) {
                frame.origin.x = x + width - margin/2.f - w;
            } else {
                frame.origin.x = x + (width - w)/2.f;
            }
        }
        frame.origin.x += offset.horizontal;
        NSValue *value = [NSValue valueWithCGRect:frame];
        [_frameCache setObject:value forKey:@(idx)];
        x += width;
        if (idx == titles.count - 1 && x < _collectionView.width_mn) {
            if (_configuration.contentMode == MNSegmentContentModeFit) {
                /**标题居中*/
                [self layoutContentFit:x];
            } else if (_configuration.contentMode == MNSegmentContentModeFill) {
                /**标题填满*/
                [self layoutContentFill:titles];
            }
        }
    }];
}

/**充满*/
- (void)layoutContentFill:(NSArray <NSString *>*)titles {
    _scrollPositionEnabled = NO;
    [_widthCache removeAllObjects];
    UIOffset offset = _configuration.shadowOffset;
    CGFloat width = _collectionView.width_mn/titles.count;
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        [_widthCache setObject:@(width) forKey:@(idx)];
        CGRect frame = [_frameCache[@(idx)] CGRectValue];
        if (_configuration.shadowMask == MNSegmentShadowMaskFit) {
            frame.origin.x = width*idx + (width - frame.size.width)/2.f;
        } else if (_configuration.shadowMask == MNSegmentShadowMaskFill) {
            frame.origin.x = width*idx;
            frame.size.width = width;
        } else if (_configuration.shadowMask == MNSegmentShadowMaskAspectFit) {
            CGFloat margin = width - frame.size.width*2.f;
            if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentLeft) {
                frame.origin.x = width*idx + margin/2.f;
            } else if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentRight) {
                frame.origin.x = width*idx + width - margin/2.f - frame.size.width;
            } else {
                frame.origin.x = width*idx + (width - frame.size.width)/2.f;
            }
        } else {
            CGFloat titleWidth = [title sizeWithAttributes:@{NSFontAttributeName: _configuration.titleFont}].width;
            CGFloat margin = width - titleWidth;
            if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentLeft) {
                frame.origin.x = width*idx + margin/2.f;
            } else if (_configuration.shadowHorizontalAlignment == MNSegmentShadowHorizontalAlignmentRight) {
                frame.origin.x = width*idx + width - margin/2.f - frame.size.width;
            } else {
                frame.origin.x = width*idx + (width - frame.size.width)/2.f;
            }
        }
        frame.origin.x += offset.horizontal;
        NSValue *value = [NSValue valueWithCGRect:frame];
        [_frameCache setObject:value forKey:@(idx)];
    }];
}

/**居中*/
- (void)layoutContentFit:(CGFloat)width {
    _scrollPositionEnabled = NO;
    CGFloat inset = (_collectionView.width_mn - width)/2.f;
    [_collectionView setContentInset:UIEdgeInsetsMake(0.f, inset, 0.f, inset)];
}

#pragma mark - Update Selected Index
- (void)updateSelectIndex:(NSInteger)selectIndex {
    _selectedIndex = selectIndex;
    [self displaySelectedShadow];
}

- (void)displaySelectedShadow {
    NSValue *value = _frameCache[@(_selectedIndex)];
    if (!value) return;
    _shadow.frame = value.CGRectValue;
    [_collectionView bringSubviewToFront:_shadow];
}

#pragma mark - Update Selected Shadow
- (void)updateShadowOffsetOfRatio:(CGFloat)ratio {
    if (!_scrollEnabled) return;
    NSInteger fromIndex = ceil(ratio) - 1;
    if (fromIndex < 0 || fromIndex >= (_frameCache.count - 1)) return;
    [self updateHighlightItemWithOffsetRatio:ratio];
    ratio -= (CGFloat)fromIndex;
    CGRect fromFrame = [_frameCache[@(fromIndex)] CGRectValue];
    CGRect toFrame = [_frameCache[@(fromIndex + 1)] CGRectValue];
    CGFloat fromWidth = fromFrame.size.width;
    CGFloat toWidth = toFrame.size.width;
    if (fromWidth != toWidth) {
        _shadow.width_mn = fromWidth + (toWidth - fromWidth)*ratio;
    }
    
    CGFloat firstX = [_frameCache[@(0)] CGRectValue].origin.x;
    CGFloat endX = [_frameCache[@(_frameCache.count - 1)] CGRectValue].origin.x;
    
    CGFloat fromX = fromFrame.origin.x;
    CGFloat toX = toFrame.origin.x;
    CGFloat x = fromX + (toX - fromX)*ratio;
    x = MIN(MAX(x, firstX), endX);
    _shadow.left_mn = x;
}

- (void)updateHighlightItemWithOffsetRatio:(CGFloat)ratio {
    NSInteger toIndex = round(ratio);
    if (index < 0 || toIndex >= _titleCache.count || toIndex == _selectedIndex) return;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
    _selectedIndex = toIndex;
    [UIView performWithoutAnimation:^{
        [_collectionView reloadItemsAtIndexPaths:@[lastIndexPath, currentIndexPath]];
    }];
    if (!_scrollPositionEnabled || _configuration.scrollPosition == MNSegmentScrollPositionNone) return;
    UICollectionViewScrollPosition scrollPosition = UICollectionViewScrollPositionLeft;
    if (_configuration.scrollPosition == MNSegmentScrollPositionCenter) {
        scrollPosition = UICollectionViewScrollPositionCenteredHorizontally;
    } else if (_configuration.scrollPosition == MNSegmentScrollPositionRight) {
        scrollPosition = UICollectionViewScrollPositionRight;
    }
    [_collectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:scrollPosition animated:YES];
}

#pragma mark - Scroll Shadow To Index
- (void)scrollShadowToIndex:(NSInteger)index {
    NSValue *value = _frameCache[@(index)];
    if (!value || !_scrollEnabled) return;
    _scrollEnabled = NO;
    CGRect frame = [value CGRectValue];
    //动画时长稍大一些, 避免滑动中回调影响
    [UIView animateWithDuration:.3f animations:^{
        _shadow.frame = frame;
    } completion:^(BOOL finished) {
        [self updateHighlightItemWithOffsetRatio:index];
        _scrollEnabled = YES;
    }];
}

#pragma mark - Shadow Visible
- (void)makeSeparatorVisible:(BOOL)isVisible {
    self.separator.hidden = !isVisible;
}

#pragma mark - Setter
- (void)setConfiguration:(MNSegmentConfiguration *)configuration {
    if (!configuration) return;
    _configuration = configuration;
    _shadow.backgroundColor = configuration.shadowColor;
    _shadow.layer.cornerRadius = configuration.shadowSize.height/2.f;
    _separator.backgroundColor = configuration.separatorColor;
    self.backgroundColor = configuration.backgroundColor;
}

#pragma mark - Getter
- (NSInteger)numberOfItems {
    return _titleCache.count;
}

#pragma mark - Clean Cache
- (void)cleanCache {
    _shadow.left_mn = 0.f;
    _shadow.width_mn = 0.f;
    [_titleCache removeAllObjects];
    [_widthCache removeAllObjects];
    [_frameCache removeAllObjects];
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayout];
}

- (void)reloadData {
    _scrollEnabled = YES;
    _selectEnabled = YES;
    _scrollPositionEnabled = YES;
    _updateSelectedIndexEnabled = YES;
    [_collectionView reloadData];
}

@end
