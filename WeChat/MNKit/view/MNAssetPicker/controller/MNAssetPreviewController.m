//
//  MNAssetPreviewController.m
//  MNFoundation
//
//  Created by Vincent on 2019/9/11.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetPreviewController.h"
#import "MNAsset.h"
#import "MNAssetBrowseControl.h"
#import "MNAssetBrowseCell.h"
#import "MNAssetSelectView.h"

@interface MNAssetPreviewController ()<MNAssetSelectViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) NSInteger currentDisplayIndex;
@property (nonatomic, strong) MNAssetSelectView *selectView;
@property (nonatomic, strong) MNAssetBrowseControl *browseControl;
@end

#define kAssetInteritemSpacing  15.f

@implementation MNAssetPreviewController
- (instancetype)initWithAssets:(NSArray <MNAsset *>*)asset {
    if (self = [super init]) {
        self.assets = asset.copy;
        self.allowsSelect = YES;
        self.currentDisplayIndex = -1;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backItemColor = UIColor.whiteColor;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.backgroundImage = [MNBundle imageForResource:@"mask_top"];
    self.navigationBar.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.navigationBar.clipsToBounds = YES;
    
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = UIColor.blackColor;
    
    self.collectionView.frame = CGRectMake(-kAssetInteritemSpacing/2.f, 0.f, self.contentView.width_mn + kAssetInteritemSpacing, self.contentView.height_mn);
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.canCancelContentTouches = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[MNAssetBrowseCell class]
       forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    
    if (self.assets.count <= 1) return;
    MNAssetSelectView *selectView = [[MNAssetSelectView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 100.f) assets:self.assets];
    selectView.height_mn += UITabSafeHeight() + MNAssetSelectBottomMinMargin;
    selectView.bottom_mn = self.contentView.height_mn;
    [self.contentView addSubview:selectView];
    self.selectView = selectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.navigationBar.hidden withAnimation:UIStatusBarAnimationFade];
    if (self.isFirstAppear) [self updateCurrentPageIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[self cellForItemAtCurrentDisplayIndex] endDisplaying];
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(MNAssetBrowseCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell didEndDisplaying];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MNAssetBrowseCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.asset = self.assets[indexPath.item];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self updateCurrentPageIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPageIfNeeded];
}

#pragma mark - Method
- (void)updateCurrentPageIfNeeded {
    NSInteger currentDisplayIndex = self.collectionView.contentOffset.x/self.collectionView.width_mn;
    if (currentDisplayIndex == self.currentDisplayIndex) return;
    self.currentDisplayIndex = currentDisplayIndex;
    [[self cellForItemAtCurrentDisplayIndex] didBeginDisplaying];
    if (self.allowsSelect) [self.browseControl updateAsset:self.assets[currentDisplayIndex]];
    if (self.selectView) self.selectView.selectIndex = currentDisplayIndex;
}

#pragma mark - Event
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    self.navigationBar.hidden = !self.navigationBar.hidden;
    if (self.selectView) self.selectView.hidden = !self.selectView.hidden;
    [[UIApplication sharedApplication] setStatusBarHidden:self.navigationBar.hidden withAnimation:UIStatusBarAnimationNone];
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
    MNAssetBrowseCell *cell = [self cellForItemAtCurrentDisplayIndex];
    if (cell.scrollView.zoomScale > 1.f) {
        [cell.scrollView setZoomScale:1.f animated:YES];
    } else {
        CGPoint touchPoint = [recognizer locationInView:cell.scrollView];
        CGFloat newZoomScale = cell.scrollView.maximumZoomScale;
        CGFloat xsize = cell.scrollView.width_mn/newZoomScale;
        CGFloat ysize = cell.scrollView.height_mn/newZoomScale;
        [cell.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2.f, touchPoint.y - ysize/2.f, xsize, ysize) animated:YES];
    }
}

#pragma mark - MNAssetSelectViewDelegate
- (void)selectView:(MNAssetSelectView *)selectView didSelectItemAtIndex:(NSInteger)index {
    if (index == self.currentDisplayIndex) return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    dispatch_after_main(.1f, ^{
        [self updateCurrentPageIfNeeded];
    });
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view.superview isKindOfClass:UICollectionViewCell.class];
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar {
    UIImageView *shadowView = [UIImageView imageViewWithFrame:navigationBar.bounds image:[MNBundle imageForResource:@"shadow_line_top"]];
    shadowView.userInteractionEnabled = NO;
    shadowView.contentMode = UIViewContentModeScaleToFill;
    [navigationBar insertSubview:shadowView atIndex:0];
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    if (self.allowsSelect) {
        MNAssetBrowseControl *browseControl = [[MNAssetBrowseControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 33.f)];
        [browseControl updateAsset:self.assets.firstObject];
        [browseControl addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.browseControl = browseControl;
        return browseControl;
    }
    UIButton *rightBarButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 30.f) image:nil title:@"确定" titleColor:[UIColor whiteColor] titleFont:[UIFont systemFontOfSize:16.5f]];
    rightBarButton.touchInset = UIEdgeInsetWith(-5.f);
    [rightBarButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarButton;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIControl *)rightItem {
    if (self.allowsSelect) {
        if ([self.delegate respondsToSelector:@selector(didSelectAsset:)]) {
            MNAsset *asset = self.assets[self.currentDisplayIndex];
            [self.delegate didSelectAsset:asset];
            [kTransform(MNAssetBrowseControl *, rightItem) updateAsset:asset];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(previewControllerDoneButtonClicked:)]) {
            [self.delegate previewControllerDoneButtonClicked:self];
        }
    }
}

#pragma mark - Getter
- (MNAssetBrowseCell *)cellForItemAtCurrentDisplayIndex {
    return (MNAssetBrowseCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentDisplayIndex inSection:0]];
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UICollectionViewLayout *)collectionViewLayout {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = kAssetInteritemSpacing;
    layout.minimumInteritemSpacing = 0.f;
    layout.sectionInset = UIEdgeInsetsMake(0.f, kAssetInteritemSpacing/2.f, 0.f, kAssetInteritemSpacing/2.f);
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = self.contentView.size_mn;
    return layout;
}

@end
