//
//  WXSelectCoverView.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXSelectCoverView.h"
#import "WXSelectCoverCell.h"

@interface WXSelectCoverView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray <UIImage *>*images;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation WXSelectCoverView
- (instancetype)initWithFrame:(CGRect)frame size:(CGSize)coverSize {
    if (self = [super initWithFrame:frame]) {
        
        coverSize = CGSizeMultiplyToHeight(coverSize, self.height_mn);
        coverSize.width = floor(coverSize.width);
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0.f;
        layout.minimumInteritemSpacing = 0.f;
        layout.itemSize = coverSize;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [UICollectionView collectionViewWithFrame:self.bounds layout:layout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.scrollEnabled = NO;
        collectionView.clipsToBounds = NO;
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        [collectionView registerClass:[WXSelectCoverCell class]
           forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.color = [UIColor colorWithHex:@"F7F7F7"];
        indicatorView.hidesWhenStopped = YES;
        indicatorView.center_mn = self.bounds_center;
        indicatorView.userInteractionEnabled = NO;
        [self addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
    return self;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WXSelectCoverCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.images.count <= indexPath.item) return;
    cell.image = self.images[indexPath.item];
}


#pragma mark - Setter
- (void)loadThumbnails {
    NSString *videoPath = self.videoPath;
    if (!videoPath) return;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGSize itemSize = layout.itemSize;
    CGFloat w = self.width_mn*2.5f;
    NSInteger count = (NSInteger)ceil(w/itemSize.width);
    
    
    NSTimeInterval duration = [MNAssetExporter exportDurationWithMediaAtPath:videoPath];
    if (duration <= 0.f) {
        [self fail];
        return;
    }
    @weakify(self);
    [self.indicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray <UIImage *>*images = @[].mutableCopy;
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath]
                                                     options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
        AVAssetImageGenerator *thumbnailGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
        thumbnailGenerator.appliesPreferredTrackTransform = YES;
        thumbnailGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        thumbnailGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        thumbnailGenerator.maximumSize = CGSizeMultiplyByRatio(itemSize, 3.f);
        for (NSInteger i = 0; i < count; i ++) {
            CGFloat progress = i*1.f/count;
            CGImageRef imageRef = [thumbnailGenerator copyCGImageAtTime:CMTimeMultiplyByFloat64(videoAsset.duration, progress) actualTime:NULL error:NULL];
            if (!imageRef) continue;
            UIImage *img = [UIImage imageWithCGImage:imageRef];
            if (!img) continue;
            [images addObject:img];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (images.count) {
                self.images = images.copy;
                [self.collectionView reloadData];
                [self.indicatorView stopAnimating];
                __weak typeof(self) weakself = self;
                [UIView animateWithDuration:.3f animations:^{
                    weakself.collectionView.alpha = 1.f;
                } completion:^(BOOL finished) {
//                    if ([weakself.delegate respondsToSelector:@selector(tailorViewDidLoadThumbnails:)]) {
//                        [weakself.delegate tailorViewDidLoadThumbnails:weakself];
//                    }
                }];
            } else {
                [self fail];
                [self.indicatorView stopAnimating];
                [UIView animateWithDuration:.3f animations:^{
                    self.collectionView.alpha = 1.f;
                } completion:^(BOOL finished) {
//                    if ([weakself.delegate respondsToSelector:@selector(tailorViewDidLoadThumbnails:)]) {
//                        [weakself.delegate tailorViewDidLoadThumbnails:weakself];
//                    }
                }];
            }
        });
        
    });
}

- (void)fail {
    UILabel *thumbnailLabel = [UILabel labelWithFrame:self.collectionView.bounds text:@"无法获取视频截图" alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:16.f]];
    //thumbnailLabel.alpha = 0.f;
    thumbnailLabel.backgroundColor = UIColor.clearColor;
    [self.collectionView addSubview:thumbnailLabel];
}


@end
