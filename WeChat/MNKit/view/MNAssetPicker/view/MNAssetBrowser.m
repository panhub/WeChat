//
//  MNAssetBrowser.m
//  MNFoundation
//
//  Created by Vincent on 2019/9/7.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetBrowser.h"
#import "MNAssetBrowseCell.h"
#import "MNAsset.h"
#import "MNAssetBrowseControl.h"

const CGFloat MNAssetBrowseCellInteritemSpacing = 15.f;
const CGFloat MNAssetBrowsePresentAnimationDuration = .23f;
const CGFloat MNAssetBrowseDismissAnimationDuration = .23f;

@interface MNAssetBrowser () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, MNAssetBrowseCellDelegate>
@property (nonatomic) NSInteger initialDisplayIndex;
@property (nonatomic) NSInteger currentDisplayIndex;
@property (nonatomic) BOOL statusBarOriginalHidden;
@property (nonatomic) UIStatusBarStyle statusBarOriginalStyle;
@property (nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) CGPoint panGestureBeginPoint;
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *coverView;
@property (nonatomic) CGPoint ratio;
@property (nonatomic) CGFloat delay;
@property (nonatomic) CGRect originFrame;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *blurBackgroundView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MNAssetBrowseControl *browseControl;
@end

@implementation MNAssetBrowser
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithAssets:(NSArray<MNAsset *> *)assets {
    if (self = [super init]) {
        self.assets = assets;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
    
        self.allowsSelect = NO;
        self.statusBarHidden = YES;
        self.allowsAutoPlaying = NO;
        self.currentDisplayIndex = -1;
        self.statusBarOriginalStyle = [[UIApplication sharedApplication] statusBarStyle];
        self.statusBarOriginalHidden = [[UIApplication sharedApplication] isStatusBarHidden];
        self.statusBarStyle = self.statusBarOriginalStyle;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        
        UIImageView *blurBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        blurBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:blurBackgroundView];
        self.blurBackgroundView = blurBackgroundView;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = MNAssetBrowseCellInteritemSpacing;
        layout.minimumInteritemSpacing = 0.f;
        layout.sectionInset = UIEdgeInsetsMake(0.f, MNAssetBrowseCellInteritemSpacing/2.f, 0.f, MNAssetBrowseCellInteritemSpacing/2.f);
        layout.headerReferenceSize = CGSizeZero;
        layout.footerReferenceSize = CGSizeZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = self.size_mn;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-MNAssetBrowseCellInteritemSpacing/2.f, 0.f, self.width_mn + MNAssetBrowseCellInteritemSpacing, self.height_mn) collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.pagingEnabled = YES;
        collectionView.delaysContentTouches = NO;
        collectionView.canCancelContentTouches = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView adjustContentInset];
        [collectionView registerClass:[MNAssetBrowseCell class]
           forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        MNAssetBrowseControl *browseControl = [[MNAssetBrowseControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 33.f)];
        browseControl.hidden = YES;
        browseControl.right_mn = self.width_mn - 20.f;
        browseControl.top_mn = (UINavBarHeight() - browseControl.height_mn)/2.f + UIStatusBarHeight();
        browseControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [browseControl addTarget:self action:@selector(browseControlClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:browseControl];
        self.browseControl = browseControl;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.delegate = self;
        singleTap.numberOfTapsRequired = 1;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:singleTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - Private Method
- (void)presentFromAsset:(MNAsset *)asset {
    [self presentFromAsset:asset animated:YES];
}

- (void)presentFromAsset:(MNAsset *)asset animated:(BOOL)animated {
    [self presentFromAsset:asset animated:animated completion:nil];
}

- (void)presentFromAsset:(MNAsset *)asset animated:(BOOL)animated completion:(void (^)(void))completion {
    [self presentInView:nil fromAsset:asset animated:animated completion:completion];
}

- (void)presentInView:(UIView *)superview fromAsset:(MNAsset *)asset animated:(BOOL)animated completion:(void (^)(void))completion {
    
    if (self.assets.count <= 0 || !asset.containerView || ![self.assets containsObject:asset]) return;
    
    if (!superview) superview = [[UIApplication sharedApplication] keyWindow];
    superview.userInteractionEnabled = NO;
    self.frame = superview.bounds;
    
    UIColor *backgroundColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    
    self.animating = YES;
    UIImageView *fromView = asset.containerView;
    self.fromView = fromView;
    self.initialDisplayIndex = [self.assets indexOfObject:asset];
    
    self.collectionView.hidden = YES;
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.initialDisplayIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    
    fromView.hidden = YES;
    self.backgroundView.image = [superview snapshotImage];
    fromView.hidden = NO;
    
    self.blurBackgroundView.alpha = 0.f;
    if (backgroundColor) {
        self.blurBackgroundView.image = [UIImage imageWithColor:backgroundColor size:self.size_mn];
    } else {
        self.blurBackgroundView.image = [[superview snapshotImage] darkEffect];
    }
    
    [superview addSubview:self];
    
    if ([self.delegate respondsToSelector:@selector(assetBrowserWillPresent:)]) {
        [self.delegate assetBrowserWillPresent:self];
    }
    
    CGSize renderSize = [MNAssetBrowseCell displaySizeWithImage:fromView.image inView:self];
    CGRect toFrame = CGRectMake((self.width_mn - renderSize.width)/2.f, (self.height_mn - renderSize.height)/2.f, renderSize.width, renderSize.height);
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:[fromView convertRect:fromView.bounds toView:self] image:fromView.image];
    imageView.clipsToBounds = YES;
    imageView.contentMode = fromView.contentMode;
    [self insertSubview:imageView aboveSubview:self.collectionView];
    
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:(animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone)];
    NSTimeInterval animationDuration = animated ? MNAssetBrowsePresentAnimationDuration*2.f : 0.f;
    [UIView animateWithDuration:animationDuration animations:^{
        self.blurBackgroundView.alpha = 1.f;
    }];
    [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView.frame = toFrame;
        [imageView.layer setValue:@(1.01f) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            [imageView.layer setValue:@(1.f) forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            self.collectionView.hidden = NO;
            [imageView removeFromSuperview];
            [self updateCurrentPageIfNeeded];
            self.animating = NO;
            superview.userInteractionEnabled = YES;
            if (completion) completion();
            if ([self.delegate respondsToSelector:@selector(assetBrowserDidPresent:)]) {
                [self.delegate assetBrowserDidPresent:self];
            }
        }];
    }];
}

+ (void)presentContainer:(UIImageView *)containerView {
    [self presentContainer:containerView animated:YES completion:nil];
}

+ (void)presentContainer:(UIImageView *)containerView animated:(BOOL)animated completion:(void (^)(void))completionHandler {
    if (!containerView) return;
    UIImage *image = containerView.image;
    MNAsset *asset = [MNAsset assetWithContent:image];
    asset.containerView = containerView;
    asset.type = MNAssetTypePhoto;
    MNAssetBrowser *browser = [MNAssetBrowser new];
    browser.allowsSelect = NO;
    browser.assets = @[asset];
    browser.backgroundColor = UIColor.blackColor;
    [browser presentFromAsset:asset animated:animated completion:completionHandler];
}

- (void)dismiss {
    [self dismissWithAnimated:YES completion:nil];
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.isAnimating) return;
    self.animating = YES;
    MNAsset *asset = self.assets[self.currentDisplayIndex];
    UIView *toView = self.currentDisplayIndex == self.initialDisplayIndex ? self.fromView : asset.containerView;
    if (toView && toView != self.fromView) {
        CGRect rect = [toView convertRect:toView.bounds toView:self];
        if (!CGRectIntersectsRect(self.bounds, rect)) toView = self.fromView;
    }
    if (!toView) toView = self.fromView;
    if (toView != self.fromView) {
        self.hidden = toView.hidden = YES;
        self.backgroundView.image = [self.superview snapshotImage];
        self.hidden = toView.hidden = NO;
    }
    
    MNAssetBrowseCell *cell = [self cellForItemAtCurrentDisplayIndex];
    
    CGRect toFrame = [toView convertRect:toView.bounds toView:self];
    
    UIImageView *imageView = cell.foregroundImageView;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.frame = [cell.scrollView.contentView convertRect:cell.scrollView.contentView.bounds toView:self];
    [self addSubview:imageView];
    
    self.collectionView.hidden = YES;
    [cell didEndDisplaying];
    
    if ([self.delegate respondsToSelector:@selector(assetBrowserWillDismiss:)]) {
        [self.delegate assetBrowserWillDismiss:self];
    }
    
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarOriginalStyle animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarOriginalHidden withAnimation:(animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone)];
    NSTimeInterval animationDuration = animated ? MNAssetBrowseDismissAnimationDuration*2.f : 0.f;
    [UIView animateWithDuration:animationDuration animations:^{
        self.blurBackgroundView.alpha = 0.f;
    }];
    [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView.frame = toFrame;
        [imageView.layer setValue:@(.99f) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            [imageView.layer setValue:@(1.f) forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:(animated ? .2f : 0.f) animations:^{
                self.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (completion) completion();
                if ([self.delegate respondsToSelector:@selector(assetBrowserDidDismiss:)]) {
                    [self.delegate assetBrowserDidDismiss:self];
                }
            }];
        }];
    }];
}

- (void)updateCurrentPageIfNeeded {
    NSInteger currentPageIndex = self.collectionView.contentOffset.x/self.collectionView.width_mn;
    if (currentPageIndex == self.currentDisplayIndex) return;
    self.currentDisplayIndex = currentPageIndex;
    [[self cellForItemAtCurrentDisplayIndex] didBeginDisplaying];
    if (self.allowsSelect) [self.browseControl updateAsset:self.assets[currentPageIndex]];
    if ([self.delegate respondsToSelector:@selector(assetBrowser:didScrollToIndex:)]) {
        [self.delegate assetBrowser:self didScrollToIndex:currentPageIndex];
    }
}

#pragma mark - Event
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    MNAssetBrowseCell *cell = [self cellForItemAtCurrentDisplayIndex];
    if (cell.scrollView.zoomScale > 1.f) return;
    [self dismiss];
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

- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            MNAssetBrowseCell *cell = [self cellForItemAtCurrentDisplayIndex];
            if (cell.scrollView.zoomScale > 1.f) return;
        
            CGPoint point = [recognizer locationInView:cell.scrollView.contentView];
            if (!CGRectContainsPoint(cell.scrollView.contentView.bounds, point)) return;
            
            [cell endDisplaying];
            UIImageView *coverView = cell.foregroundImageView;
            coverView.frame = [cell.scrollView.contentView convertRect:cell.scrollView.contentView.bounds toView:self];
            coverView.clipsToBounds = YES;
            coverView.contentMode = UIViewContentModeScaleAspectFill;
            [self insertSubview:coverView aboveSubview:self.collectionView];
            
            self.coverView = coverView;
            self.collectionView.hidden = YES;
            self.originFrame = coverView.frame;
            
            CGRect fromRect = self.fromView.frame;
            self.delay = (self.height_mn - fromRect.size.height)/2.f;
            self.ratio = CGPointMake(fromRect.size.width/coverView.width_mn, fromRect.size.height/coverView.height_mn);
            
            [UIView animateWithDuration:.3f animations:^{
                if (self.allowsSelect) self.browseControl.alpha = 0.f;
            }];
        } break;
        case UIGestureRecognizerStateChanged:
        {
            if (!self.coverView) return;
            
            CGPoint point = [recognizer translationInView:self];
            [recognizer setTranslation:CGPointZero inView:self];
            self.coverView.top_mn += point.y;
            self.coverView.left_mn += point.x;
            CGFloat ratio = fabs(self.height_mn/2.f - self.coverView.centerY_mn)/self.delay;
            self.coverView.transform = CGAffineTransformMakeScale(1.f - (1.f - self.ratio.x)*ratio, 1.f - (1.f - self.ratio.y)*ratio);
            if (self.coverView.centerY_mn <= self.fromView.height_mn/2.f) {
                self.coverView.centerY_mn = self.fromView.height_mn/2.f;
            } else if (self.coverView.centerY_mn >= self.height_mn - self.fromView.height_mn/2.f) {
                self.coverView.centerY_mn = self.height_mn - self.fromView.height_mn/2.f;
            }
            if (self.coverView.left_mn <= 0.f) {
                self.coverView.left_mn = 0.f;
            } else if (self.coverView.right_mn >= self.width_mn) {
                self.coverView.right_mn = self.width_mn;
            }
            
            self.blurBackgroundView.alpha = 1.f - ratio*.8f;
            
        } break;
        case UIGestureRecognizerStateEnded:
        {
            if (!self.coverView) return;
            if (self.coverView.top_mn <= 30.f || self.height_mn - self.coverView.bottom_mn <= 30.f) {
                [self dismissFromCurrentState];
            } else {
                [self endPanFromCurrentState];
            }
        } break;
        case UIGestureRecognizerStateCancelled:
        {
            if (!self.coverView) return;
            [self endPanFromCurrentState];
        } break;
        default:
            break;
    }
}

- (void)endPanFromCurrentState {
    [UIView animateWithDuration:MNAssetBrowsePresentAnimationDuration delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.browseControl.alpha = 1.f;
        self.blurBackgroundView.alpha = 1.f;
        self.coverView.transform = CGAffineTransformIdentity;
        self.coverView.center_mn = CGPointMake(CGRectGetMidX(self.originFrame), CGRectGetMidY(self.originFrame));
    } completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        [self.coverView removeFromSuperview];
        self.coverView = nil;
    }];
}

- (void)dismissFromCurrentState {
    if ([self.delegate respondsToSelector:@selector(assetBrowserWillDismiss:)]) {
        [self.delegate assetBrowserWillDismiss:self];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarOriginalStyle animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarOriginalHidden withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:MNAssetBrowseDismissAnimationDuration delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.blurBackgroundView.alpha = 0.f;
        if (self.currentDisplayIndex == self.initialDisplayIndex) {
            self.coverView.frame = [self.fromView convertRect:self.fromView.bounds toView:self];
        } else {
            self.coverView.bottom_mn = self.coverView.centerY_mn <= self.height_mn/2.f ? 0.f : self.height_mn + self.coverView.height_mn;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2f animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.coverView removeFromSuperview];
            self.coverView = nil;
            [self removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(assetBrowserDidDismiss:)]) {
                [self.delegate assetBrowserDidDismiss:self];
            }
        }];
    }];
}

- (void)browseControlClicked:(MNAssetBrowseControl *)control {
    if (self.collectionView.isDragging || self.collectionView.isDecelerating) return;
    MNAsset *model = self.assets[self.currentDisplayIndex];
    if ([self.delegate respondsToSelector:@selector(assetBrowser:didSelectAsset:)]) {
        [self.delegate assetBrowser:self didSelectAsset:model];
    }
    [self.browseControl updateAsset:model];
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

#pragma mark - MNAssetBrowseCellDelegate
- (BOOL)assetBrowseCellShouldAutoPlaying:(MNAssetBrowseCell *)cell {
    return self.allowsAutoPlaying;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view != self.browseControl;
}

#pragma mark - Getter
- (MNAssetBrowseCell *)cellForItemAtCurrentDisplayIndex {
    return (MNAssetBrowseCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentDisplayIndex inSection:0]];
}

@end
