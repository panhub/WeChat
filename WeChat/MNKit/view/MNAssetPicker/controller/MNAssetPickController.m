//
//  MNAssetPickController.m
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetPickController.h"
#import "MNAssetPickConfiguration.h"
#import "MNImageCropController.h"
#import "MNCapturingController.h"
#import "MNAssetTouchController.h"
#import "MNAssetPreviewController.h"
#import "MNAlbumSelectControl.h"
#import "MNAssetToolBar.h"
#import "MNAlbumView.h"
#import "MNAssetHelper.h"
#import "MNAssetCollection.h"
#import "MNAssetCell.h"
#import "MNAssetBrowser.h"
#import <Photos/Photos.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import "MNAssetTouchController.h"
@interface MNAssetPickController ()<MNAssetCellDelegate, MNImageCropDelegate, MNAlbumViewDelegate, MNAssetToolDelegate, MNCapturingControllerDelegate, MNAssetBrowseDelegate, MNAssetTouchDelegate, MNAssetPreviewDelegate, MNImageCropDelegate, UIViewControllerPreviewingDelegate, PHPhotoLibraryChangeObserver>
#else
@interface MNAssetPickController ()<MNAssetCellDelegate, MNImageCropDelegate, MNAlbumViewDelegate, MNAssetToolDelegate, MNCapturingControllerDelegate, MNAssetBrowseDelegate, MNAssetTouchDelegate, MNAssetPreviewDelegate, MNImageCropDelegate, PHPhotoLibraryChangeObserver>
#endif
@property (nonatomic, strong) MNAssetCollection *collection;
@property (nonatomic, strong) MNAlbumView *albumView;
@property (nonatomic, strong) MNAssetToolBar *assetToolBar;
@property (nonatomic, strong) MNAlbumSelectControl *albumToolBar;
@property (nonatomic, strong) MNAssetPickConfiguration *configuration;
@property (nonatomic, strong) NSArray <MNAssetCollection *>*collections;
@property (nonatomic, strong) NSMutableArray <MNAsset *>*selectedArray;
@end

@implementation MNAssetPickController
- (instancetype)init {
    return [self initWithConfiguration:[MNAssetPickConfiguration new]];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithConfiguration:[MNAssetPickConfiguration new]];
}
#pragma clang diagnostic pop

- (instancetype)initWithConfiguration:(MNAssetPickConfiguration *)configuration {
    if (self = [super init]) {
        self.configuration = configuration;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = UIColorWithSingleRGB(240.f);
    
    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = self.contentView.backgroundColor;
    [self.collectionView registerClass:[MNAssetCell class] forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionLayout;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, layout.sectionInset.top, self.contentView.width_mn, self.contentView.height_mn - layout.sectionInset.top - layout.sectionInset.bottom)];
    backgroundView.userInteractionEnabled = YES;
    backgroundView.backgroundColor = self.contentView.backgroundColor;
    UIImageView *emptyView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, MEAN_3(backgroundView.width_mn), MEAN_3(backgroundView.width_mn)) image:[MNBundle imageForResource:@"empty_photo"]];
    emptyView.center_mn = backgroundView.bounds_center;
    [backgroundView addSubview:emptyView];
    [self.contentView insertSubview:backgroundView belowSubview:self.collectionView];
    
    if (self.configuration.allowsPickingAlbum) {
        MNAlbumView *albumView = [[MNAlbumView alloc] initWithFrame:backgroundView.frame];
        albumView.delegate = self;
        [self.contentView addSubview:albumView];
        self.albumView = albumView;
    }
    
    if (self.configuration.maxPickingCount > 1) {
        MNAssetToolBar *assetToolBar = [[MNAssetToolBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width_mn, layout.sectionInset.bottom)];
        assetToolBar.bottom_mn = self.view.height_mn;
        assetToolBar.delegate = self;
        [self.view addSubview:assetToolBar];
        self.assetToolBar = assetToolBar;
    }
    
    /// 监听相册变动代理
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 注册3DTouch
    if (@available(iOS 9.0, *)) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Event
- (void)loadData {
    [MNAuthenticator requestAlbumAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            [self reloadData];
        } else {
            self.collectionView.hidden = YES;
            [[MNAlertView alertViewWithTitle:@"权限不足" message:@"请前往“设置-隐私-照片”打开应用的相册访问权限" handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
    }];
}

- (void)reloadData {
    [self.contentView showDialog:MNLoadDialogStyleActivity message:@"加载中"];
    [MNAssetHelper fetchAssetCollectionsWithConfiguration:self.configuration completion:^(NSArray<MNAssetCollection *>*dataArray) {
        self.collections = dataArray;
        self.albumToolBar.hidden = dataArray.count <= 0;
        self.albumToolBar.selectEnabled = dataArray.count > 1;
        self.collectionView.hidden = dataArray.count <= 0;
        if (dataArray.count) self.collection = dataArray.firstObject;
        if (self.albumView) self.albumView.dataArray = dataArray;
        [self.contentView closeDialog];
    }];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collection.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MNAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(MNAssetCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell didEndDisplaying];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(MNAssetCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.asset = self.collection.assets[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.collection.assets.count) return;
    MNAsset *model = self.collection.assets[indexPath.item];
    if (!model.isEnabled || model.status == MNAssetStatusDownloading) return;
    if (model.isCapturingModel) {
        /// 拍照/拍摄
        MNCapturingController *vc = [MNCapturingController new];
        vc.delegate = self;
        vc.configuration = self.configuration;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (self.configuration.maxPickingCount == 1) {
        /// 编辑
        if (model.type == MNAssetTypePhoto && self.configuration.allowsEditing) {
            [self cropImageAsset:model];
        } else if (self.configuration.allowsPreviewing) {
            MNAssetPreviewController *vc = [[MNAssetPreviewController alloc] initWithAssets:@[model]];
            vc.delegate = self;
            vc.allowsSelect = NO;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self didFinishPickingAssets:@[model]];
        }
    } else if (self.configuration.allowsPreviewing) {
        /// 预览
        NSArray <MNAsset *>*assets = [self.collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isCapturingModel == NO"]];
        if (assets.count <= 0) return;
        MNAssetBrowser *browser = [MNAssetBrowser new];
        browser.assets = assets;
        browser.delegate = self;
        browser.allowsSelect = YES;
        browser.backgroundColor = UIColor.blackColor;
        [browser presentInView:self.contentView fromAsset:model animated:YES completion:nil];
    } else {
        /// 选择
        [self didSelectAsset:model];
    }
}

#pragma mark - 裁剪图片
- (void)cropImageAsset:(MNAsset *)asset {
    UIViewController *vc = self.navigationController.viewControllers.lastObject;
    [vc.view showDialog:MNLoadDialogStyleActivity message:@"请稍后"];
    dispatch_async(dispatch_get_high_queue(), ^{
        [MNAssetHelper requestAssetContent:asset configuration:nil completion:^(MNAsset *obj) {
            dispatch_async_main(^{
                [vc.view closeDialogWithCompletionHandler:^{
                    if (obj.content) {
                        MNImageCropController *v = [[MNImageCropController alloc] initWithImage:obj.content];
                        v.delegate = self;
                        v.cropScale = self.configuration.cropScale;
                        [vc.navigationController pushViewController:v animated:YES];
                    } else {
                        [vc.view showInfoDialog:@"获取图片出错"];
                    }
                }];
            });
        }];
    });
}

#pragma mark - 选择内容完成
- (void)didFinishPickingAssets:(NSArray <MNAsset *>*)assets {
    [self.navigationController.view showDialog:MNLoadDialogStyleActivity message:@"请稍后"];
    dispatch_async(dispatch_get_high_queue(), ^{
        [MNAssetHelper requestContentWithAssets:assets configuration:self.configuration completion:^(NSArray<MNAsset *>* models) {
            // 判断是否有下载失败项<通常为下载iCloud文件失败>
            NSArray <MNAsset *>*failAssets = [models filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.status != %@", @(MNAssetStatusCompleted)]];
            NSMutableArray <MNAsset *>*succAssets = models.mutableCopy;
            if (failAssets.count) [succAssets removeObjectsInArray:failAssets];
            dispatch_async_main(^{
                [self.navigationController.view closeDialogWithCompletionHandler:^{
                    if (failAssets.count <= 0) {
                        // 获取资源成功
                        [self enterPickingAssets:succAssets];
                    } else if (succAssets.count <= 0 || succAssets.count < self.configuration.minPickingCount) {
                        // 仅有一个资源且获取失败或者成功的数量小于最小限制
                        [[MNAlertView alertViewWithTitle:nil message:@"请求iCloud内容失败\n请切换网络重试!" handler:nil ensureButtonTitle:@"关闭" otherButtonTitles:nil] show];
                    } else {
                        // 有获取失败项
                        [[MNAlertView alertViewWithTitle:@"提示" message:@"请求iCloud内容失败\n是否继续?" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == alertView.ensureButtonIndex) {
                                [self enterPickingAssets:succAssets];
                            }
                        } ensureButtonTitle:@"确定" otherButtonTitles:@"取消", nil] show];
                    }
                }];
            });
        }];
    });
}

- (void)enterPickingAssets:(NSArray <MNAsset *>*)assets {
    if ([self.configuration.delegate respondsToSelector:@selector(assetPicker:didFinishPickingAssets:)]) {
        [self.configuration.delegate assetPicker:kTransform(MNAssetPicker *, self.navigationController) didFinishPickingAssets:assets.copy];
    }
}

#pragma mark - MNAssetBrowseDelegate
- (void)assetBrowserWillPresent:(MNAssetBrowser *)assetBrowser {
    [UIView animateWithDuration:MNAssetBrowsePresentAnimationDuration animations:^{
        self.navigationBar.alpha = self.assetToolBar.alpha = 0.f;
    }];
}

- (void)assetBrowserWillDismiss:(MNAssetBrowser *)assetBrowser {
    [UIView animateWithDuration:MNAssetBrowseDismissAnimationDuration animations:^{
        self.navigationBar.alpha = self.assetToolBar.alpha = 1.f;
    }];
}

- (void)assetBrowser:(MNAssetBrowser *)assetBrowser didSelectAsset:(MNAsset *)asset {
    [self didSelectAsset:asset];
}

#pragma mark - MNAssetCellDelegate
- (BOOL)assetCellShouldDisplaySelectControl {
    return self.configuration.maxPickingCount > 1;
}

#pragma mark - Common Delegate
- (void)didSelectAsset:(MNAsset *)model {
    /// 这里把 maxPickingCount == 1 情况, 因为不会到这里
    if (model.selected) {
        /// 取消选择
        model.selected = NO;
        [self.selectedArray removeObject:model];
    } else {
        /// 选择
        model.selected = YES;
        [self.selectedArray addObject:model];
    }
    /// 判断是否超过限制
    if (self.selectedArray.count >= self.configuration.maxPickingCount) {
        /// 达到最大限制, 不可再选
        NSArray <MNAsset *>*assets = [self.collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO && self.isEnabled == YES"]];
        [assets setValue:@(NO) forKey:@"enabled"];
    } else {
        /// 可以继续再选择
        NSArray <MNAsset *>*assets = [self.collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO && self.isEnabled == NO"]];
        [assets setValue:@(YES) forKey:@"enabled"];
        /// 再进行类型限制
        if (self.selectedArray.count > 0 && !self.configuration.allowsMixPicking) {
            MNAssetType type = self.selectedArray.firstObject.type;
            if (type == MNAssetTypeVideo) {
                NSArray <MNAsset *>*assets = [self.collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO && self.type != %ld", type]];
                [assets setValue:@(NO) forKey:@"enabled"];
            } else {
                NSArray <MNAsset *>*assets = [self.collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO && self.type == %ld", MNAssetTypeVideo]];
                [assets setValue:@(NO) forKey:@"enabled"];
            }
        }
    }
    /// 更新底部提示
    if (self.assetToolBar) self.assetToolBar.count = self.selectedArray.count;
    /// 标注处理
    if (self.configuration.showPickingNumber) {
        [self.selectedArray enumerateObjectsUsingBlock:^(MNAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selectIndex = idx + 1;
        }];
    }
    /// 刷新数据
    [self.collectionView reloadData];
}

#pragma mark - MNAlbumViewDelegate
- (void)albumView:(MNAlbumView *)albumView didSelectAlbum:(MNAssetCollection *)album {
    if (album && album != self.collection) self.collection = album;
    self.albumToolBar.selected = NO;
    [albumView dismiss];
}

#pragma mark - MNAssetToolDelegate
- (void)assetToolBarLeftBarItemClicked:(MNAssetToolBar *)toolBar {
    MNAssetPreviewController *vc = [[MNAssetPreviewController alloc] initWithAssets:self.selectedArray];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)assetToolBarClearButtonClicked:(MNAssetToolBar *)toolBar {
    [[MNAlertView alertViewWithTitle:nil message:@"确定清空所选内容?" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.ensureButtonIndex) return;
        toolBar.count = 0;
        [self.selectedArray removeAllObjects];
        [self.collections enumerateObjectsUsingBlock:^(MNAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.assets setValue:@(NO) forKey:@"selected"];
            [obj.assets setValue:@(YES) forKey:@"enabled"];
        }];
        [self.collectionView reloadData];
        if (self.albumToolBar.selected) [self.albumView reloadData];
    } ensureButtonTitle:@"确定" otherButtonTitles:@"取消", nil] show];
}

- (void)assetToolBarRightBarItemClicked:(MNAssetToolBar *)toolBar {
    /// 判断是否允许退出
    NSUInteger minCount = self.configuration.minPickingCount;
    if (minCount > 0 && self.selectedArray.count < minCount) {
        [[MNAlertView alertViewWithTitle:nil message:[NSString stringWithFormat:@"至少挑选%@项资源", @(minCount).stringValue] handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    /// 确认选择
    [self didFinishPickingAssets:self.selectedArray.copy];
}

#pragma mark - MNCapturingControllerDelegate
- (void)capturingControllerDidCancel:(MNCapturingController *)capturingController {
    [capturingController.navigationController popViewControllerAnimated:[[UIApplication sharedApplication] applicationState] == UIApplicationStateActive];
}

- (void)capturingController:(MNCapturingController *)capturingController didFinishWithContent:(id)content {
    if ([content isKindOfClass:UIImage.class] && self.configuration.exportPixel > 0.f) {
        UIImage *image = [kTransform(UIImage *, content) resizingToPix:self.configuration.exportPixel];
        if (image) content = image;
    }
    MNAsset *model = [MNAsset assetWithContent:content renderSize:self.configuration.renderSize];
    if (self.configuration.sortAscending) {
        [self.collection addAsset:model];
    } else {
        [self.collection insertAssetAtFront:model];
    }
    self.collection = self.collection;
    if (self.configuration.allowsWritToAlbum) [MNAssetHelper writeContent:@[content] toAlbum:self.collection.localizedTitle completion:nil];
    [capturingController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MNImageCropDelegate
- (void)imageCropControllerDidCancel:(MNImageCropController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropController:(MNImageCropController *)controller didCroppingImage:(UIImage *)image {
    [self didFinishPickingAssets:@[[MNAsset assetWithContent:image]]];
}

#pragma mark - MNAssetPreviewDelegate
- (void)previewControllerDoneButtonClicked:(MNAssetPreviewController *)previewController {
    [self didFinishPickingAssets:previewController.assets];
}

#pragma mark - MNAssetTouchDelegate
- (void)touchControllerDoneButtonClicked:(MNAssetTouchController *)touchController {
    MNAsset *asset = touchController.asset;
    if (asset.type == MNAssetTypePhoto && self.configuration.allowsEditing) {
        [self cropImageAsset:asset];
    } else {
        [self didFinishPickingAssets:@[asset]];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if (self.collection.assets.count <= 0) return nil;
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) return nil;
    MNAsset *model = self.collection.assets[indexPath.item];
    if (model.isCapturingModel || !model.thumbnail || model.status == MNAssetStatusDownloading) return nil;
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *action, UIViewController *previewViewController) {
        NSLog(@"===取消===");
    }];
    MNAssetTouchController *vc = [MNAssetTouchController new];
    vc.asset = model;
    vc.actions = @[action];
    vc.allowsSelect = self.configuration.maxPickingCount > 1;
    return vc;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(MNAssetTouchController *)viewController {
    viewController.delegate = self;
    viewController.state = MNAssetTouchStateWeight;
    [self showViewController:viewController sender:self];
}
#pragma clang diagnostic pop
#endif

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    NSLog(@"相册内容变动");
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar {
    UIImageView *blurEffect = [UIImageView imageViewWithFrame:navigationBar.bounds image:[UIImage imageWithColor:UIColorWithAlpha([UIColor whiteColor], .97f) size:navigationBar.size_mn]];
    blurEffect.userInteractionEnabled = YES;
    [navigationBar insertSubview:blurEffect atIndex:0];
    MNAlbumSelectControl *albumToolBar = [MNAlbumSelectControl new];
    albumToolBar.hidden = YES;
    albumToolBar.center_mn = navigationBar.titleView.bounds_center;
    albumToolBar.touchInset = UIEdgeInsetsMake(-10.f, 0.f, -10.f, 0.f);
    [albumToolBar addTarget:self action:@selector(albumToolBarClicked:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar.titleView addSubview:albumToolBar];
    self.albumToolBar = albumToolBar;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 30.f) image:nil title:@"取消" titleColor:[UIColor darkTextColor] titleFont:UIFontRegular(17.f)];
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if ([self.configuration.delegate respondsToSelector:@selector(assetPickerDidCancel:)]) {
        [self.configuration.delegate assetPickerDidCancel:kTransform(MNAssetPicker *, self.navigationController)];
    } else {
        if (self.navigationController.presentingViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - 选择相册
- (void)albumToolBarClicked:(MNAlbumSelectControl *)toolBar {
    if (self.collections.count <= 1) return;
    toolBar.selected = !toolBar.selected;
    if (toolBar.selected) {
        [self.albumView show];
    } else {
        [self.albumView dismiss];
    }
}

#pragma mark - Setter
- (void)setCollection:(MNAssetCollection *)collection {
    /// 处理不可选
    [collection.assets setValue:@(YES) forKey:@"enabled"];
    if (self.configuration.maxPickingCount > 1 && collection.assets.count > 0) {
        if (self.selectedArray.count >= self.configuration.maxPickingCount) {
            NSArray <MNAsset *>*assets = [collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO"]];
            [assets setValue:@(NO) forKey:@"enabled"];
        } else if (self.selectedArray.count > 0 && !self.configuration.allowsMixPicking) {
            MNAssetType type = self.selectedArray.firstObject.type;
            if (type == MNAssetTypeVideo) {
                NSArray <MNAsset *>*assets = [collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO && self.type != %ld", type]];
                [assets setValue:@(NO) forKey:@"enabled"];
            } else {
                NSArray <MNAsset *>*assets = [collection.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == NO && self.type == %ld", MNAssetTypeVideo]];
                [assets setValue:@(NO) forKey:@"enabled"];
            }
        }
    }
    /// 更新数据
    _collection = collection;
    _albumToolBar.title = collection.title;
    [self.collectionView reloadData];
    self.collectionView.hidden = collection.assets.count <= 0;
    if (collection.assets.count > 0 && self.configuration.sortAscending) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:collection.assets.count - 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:NO];
    }
}

#pragma mark - Getter
- (NSMutableArray <MNAsset *>*)selectedArray {
    if (!_selectedArray) {
        NSMutableArray <MNAsset *>*selectedArray = [NSMutableArray arrayWithCapacity:0];
        _selectedArray = selectedArray;
    }
    return _selectedArray;
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (BOOL)isRootViewController {
    return NO;
}

- (UICollectionViewLayout *)collectionViewLayout {
    CGFloat wh = (self.contentView.width_mn - (self.configuration.numberOfColumns - 1)*5.f)/self.configuration.numberOfColumns;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 5.f;
    layout.minimumInteritemSpacing = 5.f;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(wh, wh);
    CGFloat bottom = self.configuration.maxPickingCount > 1 ? UITabSafeHeight() + 50.f : 0.f;
    layout.sectionInset = UIEdgeInsetsMake(self.navigationBar.height_mn, 0.f, bottom, 0.f);
    return layout;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

#pragma mark - dealloc
- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

@end
