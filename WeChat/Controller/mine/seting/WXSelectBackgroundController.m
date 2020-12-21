//
//  WXSelectBackgroundController.m
//  MNChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSelectBackgroundController.h"
#import "WXSelectBackgroundCell.h"

@interface WXSelectBackgroundController ()
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray <NSString *>*imgs;
@property (nonatomic, strong) NSArray <UIImage *>*dataArray;
@end

@implementation WXSelectBackgroundController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"选择背景图";
    }
    return self;
}

- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = VIEW_COLOR;
    
    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.contentView.backgroundColor = VIEW_COLOR;
    [self.collectionView registerClass:[WXSelectBackgroundCell class] forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSArray <NSString *>*imgs = @[@"", @"chat_bg_01", @"chat_bg_02", @"chat_bg_03", @"chat_bg_04", @"chat_bg_05", @"chat_bg_06", @"chat_bg_07", @"chat_bg_08", @"chat_bg_09", @"chat_bg_10", @"chat_bg_11"];
    NSString *background = [NSUserDefaults stringForKey:WXChatBackgroundKey def:@""];
    if ([imgs containsObject:background]) self.selectedIndex = [imgs indexOfObject:background];
    NSMutableArray <UIImage *>*dataArray = [NSMutableArray arrayWithCapacity:imgs.count];
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = obj.length > 0 ? [UIImage imageNamed:obj] : [UIImage imageWithColor:VIEW_COLOR];
        [dataArray addObject:image];
    }];
    self.imgs = imgs.copy;
    self.dataArray = dataArray.copy;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXSelectBackgroundCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = self.dataArray[indexPath.item];
    cell.selected = indexPath.item == self.selectedIndex;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.item;
    [self reloadList];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, kNavItemSize)
                                             image:nil
                                             title:@"取消"
                                        titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                         titleFont:@(17.f)];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 53.f, 32.f)
                                              image:nil
                                              title:@"完成"
                                         titleColor:[UIColor whiteColor]
                                          titleFont:[UIFont systemFontOfSizes:17.f weights:.15f]];
    rightBarItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightBarItem, 3.f);
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    NSString *img = self.imgs[self.selectedIndex];
    [[NSUserDefaults standardUserDefaults] setObject:img forKey:WXChatBackgroundKey];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (__kindof UICollectionViewLayout *)collectionViewLayout {
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.numberOfFormation = 3;
    layout.minimumLineSpacing = 5.f;
    layout.minimumInteritemSpacing = 5.f;
    layout.itemSize = CGSizeMake(1.f, 1.f);
    layout.sectionInset = UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f);
    return layout;
}

@end
