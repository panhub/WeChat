//
//  WXAllEmoticonController.m
//  WeChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAllEmoticonController.h"
#import "WXEmoticonPreviewController.h"
#import "WXAllEmoticonCell.h"

@interface WXAllEmoticonController ()<MNSegmentSubpageDataSource>

@end

@implementation WXAllEmoticonController
- (void)createView {
    [super createView];
    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[WXAllEmoticonCell class] forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[MNEmojiManager defaultManager] packets] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXAllEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WXAllEmoticonCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= MNEmojiManager.defaultManager.packets.count) return;
    cell.packet = [[MNEmojiManager defaultManager] packets][indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= MNEmojiManager.defaultManager.packets.count) return;
    MNEmojiPacket *packet = [[MNEmojiManager defaultManager] packets][indexPath.item];
    WXEmoticonPreviewController *vc = [[WXEmoticonPreviewController alloc] initWithPacket:packet];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNSegmentSubpageDataSource
- (UIScrollView *)segmentSubpageScrollView {
    return self.listView;
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (UICollectionViewLayout *)collectionViewLayout {
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.itemSize = CGSizeMake(1.f, 1.f);
    layout.numberOfFormation = 4;
    layout.minimumLineSpacing = 15.f;
    layout.minimumInteritemSpacing = 15.f;
    layout.sectionInset = UIEdgeInsetWith(15.f);
    return layout;
}

@end
