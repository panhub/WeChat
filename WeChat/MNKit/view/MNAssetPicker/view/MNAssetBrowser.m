//
//  MNAssetBrowser.m
//  MNKit
//
//  Created by Vincent on 2019/9/7.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetBrowser.h"
#import "MNAssetBrowseCell.h"
#import "MNAsset.h"
#import "MNAssetBrowseControl.h"

const NSInteger MNAssetBrowserTag = 1213151;
const CGFloat MNAssetBrowseCellInteritemSpacing = 15.f;
const CGFloat MNAssetBrowsePresentAnimationDuration = .46f;
const CGFloat MNAssetBrowseDismissAnimationDuration = .46f;

@interface MNAssetBrowser () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, MNAssetBrowseCellDelegate>
/**初始索引*/
@property (nonatomic) NSInteger initialDisplayIndex;
/**当前索引*/
@property (nonatomic) NSInteger currentDisplayIndex;
/**记录状态栏*/
@property (nonatomic) BOOL statusBarOriginalHidden;
/**记录状态栏*/
@property (nonatomic) UIStatusBarStyle statusBarOriginalStyle;
/**记录起始视图*/
@property (nonatomic, weak) UIView *fromView;
/**记录交互数据*/
@property (nonatomic) CGPoint interactiveRatio;
/**记录交互数据*/
@property (nonatomic) CGFloat interactiveDelay;
/**记录交互数据*/
@property (nonatomic) CGRect interactiveFrame;
/**交互消失目标视图*/
@property (nonatomic, weak) UIView *interactiveToView;
/**交互关闭视图*/
@property (nonatomic, strong) UIImageView *interactiveView;
/**背景图*/
@property (nonatomic, strong) UIImageView *backgroundView;
/**记录交互背景图*/
@property (nonatomic, strong) UIImage *originBackgroundImage;
/**背景效果图*/
@property (nonatomic, strong) UIImageView *blurBackgroundView;
/**资源展示*/
@property (nonatomic, strong) UICollectionView *collectionView;
/**资源选择控制*/
@property (nonatomic, strong) MNAssetBrowseControl *browseControl;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation MNAssetBrowser
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithAssets:(NSArray<MNAsset *> *)assets {
    if (self = [self initWithFrame:CGRectZero]) {
        self.assets = assets;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
        
        self.tag = MNAssetBrowserTag;
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
        
        UIImageView *interactiveView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        interactiveView.hidden = YES;
        interactiveView.clipsToBounds = YES;
        interactiveView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:interactiveView];
        self.interactiveView = interactiveView;
        
        MNAssetBrowseControl *browseControl = [[MNAssetBrowseControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 33.f)];
        browseControl.hidden = YES;
        browseControl.right_mn = self.width_mn - 20.f;
        browseControl.top_mn = (MN_NAV_BAR_HEIGHT - browseControl.height_mn)/2.f + MN_STATUS_BAR_HEIGHT;
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
- (void)presentFromIndex:(NSInteger)index {
    [self presentFromIndex:index animated:YES];
}

- (void)presentFromIndex:(NSInteger)index animated:(BOOL)animated {
    [self presentFromIndex:index animated:animated completion:nil];
}

- (void)presentFromIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(void))completion {
    [self presentInView:nil fromIndex:index animated:animated completion:completion];
}

- (void)presentInView:(UIView *)superview fromIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(void))completion {
    
    if (index < 0 || index >= self.assets.count) return;
    
    MNAsset *asset = [self.assets objectAtIndex:index];
    
    if (!asset.containerView) return;
    
    UIImage *animatedImage;
    if (asset.thumbnail && [asset.thumbnail isKindOfClass:UIImage.class]) {
        animatedImage = asset.thumbnail;
    } else if ([asset.containerView isKindOfClass:UIImageView.class]) {
        UIImageView *imv = (UIImageView *)(asset.containerView);
        animatedImage = imv.image.images.count > 1 ? imv.image.images.firstObject : imv.image;
    } else if ([asset.containerView isKindOfClass:UIButton.class]) {
        UIButton *ibu = (UIButton *)(asset.containerView);
        animatedImage = ibu.currentBackgroundImage;
        if (!animatedImage) animatedImage = ibu.currentImage;
    } else if (asset.content && [asset.content isKindOfClass:UIImage.class]) {
        UIImage *content = (UIImage *)(asset.content);
        animatedImage = content.images.count > 1 ? content.images.firstObject : content;
    }
    if (!animatedImage) return;
    
    if (!superview) superview = [[UIApplication sharedApplication] keyWindow];
    BOOL isUserInteractionEnabled = superview.isUserInteractionEnabled;
    superview.userInteractionEnabled = NO;
    self.frame = superview.bounds;
    
    UIColor *backgroundColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
    
    UIView *fromView = asset.containerView;
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
    
    CGSize renderSize = MNImageAssetAspectInSize(animatedImage, self.bounds.size);
    CGRect toFrame = CGRectMake((self.width_mn - renderSize.width)/2.f, (self.height_mn - renderSize.height)/2.f, renderSize.width, renderSize.height);
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:[fromView convertRect:fromView.bounds toView:self] image:animatedImage];
    imageView.clipsToBounds = YES;
    imageView.contentMode = fromView.contentMode;
    imageView.layer.cornerRadius = fromView.layer.cornerRadius;
    [self insertSubview:imageView aboveSubview:self.collectionView];
    
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:(animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone)];
    NSTimeInterval animationDuration = animated ? MNAssetBrowsePresentAnimationDuration : 0.f;
    [UIView animateWithDuration:animationDuration animations:^{
        self.blurBackgroundView.alpha = 1.f;
    }];
    [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView.frame = toFrame;
        [imageView.layer setValue:@(0.f) forKey:@"cornerRadius"];
        [imageView.layer setValue:@(1.01f) forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            [imageView.layer setValue:@(1.f) forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            self.collectionView.hidden = NO;
            [imageView removeFromSuperview];
            [self updateCurrentPageIfNeeded];
            superview.userInteractionEnabled = isUserInteractionEnabled;
            if (completion) completion();
            if ([self.delegate respondsToSelector:@selector(assetBrowserDidPresent:)]) {
                [self.delegate assetBrowserDidPresent:self];
            }
        }];
    }];
}

+ (void)presentContainer:(UIView *)containerView {
    [self presentContainer:containerView usingImage:nil animated:YES completion:nil];
}

+ (void)presentContainer:(UIView *)containerView usingImage:(UIImage *)animatedImage {
    [self presentContainer:containerView usingImage:animatedImage animated:YES completion:nil];
}

+ (void)presentContainer:(UIView *)containerView usingImage:(UIImage *)animatedImage animated:(BOOL)animated completion:(void (^)(void))completionHandler {
    if (!containerView) return;
    if (!animatedImage) {
        if ([containerView isKindOfClass:UIImageView.class]) {
            UIImageView *imv = (UIImageView *)containerView;
            animatedImage = imv.image.images.count > 1 ? imv.image.images.firstObject : imv.image;
        } else if ([containerView isKindOfClass:UIButton.class]) {
            UIButton *ibu = (UIButton *)containerView;
            animatedImage = ibu.currentBackgroundImage;
            if (!animatedImage) animatedImage = ibu.currentImage;
        }
    }
    if (!animatedImage) return;
    MNAsset *asset = [MNAsset assetWithContent:animatedImage];
    asset.containerView = containerView;
    MNAssetBrowser *browser = [[MNAssetBrowser alloc] initWithAssets:@[asset]];
    browser.allowsSelect = NO;
    browser.statusBarHidden = YES;
    browser.backgroundColor = UIColor.blackColor;
    [browser presentFromIndex:0 animated:animated completion:completionHandler];
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    
    UIView *superview = self.superview;
    BOOL isUserInteractionEnabled = superview.isUserInteractionEnabled;
    superview.userInteractionEnabled = NO;
    
    MNAsset *asset = self.assets[self.currentDisplayIndex];
    UIView *toView = self.currentDisplayIndex == self.initialDisplayIndex ? self.fromView : asset.containerView;
    if (toView && toView != self.fromView) {
        CGRect rect = [toView.superview convertRect:toView.frame toView:self];
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
    
    UIImage *animatedImage;
    if (toView == self.fromView) {
        if ([self.fromView isKindOfClass:UIImageView.class]) {
            UIImageView *imv = (UIImageView *)(self.fromView);
            animatedImage = imv.image.images.count > 1 ? imv.image.images.firstObject : imv.image;
        } else if ([self.fromView isKindOfClass:UIButton.class]) {
            UIButton *ibu = (UIButton *)(self.fromView);
            animatedImage = ibu.currentBackgroundImage;
            if (!animatedImage) animatedImage = ibu.currentImage;
        }
    }
    UIImageView *imageView = cell.currentImageView;
    if (animatedImage) imageView.image = animatedImage;
    imageView.clipsToBounds = YES;
    imageView.contentMode = toView.contentMode;
    imageView.frame = [cell.scrollView.contentView.superview convertRect:cell.scrollView.contentView.frame toView:self];
    [self addSubview:imageView];
    
    [cell didEndDisplaying];
    self.collectionView.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(assetBrowserWillDismiss:)]) {
        [self.delegate assetBrowserWillDismiss:self];
    }
    
    [UIView setAnimationsEnabled:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarOriginalStyle animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarOriginalHidden withAnimation:(animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone)];
    NSTimeInterval animationDuration = animated ? MNAssetBrowseDismissAnimationDuration : 0.f;
    [UIView animateWithDuration:animationDuration animations:^{
        self.blurBackgroundView.alpha = 0.f;
    }];
    [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView.frame = toFrame;
        [imageView.layer setValue:@(.99f) forKeyPath:@"transform.scale"];
        [imageView.layer setValue:@(toView.layer.cornerRadius) forKey:@"cornerRadius"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            [imageView.layer setValue:@(1.f) forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:(animated ? .2f : 0.f) animations:^{
                self.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                superview.userInteractionEnabled = isUserInteractionEnabled;
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

#pragma mark - MNAlertProtocol
- (void)show {}
- (void)showInView:(UIView *)superview {}
- (void)dismiss {
    [self dismissWithAnimated:YES completion:nil];
}

+ (void)close {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    MNAssetBrowser *browser = [keyWindow viewWithTag:MNAssetBrowserTag];
    if (!browser) return;
    [browser removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:browser.statusBarOriginalHidden animated:YES];
}

+ (BOOL)isPresenting {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    return [keyWindow viewWithTag:MNAssetBrowserTag] != nil;
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
            
            MNAsset *asset = self.assets[self.currentDisplayIndex];
            UIView *interactiveToView = self.currentDisplayIndex == self.initialDisplayIndex ? self.fromView : asset.containerView;
            if (interactiveToView && interactiveToView != self.fromView) {
                CGRect rect = [interactiveToView.superview convertRect:interactiveToView.frame toView:self];
                if (!CGRectIntersectsRect(self.bounds, rect)) interactiveToView = self.fromView;
            }
            if (!interactiveToView) interactiveToView = self.fromView;
            if (interactiveToView != self.fromView) {
                self.hidden = interactiveToView.hidden = YES;
                self.originBackgroundImage = self.backgroundView.image;
                self.backgroundView.image = [self.superview snapshotImage];
                self.hidden = interactiveToView.hidden = NO;
            }
            self.interactiveToView = interactiveToView;
            
            [cell endDisplaying];
            
            self.interactiveView.image = cell.currentImage;
            self.interactiveView.frame = [cell.scrollView.contentView.superview convertRect:cell.scrollView.contentView.frame toView:self];
            self.interactiveFrame = self.interactiveView.frame;
            
            self.interactiveView.hidden = NO;
            self.collectionView.hidden = YES;
            
            CGRect fromRect = self.fromView.frame;
            self.interactiveDelay = (self.height_mn - fromRect.size.height)/2.f;
            self.interactiveRatio = CGPointMake(fromRect.size.width/self.interactiveView.width_mn, fromRect.size.height/self.interactiveView.height_mn);
            
            if (self.browseControl) {
                [UIView animateWithDuration:.3f animations:^{
                    self.browseControl.alpha = 0.f;
                }];
            }

        } break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.interactiveView.isHidden) return;
            
            CGPoint point = [recognizer translationInView:self];
            [recognizer setTranslation:CGPointZero inView:self];
            
            CGPoint center = self.interactiveView.center_mn;
            center.x += point.x;
            center.y += point.y;
    
            CGFloat interactiveRatio = fabs(self.height_mn/2.f - self.interactiveView.centerY_mn)/self.interactiveDelay;
            
            CGRect frame = self.interactiveFrame;
            frame.size.width = (1.f - (1.f - self.interactiveRatio.x)*interactiveRatio)*frame.size.width;
            frame.size.height = (1.f - (1.f - self.interactiveRatio.y)*interactiveRatio)*frame.size.height;
            frame.origin.x = center.x - frame.size.width/2.f;
            frame.origin.y = center.y - frame.size.height/2.f;
            frame.origin.x = MIN(MAX(0.f, frame.origin.x), self.width_mn - frame.size.width);
            frame.origin.y = MIN(MAX(0.f, frame.origin.y), self.height_mn - frame.size.height);
            self.interactiveView.frame = frame;
            
            self.blurBackgroundView.alpha = 1.f - interactiveRatio*.8f;
            
        } break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.interactiveView.isHidden) return;
            if (self.interactiveView.centerY_mn >= self.height_mn/4.f*2.7f) {
                [self dismissFromCurrentState];
            } else {
                [self endPanFromCurrentState];
            }
        } break;
        case UIGestureRecognizerStateCancelled:
        {
            if (self.interactiveView.isHidden) return;
            [self endPanFromCurrentState];
        } break;
        default:
            break;
    }
}

- (void)endPanFromCurrentState {
    [UIView animateWithDuration:MNAssetBrowsePresentAnimationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.blurBackgroundView.alpha = 1.f;
        self.interactiveView.frame = self.interactiveFrame;
        if (self.browseControl) self.browseControl.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.interactiveView.hidden = YES;
        self.collectionView.hidden = NO;
        if (self.originBackgroundImage) self.backgroundView.image = self.originBackgroundImage;
        self.interactiveToView = nil;
        self.originBackgroundImage = nil;
    }];
}

- (void)dismissFromCurrentState {
    
    UIView *superview = self.superview;
    BOOL isUserInteractionEnabled = superview.isUserInteractionEnabled;
    superview.userInteractionEnabled = NO;
    
    CGRect toFrame = self.interactiveView.frame;
    CGFloat cornerRadius = self.interactiveView.layer.cornerRadius;
    if (self.interactiveToView) {
        cornerRadius = self.interactiveToView.layer.cornerRadius;
        toFrame = [self.interactiveToView.superview convertRect:self.interactiveToView.frame toView:self];
    } else {
        toFrame.origin.y = self.interactiveView.centerY_mn <= self.height_mn/2.f ? -toFrame.size.height : self.height_mn;
    }
    
    if ([self.delegate respondsToSelector:@selector(assetBrowserWillDismiss:)]) {
        [self.delegate assetBrowserWillDismiss:self];
    }
    self.interactiveView.contentMode = self.fromView.contentMode;
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarOriginalStyle animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarOriginalHidden withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:MNAssetBrowseDismissAnimationDuration/2.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        self.blurBackgroundView.alpha = 0.f;
        self.interactiveView.frame = toFrame;
        [self.interactiveView.layer setValue:@(cornerRadius) forKey:@"cornerRadius"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2f animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.interactiveView removeFromSuperview];
            [self removeFromSuperview];
            superview.userInteractionEnabled = isUserInteractionEnabled;
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
    MNAssetBrowseCell *cell = (MNAssetBrowseCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
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
    return self.isAllowsAutoPlaying;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view != self.browseControl;
}

#pragma mark - Getter
- (MNAssetBrowseCell *)cellForItemAtCurrentDisplayIndex {
    return (MNAssetBrowseCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentDisplayIndex inSection:0]];
}

#pragma mark - dealloc
- (void)dealloc {
    if (self.isCleanAssetWhenDealloc) {
        [self.assets setValue:nil forKey:@"content"];
        [self.assets makeObjectsPerformSelector:@selector(cancelRequest)];
    }
}

@end
#pragma clang diagnostic pop
