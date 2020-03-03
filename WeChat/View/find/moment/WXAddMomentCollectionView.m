//
//  WXAddMomentCollectionView.m
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentCollectionView.h"
#import "WXAddMomentCollectionModel.h"
#import "WXAddMomentCollectionViewCell.h"

@interface WXAddMomentCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, WXAddMomentCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <WXAddMomentCollectionModel *>*dataSource;
@end

@implementation WXAddMomentCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        
        CGFloat interval = 8.f;
        CGFloat WH = (self.width_mn - interval*2.f)/3.f;
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = interval;
        layout.minimumInteritemSpacing = interval;
        layout.itemSize = CGSizeMake(WH, WH);
        
        UICollectionView *collectionView = [UICollectionView collectionViewWithFrame:self.bounds layout:layout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.scrollEnabled = NO;
        collectionView.clipsToBounds = NO;
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        [collectionView registerClass:[WXAddMomentCollectionViewCell class]
           forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        self.height_mn = WH;
        
        self.dataSource = [NSMutableArray array];
        [self.dataSource addObject:[WXAddMomentCollectionModel lastModel]];
        
        [self handNotification:UIKeyboardWillShowNotification eventHandler:^(id sender) {
            @PostNotify(WXMomentCollectionCellCancelShakeNotificationName, nil);
        }];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WXAddMomentCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count <= indexPath.item) return;
    cell.model = self.dataSource[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    WXAddMomentCollectionModel *obj = self.dataSource[sourceIndexPath.item];
    [self.dataSource removeObjectAtIndex:sourceIndexPath.item];
    [self.dataSource insertObject:obj atIndex:destinationIndexPath.item];
    [collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.dataSource.count) return;
    [UIWindow endEditing:YES];
    @PostNotify(WXMomentCollectionCellCancelShakeNotificationName, nil);
    /// 添加图片
    WXAddMomentCollectionModel *model = self.dataSource[indexPath.item];
    if (model.isLast) {
        /// 添加图片
        MNAssetPicker *picker = [MNAssetPicker picker];
        picker.configuration.allowsPickingGif = NO;
        picker.configuration.allowsPickingVideo = NO;
        picker.configuration.allowsPickingLivePhoto = NO;
        picker.configuration.allowsEditing = NO;
        picker.configuration.exportPixel = 800.f;
        picker.configuration.maxPickingCount = 9 - self.dataSource.count + 1;
        [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
            if (assets.count <= 0) {
                [self.viewController.view showInfoDialog:@"获取图片出错"];
                return;
            }
            NSMutableArray *models = [NSMutableArray arrayWithCapacity:assets.count];
            [assets enumerateObjectsUsingBlock:^(MNAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [models addObject:[[WXAddMomentCollectionModel alloc] initWithImage:obj.content]];
            }];
            WXAddMomentCollectionModel *m = self.dataSource.lastObject;
            [self.dataSource removeLastObject];
            [self.dataSource addObjectsFromArray:models];
            if (self.dataSource.count < 9) [self.dataSource addObject:m];
            [self.collectionView reloadData];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } cancelHandler:nil];
    } else {
        /// 浏览图片
        __block MNAsset *asset;
        NSMutableArray *assets = @[].mutableCopy;
        [self.dataSource enumerateObjectsUsingBlock:^(WXAddMomentCollectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isLast) return;
            MNAsset *assetModel = [MNAsset assetWithContent:obj.image];
            assetModel.containerView = obj.containerView;
            if (obj == model) asset = assetModel;
            [assets addObject:assetModel];
        }];
        MNAssetBrowser *browser = [MNAssetBrowser new];
        browser.assets = assets;
        browser.allowsSelect = NO;
        browser.backgroundColor = [UIColor blackColor];
        [browser presentInView:self.viewController.view fromAsset:asset animated:YES completion:nil];
    }
}

#pragma mark - WXAddMomentCellDelegate
- (void)collectionViewCellDeleteButtonDidClick:(WXAddMomentCollectionViewCell *)cell {
    if (![self.dataSource containsObject:cell.model]) return;
    NSInteger index = [self.dataSource indexOfObject:cell.model];
    [self.dataSource removeObjectAtIndex:index];
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    if (!self.dataSource.lastObject.isLast) {
        [self.dataSource addObject:[WXAddMomentCollectionModel lastModel]];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0]]];
    }
}

#pragma mark - 修改高度
- (void)layoutSubviews {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (!layout || self.dataSource.count <= 0) return;
    NSUInteger rows = self.rows;
    CGFloat height = layout.itemSize.height*rows + layout.minimumInteritemSpacing*(rows - 1);
    if (self.height_mn != height) {
        self.height_mn = height;
        if ([_delegate respondsToSelector:@selector(collectionViewDidChangeHeight:)]) {
            [_delegate collectionViewDidChangeHeight:self];
        }
    }
}

#pragma mark - 获取图片
- (NSArray <UIImage *>*)images {
    NSMutableArray <UIImage *>*array = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    [self.dataSource enumerateObjectsUsingBlock:^(WXAddMomentCollectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.isLast && obj.image) {
            [array addObject:obj.image];
        }
    }];
    return array.copy;
}

#pragma mark - 行数
- (NSUInteger)rows {
    NSUInteger rows = self.dataSource.count/3;
    NSUInteger remainder = self.dataSource.count%3;
    if (remainder > 0) rows++;
    return rows;
}

@end
