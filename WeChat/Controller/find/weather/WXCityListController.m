//
//  WXCityListController.m
//  MNChat
//
//  Created by Vincent on 2019/5/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCityListController.h"
#import "WXCityListCell.h"
#import "WXCityModel.h"
#import "WXCityListSectionHeaderView.h"
#import "WXWeatherViewController.h"

@interface WXCityListController () <MNCollectionViewLayoutDataSource, MNLinkSubpageControllerDataSource>

@end

@implementation WXCityListController

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
    
    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.backgroundColor = UIColorWithSingleRGB(51.f);
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerClass:[WXCityListCell class] forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    [self.collectionView registerClass:[WXCityListSectionHeaderView class] forSupplementaryViewOfKind:MNCollectionElementKindSectionHeader withReuseIdentifier:MNCollectionElementSectionHeaderReuseIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    WXCityModel *model = self.dataSource[section];
    return model.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXCityListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
    if (indexPath.section < self.dataSource.count) {
        WXCityModel *model = self.dataSource[indexPath.section];
        if (indexPath.row < model.dataSource.count) {
            WXDistrictModel *district = model.dataSource[indexPath.row];
            cell.titleLabel.text = district.name;
        }
    }
    return cell;
}

- (WXCityListSectionHeaderView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:MNCollectionElementKindSectionHeader]) {
        WXCityListSectionHeaderView *reusableView = (WXCityListSectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MNCollectionElementSectionHeaderReuseIdentifier forIndexPath:indexPath];
        if (indexPath.section < self.dataSource.count) {
            WXCityModel *model = self.dataSource[indexPath.section];
            reusableView.title = model.name;
        }
        return reusableView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataSource.count) return;
    WXCityModel *city = self.dataSource[indexPath.section];
    if (indexPath.item >= city.dataSource.count) return;
    WXDistrictModel *district = city.dataSource[indexPath.item];
    WXWeatherViewController *vc = [[WXWeatherViewController alloc] initWithDistrict:district];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNCollectionViewLayoutDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    if (indexPath.section < self.dataSource.count) {
        WXCityModel *model = self.dataSource[indexPath.section];
        if (indexPath.row < model.dataSource.count) {
            WXDistrictModel *district = model.dataSource[indexPath.row];
            size = [district.name sizeWithFont:[UIFont systemFontOfSize:16.f]];
            size.width += 30.f;
            size.height += 13.f;
        }
    }
    return size;
}

#pragma mark - MNLinkSubpageControllerDataSource
- (UIScrollView *)linkSubpageScrollView {
    return self.listView;
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (__kindof UICollectionViewLayout *)collectionViewLayout {
    MNCollectionTextLayout *layout = [MNCollectionTextLayout layout];
    layout.minimumLineSpacing = 15.f;
    layout.minimumInteritemSpacing = 15.f;
    layout.sectionInset = UIEdgeInsetsMake(15.f, 10.f, 15.f, 10.f);
    layout.headerReferenceSize = CGSizeMake(self.contentView.width_mn, 40.f);
    return layout;
}

- (BOOL)isChildViewController {
    return YES;
}

@end
