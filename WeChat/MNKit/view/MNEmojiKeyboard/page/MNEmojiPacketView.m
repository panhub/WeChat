//
//  MNEmojiPacketView.m
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiPacketView.h"
#import "MNEmojiManager.h"
#import "MNEmojiPacketCell.h"
#import "MNEmojiButton.h"
#import "MNEmojiKeyboardConfiguration.h"

#define MNEmojiPacketViewCellIdentifier   @"com.mn.emoji.packet.view.cell.identifier"

@interface MNEmojiPacketView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) MNEmojiButton *returnButton;
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <UIImage *>*dataArray;
@property (nonatomic, strong) MNEmojiKeyboardConfiguration *configuration;
@end

@implementation MNEmojiPacketView
- (instancetype)initWithConfiguration:(MNEmojiKeyboardConfiguration *)configuration {
    CGRect frame = CGRectZero;
    frame.size.width = UIScreen.mainScreen.bounds.size.width;
    frame.size.height = configuration.style == MNEmojiKeyboardStyleLight ? 50.f : UITabSafeHeight() + 40.f;
    if (self = [super initWithFrame:frame]) {
        
        self.configuration = configuration;
        self.selectedIndex = NSIntegerMax;
        self.backgroundColor = configuration.tintColor;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, .4f)];
        if (configuration.style == MNEmojiKeyboardStyleLight) separator.bottom_mn = self.height_mn;
        separator.backgroundColor = configuration.separatorColor;
        [self addSubview:separator];
        
        MNEmojiButton *returnButton = MNEmojiButton.new;
        if (configuration.style == MNEmojiKeyboardStyleLight) {
            returnButton.size_mn = CGSizeMake(0.f, self.height_mn);
        } else {
            returnButton.top_mn = separator.bottom_mn;
            returnButton.size_mn = CGSizeMake(55.f, self.height_mn - UITabSafeHeight() - separator.bottom_mn);
        }
        returnButton.right_mn = self.width_mn;
        returnButton.titleColor = configuration.returnKeyTitleColor;
        returnButton.titleFont = configuration.returnKeyTitleFont;
        returnButton.title = self.returnButtonTitle;
        returnButton.backgroundColor = configuration.returnKeyColor;
        if (configuration.style == MNEmojiKeyboardStyleRegular) returnButton.titleInset = UIEdgeInsetsMake(7.f, 7.f, 7.f, 7.f);
        [returnButton addTarget:self action:@selector(returnButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:returnButton];
        self.returnButton = returnButton;
        
        CGFloat inset = 6.f;
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.headerReferenceSize = CGSizeZero;
        layout.footerReferenceSize = CGSizeZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (configuration.style == MNEmojiKeyboardStyleLight) {
            layout.minimumLineSpacing = 5.f;
            layout.minimumInteritemSpacing = 5.f;
            layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
            layout.itemSize = CGSizeMake(returnButton.height_mn - inset*2.f, returnButton.height_mn - inset*2.f);
        } else {
            layout.minimumLineSpacing = 0.f;
            layout.minimumInteritemSpacing = 0.f;
            layout.sectionInset = UIEdgeInsetsZero;
            layout.itemSize = CGSizeMake(returnButton.height_mn + inset, returnButton.height_mn);
        }
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, returnButton.left_mn, returnButton.height_mn) collectionViewLayout:layout];
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[MNEmojiPacketCell class]
           forCellWithReuseIdentifier:MNEmojiPacketViewCellIdentifier];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        [self bringSubviewToFront:separator];
        
        if (configuration.style == MNEmojiKeyboardStyleRegular) {
            
            [self bringSubviewToFront:returnButton];
            
            UIImage *image = [MNBundle imageForResource:@"keyboard_shadow"];
            UIImageView *rightShadowView = [UIImageView imageViewWithFrame:CGRectZero image:image];
            rightShadowView.size_mn = CGSizeMultiplyToHeight(image.size, returnButton.height_mn);
            rightShadowView.centerY_mn = rightShadowView.centerY_mn;
            rightShadowView.centerX_mn = returnButton.left_mn;
            [self insertSubview:rightShadowView belowSubview:returnButton];
            
            UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, .5f, returnButton.height_mn)];
            rightLine.top_mn = returnButton.top_mn;
            rightLine.right_mn = returnButton.left_mn;
            rightLine.backgroundColor = separator.backgroundColor;
            [self insertSubview:rightLine belowSubview:returnButton];
        }
    }
    return self;
}

- (void)reloadData {
    NSMutableArray <UIImage *>*dataArray = @[].mutableCopy;
    [dataArray addObject:[MNBundle imageForResource:@"keyboard_add"]];
    [self.emojiPackets enumerateObjectsUsingBlock:^(MNEmojiPacket * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dataArray addObject:obj.image];
    }];
    self.dataArray = dataArray.copy;
    self.selectedIndex = dataArray.count > 1 ? 1 : NSIntegerMax;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNEmojiPacketViewCellIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MNEmojiPacketCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.dataArray.count) return;
    [cell setImage:self.dataArray[indexPath.item] selected:indexPath.item == self.selectedIndex configuration:self.configuration];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item <= 0) {
        if ([self.delegate respondsToSelector:@selector(emojiPacketAddButtonTouchUpInside)]) {
            [self.delegate emojiPacketAddButtonTouchUpInside];
        }
        return;
    }
    NSInteger item = indexPath.item - 1;
    [self selectPacketOfIndex:indexPath.item - 1];
    if ([self.delegate respondsToSelector:@selector(emojiPacketViewDidSelectPacketOfIndex:)]) {
        [self.delegate emojiPacketViewDidSelectPacketOfIndex:item];
    }
}

#pragma mark - 展示指定选择项
- (void)selectPacketOfIndex:(NSUInteger)index {
    index ++;
    if (index >= self.dataArray.count || index == self.selectedIndex) return;
    NSInteger lastSelectedIndex = self.selectedIndex;
    self.selectedIndex = index;
    NSMutableArray <NSIndexPath *>*indexPaths = @[].mutableCopy;
    [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
    if (lastSelectedIndex < self.dataArray.count) [indexPaths addObject:[NSIndexPath indexPathForItem:lastSelectedIndex inSection:0]];
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

#pragma mark - Event
- (void)returnButtonTouchUpInside:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(emojiReturnButtonTouchUpInside)]) {
        [self.delegate emojiReturnButtonTouchUpInside];
    }
}

#pragma mark - Getter
- (NSArray <MNEmojiPacket *>*)emojiPackets {
    if ([self.dataSource respondsToSelector:@selector(emojiPacketsOfPacketView)]) {
        return [self.dataSource emojiPacketsOfPacketView];
    }
    return @[];
}

- (NSString *)returnButtonTitle {
    NSArray <NSString *>*buttonTitles = @[@"换行", @"前往", @"Google", @"加入", @"下一项", @"路线", @"搜索", @"发送", @"Yahoo", @"确定", @"紧急", @"继续"];
    if (self.configuration.returnKeyType >= buttonTitles.count) return @"确定";
    return buttonTitles[self.configuration.returnKeyType];
}

@end
