//
//  WXCookListController.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookListController.h"
#import "WXCookSort.h"
#import "WXCookRecipeController.h"
#import "WXCookRequest.h"
#import "WXCookListCell.h"

@interface WXCookListController ()<MNSegmentSubpageDataSource>

@end

@implementation WXCookListController
- (instancetype)initWithFrame:(CGRect)frame menu:(WXCookMenu *)menu {
    if (self = [super initWithFrame:frame]) {
        self.loadMoreEnabled = YES;
        self.pullRefreshEnabled = YES;
        self.httpRequest = [[WXCookRequest alloc] initWithMenu:menu];
    }
    return self;
}

- (void)createView {
    [super createView];

    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.collectionView registerClass:[WXCookListCell class] forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.httpRequest.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WXCookListCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.httpRequest.dataArray.count) return;
    cell.model = self.httpRequest.dataArray[indexPath.item];
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.item >= self.httpRequest.dataArray.count) return;
//    WXCook *cook = self.httpRequest.dataArray[indexPath.row];
//    WXCookRecipeController *vc = [[WXCookRecipeController alloc] initWithRecipeModel:cook.recipe];
//    [self.navigationController pushViewController:vc animated:YES];
//}

#pragma mark - MNSegmentSubpageDataSource
- (UIScrollView *)segmentSubpageScrollView {
    return self.listView;
}

#pragma mark - Super
- (BOOL)isChildViewController {
    return YES;
}

- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (UICollectionViewLayout *)collectionViewLayout {
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.minimumLineSpacing = 8.f;
    layout.minimumInteritemSpacing = 8.f;
    layout.numberOfFormation = 2;
    layout.sectionInset = UIEdgeInsetsMake(8.f, 8.f, MN_TAB_SAFE_HEIGHT, 8.f);
    layout.itemSize = CGSizeMake(1.f, 1.f);
    return layout;
}

- (void)showEmptyViewNeed:(BOOL)isNeed image:(UIImage *)image message:(NSString *)message title:(NSString *)title type:(MNEmptyEventType)type {
    [super showEmptyViewNeed:isNeed image:[MNBundle imageForResource:@"empty_data_jd"] message:@"获取数据失败" title:@"点击重试" type:MNEmptyEventTypeReload];
}

@end
