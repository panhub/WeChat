//
//  WXNewMomentController.m
//  WeChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXNewMomentController.h"
#import "WXAddMomentTableView.h"
#import "WXAddMomentCollectionViewCell.h"
#import "WXNewMomentDeleteView.h"
#import "WXAddProfile.h"
#import "WXMoment.h"
#import "WXLocation.h"

#define WXNewMomentCollectionTopMargin 35.f
#define WXNewMomentCollectionBottomMargin 75.f
#define WXNewMomentCollectionAnimationDuration .25f

#define WXNewMomentCollectionMaxWidth 155.f
#define WXNewMomentCollectionMaxHeight 155.f

@interface WXNewMomentController ()<MNTextViewHandler, MNEmojiKeyboardDelegate>
// 表情
@property (nonatomic, strong) UIView *emojiView;
// 表情按钮
@property (nonatomic, strong) UIButton *emojiButton;
// 记录拖拽的索引
@property (nonatomic, strong) NSIndexPath *indexPath;
// 底部滑动视图
@property (nonatomic, strong) UIScrollView *scrollView;
// 文字编辑区
@property (nonatomic, strong) MNEmojiTextView *textView;
// 拖拽交互
@property (nonatomic, strong) UIImageView *interactiveView;
// 表情键盘
@property (nonatomic, strong) MNEmojiKeyboard *emojiKeyboard;
// 底部选项
@property (nonatomic, strong) WXAddMomentTableView *optionView;
// 底部删除区域
@property (nonatomic, strong) WXNewMomentDeleteView *deleteView;
// 数据源
@property (nonatomic, strong) NSMutableArray <WXAddProfile *>*dataSource;
@end

@implementation WXNewMomentController
- (instancetype)initWithAssets:(NSArray <MNAsset *>*_Nullable)assets {
    if (self = [super init]) {
        [assets enumerateObjectsUsingBlock:^(MNAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type <= MNAssetTypeVideo) [self.dataSource addObject:[WXAddProfile modelWithAsset:obj]];
        }];
    }
    return self;
}

- (void)initialized {
    [super initialized];
    self.dataSource = @[].mutableCopy;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.navigationBar.shadowView.backgroundColor = UIColor.whiteColor;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;

    MNEmojiTextView *textView = [[MNEmojiTextView alloc] initWithFrame:CGRectMake(0.f, 25.f, scrollView.width_mn - 55.f, 45.f)];
    textView.handler = self;
    textView.centerX_mn = scrollView.width_mn/2.f;
    textView.font = [UIFont systemFontOfSize:17.f];
    textView.tintColor = THEME_COLOR;
    textView.placeholder = @"这一刻的想法...";
    textView.expandHeight = 110.f;
    textView.placeholderColor = [[UIColor grayColor] colorWithAlphaComponent:.4f];
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;
    textView.enablesReturnKeyAutomatically = YES;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0.f;
    if (@available(iOS 11.0, *)) {
        textView.textDragInteraction.enabled = NO;
    }
    [scrollView addSubview:textView];
    self.textView = textView;
    
    self.collectionView.frame = CGRectMake(textView.left_mn, textView.bottom_mn + WXNewMomentCollectionTopMargin, textView.width_mn, 100.f);
    self.collectionView.scrollEnabled = NO;
    self.collectionView.clipsToBounds = NO;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    [self.collectionView registerClass:[WXAddMomentCollectionViewCell class]
       forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    [self.collectionView removeFromSuperview];
    [scrollView addSubview:self.collectionView];
    
    WXAddMomentTableView *optionView = [[WXAddMomentTableView alloc] initWithFrame:CGRectMake(textView.left_mn, self.collectionView.bottom_mn + WXNewMomentCollectionBottomMargin, textView.width_mn, 0.f)];
    [scrollView addSubview:optionView];
    self.optionView = optionView;
    
    UIView *emojiView = [[UIView alloc] initWithFrame:self.view.bounds];
    emojiView.backgroundColor = MN_RGB(247.f);
    emojiView.top_mn = self.view.height_mn;
    [self.view addSubview:emojiView];
    self.emojiView = emojiView;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, emojiView.width_mn, MN_SEPARATOR_HEIGHT)];
    separator.backgroundColor = [UIColor.darkTextColor colorWithAlphaComponent:.15f];
    separator.clipsToBounds = YES;
    [emojiView addSubview:separator];
    
    UIButton *emojiButton = [UIButton buttonWithFrame:CGRectZero
                                                image:[[UIImage imageNamed:@"wx_chat_face"] imageWithColor:UIColor.blackColor]
                                                title:nil
                                           titleColor:nil
                                                 titleFont:nil];
    emojiButton.size_mn = CGSizeMake(28.f, 28.f);
    emojiButton.left_mn = 17.f;
    emojiButton.top_mn = 10.f;
    emojiButton.touchInset = UIEdgeInsetWith(-5.f);
    [emojiButton setBackgroundImage:[[UIImage imageNamed:@"wx_chat_keyboard"] imageWithColor:UIColor.blackColor] forState:UIControlStateSelected];
    [emojiButton addTarget:self action:@selector(emojiButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [emojiView addSubview:emojiButton];
    self.emojiButton = emojiButton;
    
    UIImageView *interactiveView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
    interactiveView.hidden = YES;
    interactiveView.clipsToBounds = YES;
    [self.view addSubview:interactiveView];
    self.interactiveView = interactiveView;
    
    WXNewMomentDeleteView *deleteView = [[WXNewMomentDeleteView alloc] initWithFrame:self.view.bounds];
    deleteView.top_mn = self.view.height_mn;
    [self.view addSubview:deleteView];
    self.deleteView = deleteView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlongPress:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    @weakify(self);
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(NSNotification *not) {
        UIKeyboardWillChangeFrameConvert(not, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
            [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                @strongify(self);
                if (to.origin.y >= MN_SCREEN_HEIGHT) {
                    // 下落
                    self.emojiView.top_mn = self.view.height_mn;
                } else {
                    // 上升
                    self.emojiView.top_mn = to.origin.y - (self.emojiButton.bottom_mn + self.emojiButton.top_mn);
                }
            } completion:^(BOOL finished) {
                @strongify(self);
                if (self.emojiButton.isSelected && to.origin.y >= MN_SCREEN_HEIGHT) {
                    // 表情模式下非点击按钮导致收起键盘
                    self.textView.inputView = nil;
                    self.emojiButton.selected = NO;
                }
            }];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.interactiveView];
    [self.view bringSubviewToFront:self.deleteView];
}

- (void)loadData {
    if (self.dataSource.count > 9) {
        [self.dataSource removeObjectsInRange:NSMakeRange(9, self.dataSource.count - 9)];
    } else if (self.dataSource.count < 9) {
        if (self.dataSource.count <= 0 || self.dataSource.lastObject.type == WXAddProfileTypeImage) {
            [self.dataSource addObject:WXAddProfile.addModel];
        }
    }
    [self reloadList];
    [self layoutSubviews];
}

#pragma mark - Event
- (void)handlongPress:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.textView resignFirstResponder];
            CGPoint location = [recognizer locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
            if (!indexPath) break;
            WXAddProfile *model = [self.dataSource objectAtIndex:indexPath.item];
            if (model.type != WXAddProfileTypeImage) break;
            self.indexPath = indexPath;
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            self.interactiveView.image = model.image;
            self.interactiveView.contentMode = model.containerView.contentMode;
            self.interactiveView.frame = [self.view convertRect:cell.frame fromView:self.collectionView];
            cell.hidden = YES;
            self.interactiveView.hidden = NO;
            [UIView animateWithDuration:WXNewMomentCollectionAnimationDuration animations:^{
                self.deleteView.bottom_mn = self.view.height_mn;
                self.interactiveView.transform = CGAffineTransformMakeScale(1.08f, 1.08f);
                self.interactiveView.center = [self.view convertPoint:location fromView:self.collectionView];
            }];
        } break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.interactiveView.isHidden) return;
            self.interactiveView.center = [recognizer locationInView:self.view];
            self.deleteView.highlighted = CGRectIntersectsRect(self.interactiveView.frame, self.deleteView.frame);
            if (self.deleteView.isHighlighted) break;
            for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
                NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                if (!indexPath || indexPath == self.indexPath) continue;
                if ([self.dataSource objectAtIndex:indexPath.item].isAddModel) continue;
                CGRect frame = [self.view convertRect:cell.frame fromView:self.collectionView];
                CGFloat space = sqrtf(pow(self.interactiveView.center.x - CGRectGetMidX(frame), 2) + powf(self.interactiveView.center.y - CGRectGetMidY(frame), 2));
                if (space <= self.interactiveView.bounds.size.width/2.f) {
                    //移动 会调用willMoveToIndexPath方法更新数据源
                    [self.collectionView moveItemAtIndexPath:self.indexPath toIndexPath:indexPath];
                    // 修改数据源
                    WXAddProfile *model = self.dataSource[self.indexPath.item];
                    [self.dataSource removeObject:model];
                    [self.dataSource insertObject:model atIndex:indexPath.item];
                    //设置移动后的起始indexPath
                    self.indexPath = indexPath;
                    break;
                }
            }
        } break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (self.interactiveView.isHidden) return;
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.indexPath];
            // 结束动画过程中停止交互, 防止出问题
            self.view.userInteractionEnabled = NO;
            // 给截图视图一个动画移动到隐藏cell的新位置
            [UIView animateWithDuration:WXNewMomentCollectionAnimationDuration animations:^{
                self.deleteView.top_mn = self.view.height_mn;
                self.interactiveView.transform = CGAffineTransformIdentity;
                self.interactiveView.frame = [self.view convertRect:cell.frame fromView:self.collectionView];
            } completion:^(BOOL finished) {
                // 移除截图视图,显示隐藏的cell并开始交互
                cell.hidden = NO;
                self.interactiveView.hidden = YES;
                self.view.userInteractionEnabled = YES;
            }];
        } break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.interactiveView.isHidden) return;
            self.view.userInteractionEnabled = NO;
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.indexPath];
            if (self.deleteView.isHighlighted) {
                self.deleteView.highlighted = NO;
                self.interactiveView.hidden = YES;
                [self.dataSource removeObjectAtIndex:self.indexPath.item];
                [self.collectionView deleteItemsAtIndexPaths:@[self.indexPath]];
                if (self.dataSource.count <= 0 || self.dataSource.lastObject.type != WXAddProfileTypeAdd) {
                    [self.dataSource addObject:WXAddProfile.addModel];
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0]]];
                }
                [self layoutSubviewsUsingAnimation];
                [UIView animateWithDuration:WXNewMomentCollectionAnimationDuration animations:^{
                    self.deleteView.top_mn = self.view.height_mn;
                } completion:^(BOOL finished) {
                    cell.hidden = NO;
                    self.view.userInteractionEnabled = YES;
                }];
            } else {
                // 给截图视图一个动画移动到隐藏cell的新位置
                [UIView animateWithDuration:WXNewMomentCollectionAnimationDuration animations:^{
                    self.deleteView.top_mn = self.view.height_mn;
                    self.interactiveView.transform = CGAffineTransformIdentity;
                    self.interactiveView.frame = [self.view convertRect:cell.frame fromView:self.collectionView];
                } completion:^(BOOL finished) {
                    // 移除截图视图,显示隐藏的cell并开始交互
                    cell.hidden = NO;
                    self.interactiveView.hidden = YES;
                    self.view.userInteractionEnabled = YES;
                }];
            }
        } break;
        default:
            break;
    }
}

- (void)emojiButtonTouchUpInside:(UIButton *)button {
    button.selected = !button.selected;
    self.textView.inputView = button.isSelected ? self.emojiKeyboard : nil;
    [self.textView reloadInputViews];
    if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.dataSource.count) return;
    [self.scrollView scrollsToTop];
    [self.textView resignFirstResponder];
    WXAddProfile *model = [self.dataSource objectAtIndex:indexPath.item];
    if (model.isAddModel) {
        @weakify(self);
        if (self.dataSource.count > 1) {
            // 添加图片
            MNAssetPicker *picker = [MNAssetPicker picker];
            picker.configuration.allowsEditing = NO;
            picker.configuration.allowsPreviewing = NO;
            picker.configuration.allowsPickingGif = YES;
            picker.configuration.allowsPickingVideo = NO;
            picker.configuration.allowsPickingPhoto = YES;
            picker.configuration.allowsPickingLivePhoto = YES;
            picker.configuration.allowsOptimizeExporting = YES;
            picker.configuration.requestGifUseingPhotoPolicy = YES;
            picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
            picker.configuration.maxPickingCount = 10 - self.dataSource.count;
            [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
                [weakself didPickAssets:assets];
            } cancelHandler:nil];
        } else {
            // 添加视频
            NSString *s1 = @"拍摄";
            NSString *s2 = @"照片或视频";
            NSString *string = [NSString stringWithFormat:@"%@\n%@", s1, s2];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            [attributedString addAttribute:NSFontAttributeName value:UIFontWithNameSize(MNFontNameRegular, 17.f) range:[string rangeOfString:s1]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor.darkTextColor colorWithAlphaComponent:.85f] range:[string rangeOfString:s1]];
            [attributedString addAttribute:NSFontAttributeName value:UIFontWithNameSize(MNFontNameRegular, 12.f) range:[string rangeOfString:s2]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor.darkGrayColor colorWithAlphaComponent:.7f] range:[string rangeOfString:s2]];
            NSMutableParagraphStyle *style = NSMutableParagraphStyle.new;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:string.rangeOfAll];
            [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == actionSheet.cancelButtonIndex) return;
                MNAssetPickerType type = buttonIndex == 0 ? MNAssetPickerTypeCapturing : MNAssetPickerTypeNormal;
                MNAssetPicker *picker = [[MNAssetPicker alloc] initWithType:type];
                picker.configuration.maxPickingCount = 9;
                picker.configuration.maxCaptureDuration = 30.f;
                picker.configuration.allowsMixPicking = NO;
                picker.configuration.allowsPreviewing = NO;
                picker.configuration.allowsPickingGif = YES;
                picker.configuration.allowsPickingVideo = YES;
                picker.configuration.allowsPickingPhoto = YES;
                picker.configuration.allowsResizeVideoSize = NO;
                picker.configuration.allowsPickingLivePhoto = YES;
                picker.configuration.allowsOptimizeExporting = YES;
                picker.configuration.allowsMultiplePickingVideo = NO;
                picker.configuration.requestGifUseingPhotoPolicy = YES;
                picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
                picker.configuration.allowsEditing = type == MNAssetPickerTypeNormal;
                picker.configuration.exportURL = [NSURL fileURLWithPath:[WechatHelper.helper.momentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", NSString.identifier]]];
                [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
                    WXNewMomentController *vc = [[WXNewMomentController alloc] initWithAssets:assets];
                    [weakself.navigationController pushViewController:vc animated:YES];
                } cancelHandler:nil];
            } otherButtonTitles:attributedString.copy, @"从手机相册选择", nil] showInView:self.view];
        }
    } else {
        // 预览
        __block MNAsset *asset;
        NSMutableArray *assets = @[].mutableCopy;
        [self.dataSource enumerateObjectsUsingBlock:^(WXAddProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isAddModel) return;
            MNAsset *assetModel = [MNAsset new];
            assetModel.type = (MNAssetType)obj.type;
            assetModel.content = obj.content;
            assetModel.thumbnail = obj.image;
            assetModel.containerView = obj.containerView;
            if (obj == model) asset = assetModel;
            [assets addObject:assetModel];
        }];
        MNAssetBrowser *browser = [MNAssetBrowser new];
        browser.assets = assets;
        browser.allowsAutoPlaying = YES;
        browser.backgroundColor = UIColor.blackColor;
        [browser presentInView:self.view fromIndex:[assets indexOfObject:asset] animated:YES completion:nil];
    }
}

- (void)didPickAssets:(NSArray<MNAsset *> *)assets {
    if (assets.count <= 0) {
        [self.view showInfoDialog:@"获取资源出错"];
        return;
    }
    WXAddProfile *model = self.dataSource.lastObject;
    NSMutableArray <WXAddProfile *>*models = [NSMutableArray arrayWithCapacity:assets.count];
    [assets enumerateObjectsUsingBlock:^(MNAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [models addObject:[WXAddProfile modelWithAsset:obj]];
    }];
    [self.dataSource removeObject:model];
    [self.dataSource addObjectsFromArray:models];
    if (self.dataSource.count <= 0 || (self.dataSource.count < 9 && self.dataSource.lastObject.type == WXAddProfileTypeImage)) [self.dataSource addObject:model];
    if (self.dataSource.firstObject.type == WXAddProfileTypeVideo) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        layout.itemSize = [self itemSize];
    }
    [self reloadList];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    CGSize contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    self.collectionView.height_mn = contentSize.height;
    self.optionView.top_mn = self.collectionView.bottom_mn + WXNewMomentCollectionBottomMargin;
    [self updateContentSize];
}

- (void)layoutSubviewsUsingAnimation {
    CGSize contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    [UIView animateWithDuration:WXNewMomentCollectionAnimationDuration animations:^{
        self.collectionView.height_mn = contentSize.height;
        self.optionView.top_mn = self.collectionView.bottom_mn + WXNewMomentCollectionBottomMargin;
    } completion:^(BOOL finished) {
        [self updateContentSize];
    }];
}

- (void)updateContentSize {
    CGSize contentSize = self.scrollView.size_mn;
    contentSize.height = MAX(self.optionView.bottom_mn + MAX(35.f, MN_TAB_SAFE_HEIGHT + 30.f), self.scrollView.height_mn);
    self.scrollView.contentSize = contentSize;
}

#pragma mark - MNTextViewHandler
- (void)textView:(MNTextView *)textView fixedHeightSubscribeNext:(CGFloat)height {
    [UIView animateWithDuration:.2f animations:^{
        textView.height_mn += height;
        self.collectionView.top_mn = textView.bottom_mn + WXNewMomentCollectionTopMargin;
        self.optionView.top_mn = self.collectionView.bottom_mn + WXNewMomentCollectionBottomMargin;
    } completion:^(BOOL finished) {
        [self updateContentSize];
    }];
}

#pragma mark - MNEmojiKeyboardDelegate
- (void)emojiKeyboardDeleteButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == NSNotFound || (selectedRange.location + selectedRange.length) == 0) return;
    [self.textView deleteBackward];
}

- (void)emojiKeyboardReturnButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard {
    [self.textView resignFirstResponder];
}

- (void)emojiKeyboard:(MNEmojiKeyboard *)emojiKeyboard emojiButtonTouchUpInside:(MNEmoji *)emoji {
    if (emoji.type == MNEmojiTypeText) {
        [self.textView inputEmoji:emoji];
    }
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
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 53.f, 32.f)
                                              image:nil
                                              title:@"发表"
                                         titleColor:[UIColor whiteColor]
                                               titleFont:[UIFont systemFontOfSizes:16.f weights:.15f]];
    rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    /// 先检查数据模型, 为用户模型赋值
    @weakify(self);
    [self.view endEditing:YES];
    __block BOOL result = NO;
    [self.view showWechatDialogDelay:.3f eventHandler:^{
        WXMoment *moment = [WXMoment new];
        moment.uid = weakself.optionView.user.uid;
        moment.location = weakself.optionView.location.description;
        moment.privacy = weakself.optionView.isPrivacy;
        moment.content = weakself.textView.attributedText.emoji_plainText;
        moment.timestamp = weakself.optionView.timestamp;
        NSMutableArray <WXProfile *>*profiles = @[].mutableCopy;
        [weakself.dataSource enumerateObjectsUsingBlock:^(WXAddProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isAddModel) return;
            WXProfile *profile = [WXProfile pictureWithProfile:obj.content];
            profile.moment = moment.identifier;
            profile.timestamp = moment.timestamp;
            if (profile && [MNDatabase.database insertToTable:WXMomentProfileTableName model:profile]) {
                [profiles addObject:profile];
            }
        }];
        if (profiles.count) moment.type = profiles.lastObject.type == WXProfileTypeImage ? WXMomentTypePicture : WXMomentTypeVideo;
        if ([MNDatabase.database insertToTable:WXMomentTableName model:moment]) {
            result = YES;
            @PostNotify(WXMomentUpdateNotificationName, moment);
        }
    } completionHandler:^{
        if (result) {
            [weakself.navigationController popViewControllerAnimated:YES];
        } else {
            [weakself.view showWechatError:@"发布失败"];
        }
    }];
}

#pragma mark - Getter
- (MNEmojiKeyboard *)emojiKeyboard {
    if (!_emojiKeyboard) {
        MNEmojiKeyboard *emojiKeyboard = [[MNEmojiKeyboard alloc] initWithKeyboardHeight:MN_TAB_SAFE_HEIGHT + 265.f];
        emojiKeyboard.delegate = self;
        emojiKeyboard.configuration.allowsUseEmojiPackets = NO;
        emojiKeyboard.configuration.returnKeyColor = THEME_COLOR;
        emojiKeyboard.configuration.returnKeyTitleColor = UIColor.whiteColor;
        emojiKeyboard.configuration.returnKeyType = self.textView.returnKeyType;
        emojiKeyboard.configuration.separatorColor = [UIColor.darkTextColor colorWithAlphaComponent:.1f];
        _emojiKeyboard = emojiKeyboard;
    }
    return _emojiKeyboard;
}

#pragma mark - Super
- (MNListViewType)listViewType {
    return MNListViewTypeGrid;
}

- (__kindof UICollectionViewLayout *)collectionViewLayout {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 7.f;
    layout.minimumInteritemSpacing = 7.f;
    layout.itemSize = [self itemSize];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    return layout;
}

- (CGSize)itemSize {
    CGFloat interval = 7.f;
    CGFloat wh = floor((self.textView.width_mn - interval*2.f)/3.f);
    if (self.dataSource.lastObject.type == WXAddProfileTypeVideo) {
        CGSize naturalSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:self.dataSource.lastObject.content];
        if (naturalSize.width > naturalSize.height) {
            naturalSize = CGSizeMultiplyToWidth(naturalSize, WXNewMomentCollectionMaxWidth);
            naturalSize.height = floor(naturalSize.height);
            return naturalSize;
        } else if (naturalSize.height > naturalSize.width) {
            naturalSize = CGSizeMultiplyToHeight(naturalSize, WXNewMomentCollectionMaxHeight);
            naturalSize.width = floor(naturalSize.width);
            return naturalSize;
        }
    }
    return CGSizeMake(wh, wh);
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
