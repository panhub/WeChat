//
//  WXCropViewController.m
//  MNChat
//
//  Created by Vincent on 2019/11/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCropViewController.h"
#import "WXImageCropModel.h"
#import "WXImageCropCell.h"

@interface WXCropViewController ()<MNAssetPickerDelegate>
@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger column;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) NSArray <NSNumber *> *rowArray;
@property (nonatomic, strong) NSArray <NSNumber *> *columnArray;
@property (nonatomic, strong) NSMutableArray <UIImage *>*subImages;
@end

@implementation WXCropViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"宫格切图";
        self.row = self.column = 3;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.navigationBar.shadowColor = UIColor.whiteColor;
    
    self.collectionView.alpha = 0.f;
    self.collectionView.frame = self.contentView.bounds;
    self.collectionView.backgroundColor = VIEW_COLOR;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:WXImageCropCell.class forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    
    UIImageView *selectImageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn/5.f, self.contentView.width_mn/5.f) image:UIImageNamed(@"wx_contacts_avatar_add")];
    selectImageView.centerX_mn = self.contentView.width_mn/2.f;
    selectImageView.centerY_mn = self.contentView.height_mn/3.f;
    [self.contentView addSubview:selectImageView];
    self.selectImageView = selectImageView;
    
    UILabel *selectLabel = [UILabel labelWithFrame:CGRectMake(0.f, selectImageView.bottom_mn + 10.f, self.contentView.width_mn, 16.f) text:@"点击选择图片" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.darkTextColor, .88f) font:UIFontRegular(16.f)];
    [self.contentView addSubview:selectLabel];
    self.selectLabel = selectLabel;
    
    UIButton *selectButton = [UIButton buttonWithFrame:CGRectMake((self.contentView.width_mn - 250.f)/3.f, 0.f, 125.f, 40.f) image:nil title:@"修改图片" titleColor:UIColor.whiteColor titleFont:UIFontRegular(16.f)];
    selectButton.alpha = 0.f;
    selectButton.bottom_mn = self.contentView.height_mn - MAX(MN_TAB_SAFE_HEIGHT, 25.f) - 30.f;
    selectButton.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(selectButton, selectButton.height_mn/2.f);
    [selectButton addTarget:self action:@selector(selectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectButton];
    self.selectButton = selectButton;
    
    UIButton *saveButton = [UIButton buttonWithFrame:selectButton.frame image:nil title:@"保存至相册" titleColor:UIColor.whiteColor titleFont:UIFontRegular(16.f)];
    saveButton.alpha = 0.f;
    saveButton.right_mn = self.contentView.width_mn - selectButton.left_mn;
    saveButton.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(saveButton, saveButton.height_mn/2.f);
    [saveButton addTarget:self action:@selector(saveImagesToAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:saveButton];
    self.saveButton = saveButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.subImages.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull WXImageCropCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    cell.image = self.subImages[indexPath.item];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(MNCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = self.subImages[indexPath.item];
    CGFloat w = collectionView.width_mn - collectionViewLayout.minimumInteritemSpacing*(self.column - 1);
    return CGSizeMultiplyToWidth(image.size, w/self.column);
}

#pragma mark - Event
- (void)saveImagesToAlbum {
    if (self.subImages.count > 0) {
        [self.view showWechatDialog];
        [MNAssetHelper writeAssets:self.subImages toAlbum:nil completion:^(NSArray<NSString *> * _Nullable identifiers, NSError * _Nullable error) {
            if (identifiers.count <= 0) {
                [self.view showInfoDialog:error.localizedDescription];
            } else {
                [self.view showCompletedDialog:@"已保存至系统相册"];
            }
        }];
    } else {
        [self.view showInfoDialog:@"操作失败"];
    }
}

- (void)selectButtonClicked {
    MNAssetPicker *imagePicker = [[MNAssetPicker alloc] init];
    imagePicker.configuration.delegate = self;
    imagePicker.configuration.allowsPreviewing = YES;
    imagePicker.configuration.allowsPickingGif = YES;
    imagePicker.configuration.allowsPickingVideo = NO;
    imagePicker.configuration.allowsPickingLivePhoto = YES;
    imagePicker.configuration.requestGifUseingPhotoPolicy = YES;
    imagePicker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
    imagePicker.configuration.allowsEditing = YES;
    imagePicker.configuration.allowsCapturing = YES;
    imagePicker.configuration.maxPickingCount = 1;
    imagePicker.configuration.maxExportPixel = 0.f;
    imagePicker.configuration.cropScale = 0.f;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - MNAssetPickerDelegate
- (void)assetPickerDidCancel:(MNAssetPicker *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)assetPicker:(MNAssetPicker *)picker didFinishPickingAssets:(NSArray <MNAsset *>*)assets {
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        if (assets.count <= 0) {
            [self.view showInfoDialog:@"获取图片失败"];
            return;
        }
        UIImage *image = assets.firstObject.content;
        if (!image) {
            [self.view showInfoDialog:@"获取图片失败"];
            return;
        }
        self.image = image;
        [self reloadImagesIfNeeded];
    }];
}

- (void)reloadImagesIfNeeded {
    if (!self.image) return;
    @weakify(self);
    [self.subImages removeAllObjects];
    CGSize imageSize = CGSizeMultiplyByRatio(self.image.size, self.image.scale);
    [self.view showWechatDialogDelay:.35f eventHandler:^{
        @strongify(self);
        for (NSInteger idx = 0; idx < self.row; idx++) {
            for (NSInteger i = 0; i < self.column; i++) {
                CGRect rect = CGRectMake(imageSize.width/self.column*i, imageSize.height/self.row*idx, imageSize.width/self.column, imageSize.height/self.row);
                UIImage *cropImage = [self.image cropImageInRect:rect];
                if (cropImage) [self.subImages addObject:cropImage];
            }
        }
    } completionHandler:^{
        @strongify(self);
        [self reloadList];
        [UIView animateWithDuration:.2f animations:^{
            self.selectImageView.alpha = self.selectLabel.alpha = 0.f;
            self.collectionView.alpha = self.selectButton.alpha = self.saveButton.alpha = 1.f;
        }];
    }];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIView *rightBarItem = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 30.f)];
    rightBarItem.backgroundColor = [UIColor whiteColor];
    rightBarItem.layer.cornerRadius = rightBarItem.height_mn/2.f;
    rightBarItem.clipsToBounds = YES;
    UIImage *moreImage = [UIImage imageNamed:@"wx_applet_more"];
    CGSize moreSize = CGSizeMultiplyToHeight(moreImage.size, rightBarItem.height_mn);
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0.f, 0.f, moreSize.width, moreSize.height);
    [moreButton setBackgroundImage:moreImage forState:UIControlStateNormal];
    [moreButton setBackgroundImage:moreImage forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem addSubview:moreButton];
    UIImage *exitImage = [UIImage imageNamed:@"wx_applet_exit"];
    CGSize exitSize = CGSizeMultiplyToHeight(exitImage.size, rightBarItem.height_mn);
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.tag = 1;
    exitButton.frame = CGRectMake(moreButton.right_mn, moreButton.top_mn, exitSize.width, exitSize.height);
    [exitButton setBackgroundImage:exitImage forState:UIControlStateNormal];
    [exitButton setBackgroundImage:exitImage forState:UIControlStateHighlighted];
    [exitButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem addSubview:exitButton];
    rightBarItem.width_mn = exitButton.right_mn;
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:@"选择宫格尺寸" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        @strongify(self);
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        self.row = self.rowArray[buttonIndex].integerValue;
        self.column = self.columnArray[buttonIndex].integerValue;
        [self reloadImagesIfNeeded];
    } otherButtonTitles:@"2x2", @"3x3", @"3x2",nil] showInView:self.view];
}

#pragma mark - Getter
- (NSMutableArray <UIImage *>*)subImages {
    if (!_subImages) {
        _subImages = [NSMutableArray arrayWithCapacity:9];
    }
    return _subImages;
}

- (NSArray <NSNumber *>*)columnArray {
    if (!_columnArray) {
        _columnArray = @[@(2), @(3), @(3)];
    }
    return _columnArray;
}

- (NSArray <NSNumber *>*)rowArray {
    if (!_rowArray) {
        _rowArray = @[@(2), @(3), @(2)];
    }
    return _rowArray;
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (void)reloadList {
    MNCollectionVerticalLayout *layout = (MNCollectionVerticalLayout *)self.collectionView.collectionViewLayout;
    layout.numberOfFormation = self.column;
    [super reloadList];
}

- (UICollectionViewLayout *)collectionViewLayout {
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.numberOfFormation = 3;
    layout.minimumLineSpacing = 5.f;
    layout.minimumInteritemSpacing = 5.f;
    layout.sectionInset = UIEdgeInsetsMake(5.f, 0.f, 0.f, 0.f);
    return layout;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject.tapCount != 1 || self.selectImageView.alpha != 1.f) return;
    [self selectButtonClicked];
}

@end
