//
//  WXMusicViewController.m
//  MNChat
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicViewController.h"
#import "WXMusicPlayController.h"
#import "WXMusicCell.h"
#import "WXSong.h"

@interface WXMusicViewController ()
@property (nonatomic, strong) NSArray <WXSong *>*dataArray;
@end

@implementation WXMusicViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"本地音乐";
        self.dataArray = @[].mutableCopy;
    }
    return self;
}

- (void)createView {
    [super createView];
    // 创建视图
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.navigationBar.shadowColor = UIColor.whiteColor;
    
    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    [self.collectionView registerClass:[WXMusicCell class]
            forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    @weakify(self);
    [self.view showLoadDialog:@"加载中..."];
    [WXSong fetchMusicAtResourceWithCompletionHandler:^(NSArray<WXSong *>*songs) {
        dispatch_async_main(^{
            @strongify(self);
            self.dataArray = songs.copy;
            [self reloadList];
            [self.view closeDialog];
        });
    }];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMusicPlayController *vc = [[WXMusicPlayController alloc] initWithSongs:self.dataArray.copy atIndex:indexPath.item];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull WXMusicCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    cell.song = self.dataArray[indexPath.row];
}

#pragma mark - Overwrite
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (UICollectionViewLayout *)collectionViewLayout {
    CGFloat width = (self.contentView.width_mn - 30.f)/2.f;
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.numberOfFormation = 2;
    layout.minimumLineSpacing = 10.f;
    layout.minimumInteritemSpacing = 10.f;
    layout.itemSize = CGSizeMake(width, width + 55.f);
    layout.sectionInset = UIEdgeInsetsMake(0.f, 10.f, 0.f, 10.f);
    return layout;
}

@end
