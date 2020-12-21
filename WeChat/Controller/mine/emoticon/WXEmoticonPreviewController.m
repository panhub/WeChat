//
//  WXEmoticonPreviewController.m
//  MNChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXEmoticonPreviewController.h"
#import "WXEmoticonHeaderView.h"

@interface WXEmoticonPreviewController ()
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) MNEmojiPacket *packet;
@property (nonatomic, strong) WXEmoticonHeaderView *headerView;
@end

@implementation WXEmoticonPreviewController
- (instancetype)initWithPacket:(MNEmojiPacket *)packet {
    if (self = [super init]) {
        self.title = packet.name;
        self.packet = packet;
    }
    return self;
}

- (void)createView {
    [super createView];

    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[MNCollectionViewCell class] forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    [self.collectionView addSubview:self.headerView];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.packet.emojis.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MNCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
    cell.imageView.frame = cell.bounds;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MNCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    MNEmoji *emoji = self.packet.emojis[indexPath.item];
    cell.imageView.image = emoji.image;
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (UICollectionViewLayout *)collectionViewLayout {
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.itemSize = CGSizeMake(1.f, 1.f);
    if (self.packet.type == MNEmojiTypeText) {
        layout.numberOfFormation = MN_SCREEN_WIDTH >= 414.f ? 9 : 8;
    } else {
        layout.numberOfFormation = 5;
    }
    layout.minimumLineSpacing = 15.f;
    layout.minimumInteritemSpacing = 15.f;
    layout.sectionInset = UIEdgeInsetsMake(self.headerView.height_mn, 15.f, 15.f, 15.f);
    return layout;
}

#pragma mark - Getter
- (WXEmoticonHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[WXEmoticonHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
        _headerView.packet = _packet;
    }
    return _headerView;
}

@end
