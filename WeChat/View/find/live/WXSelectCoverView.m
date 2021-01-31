//
//  WXSelectCoverView.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXSelectCoverView.h"
#import "WXSelectCoverCell.h"
#import "WXDataValueModel.h"

@interface WXSelectCoverView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*images;
@end

@implementation WXSelectCoverView
- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath {
    if (self = [super initWithFrame:frame]) {
        
        CGSize itemSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:videoPath];
        itemSize = CGSizeMultiplyToHeight(itemSize, self.height_mn);
        itemSize.width = floor(itemSize.width);
        
        self.videoPath = videoPath;
        
        self.backgroundColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = itemSize;
        layout.minimumLineSpacing = 0.f;
        layout.minimumInteritemSpacing = 0.f;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [UICollectionView collectionViewWithFrame:self.bounds layout:layout];
        collectionView.alpha = 0.f;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.clipsToBounds = YES;
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
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
    cell.model = self.images[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.images.count <= indexPath.item) return;
    WXDataValueModel *model = self.images[indexPath.item];
    if (model.isSelected) return;
    [self.images setValue:@(NO) forKey:@"selected"];
    model.selected = YES;
    [collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(coverViewDidSelectThumbnail:)]) {
        [self.delegate coverViewDidSelectThumbnail:model];
    }
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
    if (duration <= 0.f || itemSize.width <= 0.f) {
        [self fail];
        [UIView animateWithDuration:.3f animations:^{
            self.collectionView.alpha = 1.f;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(coverViewLoadThumbnailsFailed:)]) {
                [self.delegate coverViewLoadThumbnailsFailed:self];
            }
        }];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(coverViewBeginLoadThumbnails:)]) {
        [self.delegate coverViewBeginLoadThumbnails:self];
    }
    @weakify(self);
    [self.indicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray <WXDataValueModel *>*images = @[].mutableCopy;
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath]
                                                     options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
        AVAssetImageGenerator *thumbnailGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
        thumbnailGenerator.appliesPreferredTrackTransform = YES;
        thumbnailGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        thumbnailGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        thumbnailGenerator.maximumSize = CGSizeMultiplyByRatio(itemSize, 3.f);
        for (NSInteger i = 0; i < count; i ++) {
            CGFloat progress = [[NSString stringWithFormat:@"%.2f", i*1.f/count] floatValue];
            CGImageRef imageRef = [thumbnailGenerator copyCGImageAtTime:CMTimeMultiplyByFloat64(videoAsset.duration, progress) actualTime:NULL error:NULL];
            if (!imageRef) continue;
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if (!image) continue;
            WXDataValueModel *model = WXDataValueModel.new;
            model.image = image;
            model.value = @(progress);
            [images addObject:model];
        }
        images.firstObject.selected = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (images.count) {
                self.images = images.copy;
                [self.collectionView reloadData];
                [self.indicatorView stopAnimating];
                __weak typeof(self) weakself = self;
                [UIView animateWithDuration:.3f animations:^{
                    weakself.collectionView.alpha = 1.f;
                    weakself.backgroundColor = UIColor.clearColor;
                } completion:^(BOOL finished) {
                    if ([weakself.delegate respondsToSelector:@selector(coverViewDidLoadThumbnails:)]) {
                        [weakself.delegate coverViewDidLoadThumbnails:weakself];
                    }
                }];
            } else {
                [self fail];
                [self.indicatorView stopAnimating];
                [UIView animateWithDuration:.3f animations:^{
                    self.collectionView.alpha = 1.f;
                } completion:^(BOOL finished) {
                    if ([weakself.delegate respondsToSelector:@selector(coverViewLoadThumbnailsFailed:)]) {
                        [weakself.delegate coverViewLoadThumbnailsFailed:weakself];
                    }
                }];
            }
        });
    });
}

- (void)fail {
    UILabel *thumbnailLabel = [UILabel labelWithFrame:self.collectionView.bounds text:@"无法获取视频截图" alignment:NSTextAlignmentCenter textColor:[UIColor colorWithHex:@"F7F7F7"] font:[UIFont systemFontOfSize:16.f]];
    thumbnailLabel.backgroundColor = UIColor.clearColor;
    [self.collectionView addSubview:thumbnailLabel];
}

#pragma mark - Getter
- (WXDataValueModel *)coverModel {
    NSArray <WXDataValueModel *>*results = [self.images filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.selected == YES"]];
    return results.count ? results.firstObject : nil;
}

@end
