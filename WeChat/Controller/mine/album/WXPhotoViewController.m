//
//  WXPhotoViewController.m
//  WeChat
//
//  Created by Vicent on 2021/4/22.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXPhotoViewController.h"
#import "WXEditingViewController.h"
#import "WXPhotoCell.h"
#import "MNAssetScrollView.h"
#import "WXPhotoTitleView.h"
#import "WXPhotoTabView.h"
#import "WXPhotoContentView.h"
#import "WXMoment.h"
#import "WXPhotoTipButton.h"

#define WXPhotoCellInteritemSpacing 14.f
#define WXPhotoDismissAnimationDuration .46f

@interface WXPhotoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL WXPhotoStatusBarHidden;
}
// 展示的索引
@property (nonatomic) NSInteger displayIndex;
// 图片集合
@property (nonatomic, strong) NSMutableArray <WXProfile *>*photos;
// 标题视图
@property (nonatomic, strong) WXPhotoTitleView *titleView;
// 底部控制
@property (nonatomic, strong) WXPhotoTabView *timelineBar;
// 交互起始位置记录
@property (nonatomic) CGRect interactiveFrame;
// 是否允许交互时缩小效果
@property (nonatomic, getter=isAllowsZoomInteractive) BOOL allowsZoomInteractive;
// 交互视图
@property (nonatomic, strong) UIImageView *interactiveView;
// 内容展示
@property (nonatomic, strong) WXPhotoContentView *contentLabel;
// 图片展示 
@property (nonatomic, strong) UICollectionView *collectionView;
// 背景展示
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation WXPhotoViewController
- (instancetype)initWithPhotos:(NSArray <WXProfile *>*)photos startIndex:(NSInteger)startIndex {
    if (self = [super init]) {
        self.displayIndex = startIndex;
        self.photos = photos.mutableCopy;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    // 导航
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = MN_RGB(23.f);
    
    self.contentView.backgroundColor = UIColor.blackColor;
    
    // 背景
    UIImageView *backgroundImageView = [UIImageView imageViewWithFrame:self.view.bounds image:nil];
    backgroundImageView.userInteractionEnabled = NO;
    backgroundImageView.backgroundColor = UIColor.clearColor;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:backgroundImageView atIndex:0];
    self.backgroundImageView = backgroundImageView;
    
    // 图片展示
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = WXPhotoCellInteritemSpacing;
    layout.minimumInteritemSpacing = 0.f;
    layout.sectionInset = UIEdgeInsetsMake(0.f, WXPhotoCellInteritemSpacing/2.f, 0.f, WXPhotoCellInteritemSpacing/2.f);
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = self.contentView.size_mn;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(0.f, -WXPhotoCellInteritemSpacing/2.f, 0.f, -WXPhotoCellInteritemSpacing/2.f)) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.pagingEnabled = YES;
    collectionView.delaysContentTouches = NO;
    collectionView.canCancelContentTouches = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = UIColor.blackColor;
    [collectionView adjustContentInset];
    [collectionView registerClass:[WXPhotoCell class]
       forCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier];
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView reloadData];
    [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.displayIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                   animated:NO];
    
    UIImageView *interactiveView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
    interactiveView.hidden = YES;
    interactiveView.clipsToBounds = YES;
    interactiveView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:interactiveView];
    self.interactiveView = interactiveView;
    
    WXPhotoTabView *timelineBar = [[WXPhotoTabView alloc] initWithFrame:self.view.bounds];
    timelineBar.bottom_mn = self.view.height_mn;
    [timelineBar addLikeTargetForTouchEvent:self action:@selector(like:)];
    [timelineBar addDetailTargetForTouchEvent:self action:@selector(detail:)];
    [timelineBar addCommentTargetForTouchEvent:self action:@selector(comment:)];
    [self.view addSubview:timelineBar];
    self.timelineBar = timelineBar;
    
    WXPhotoContentView *contentLabel = [[WXPhotoContentView alloc] initWithFrame:self.view.bounds];
    contentLabel.bottom_mn = timelineBar.top_mn - 2.f;
    [self.view addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    [self updateCurrentPicture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 交互事件
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    //doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    //singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
    //pan.delegate = self;
    [self.contentView addGestureRecognizer:pan];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self cellForItemAtCurrentDisplayIndex] didBeginDisplaying];
    [UIApplication.sharedApplication setStatusBarHidden:WXPhotoStatusBarHidden withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self cellForItemAtCurrentDisplayIndex] endDisplaying];
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Event
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    __weak typeof(self) weakself = self;
    WXPhotoStatusBarHidden = !UIApplication.sharedApplication.isStatusBarHidden;
    //self.navigationBar.hidden = WXPhotoStatusBarHidden;
    [UIApplication.sharedApplication setStatusBarHidden:WXPhotoStatusBarHidden withAnimation:UIStatusBarAnimationNone];
    CGFloat margin = self.timelineBar.top_mn - self.contentLabel.bottom_mn;
    [UIView animateWithDuration:.15f animations:^{
        weakself.navigationBar.alpha = WXPhotoStatusBarHidden ? 0.f : 1.f;
    }];
    [UIView animateWithDuration:UIApplication.sharedApplication.statusBarOrientationAnimationDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakself.timelineBar.top_mn = weakself.view.height_mn - (WXPhotoStatusBarHidden ? 0.f : weakself.timelineBar.height_mn);
        weakself.contentLabel.bottom_mn = weakself.timelineBar.top_mn - margin;
    } completion:nil];
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
    WXPhotoCell *cell = [self cellForItemAtCurrentDisplayIndex];
    if (cell.scrollView.zoomScale > 1.f) {
        [cell.scrollView setZoomScale:1.f animated:YES];
    } else {
        CGPoint location = [recognizer locationInView:cell.scrollView.contentView];
        if (!CGRectContainsPoint(cell.scrollView.contentView.bounds, location)) return;
        CGFloat scale = cell.scrollView.maximumZoomScale;
        CGFloat xsize = cell.scrollView.width_mn/scale;
        CGFloat ysize = cell.scrollView.height_mn/scale;
        [cell.scrollView zoomToRect:CGRectMake(location.x - xsize/2.f, location.y - ysize/2.f, xsize, ysize) animated:YES];
    }
}

- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            WXPhotoCell *cell = [self cellForItemAtCurrentDisplayIndex];
            if (cell.scrollView.zoomScale > 1.f) return;
        
            CGPoint point = [recognizer locationInView:cell.scrollView.contentView];
            if (!CGRectContainsPoint(cell.scrollView.contentView.bounds, point)) return;
            
            [cell endDisplaying];
            
            self.interactiveView.image = cell.picture.image;
            self.interactiveView.frame = [cell.scrollView.contentView.superview convertRect:cell.scrollView.contentView.frame toView:self.contentView];
            self.interactiveFrame = self.interactiveView.frame;
            
            self.allowsZoomInteractive = self.interactiveView.height_mn <= self.collectionView.height_mn;
            
            self.interactiveView.hidden = NO;
            self.collectionView.hidden = YES;
            
            [self makePhotoBarVisible:NO];
            
        } break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.interactiveView.isHidden) return;
            
            CGPoint translation = [recognizer translationInView:self.contentView];
            [recognizer setTranslation:CGPointZero inView:self.contentView];
            
            CGPoint center = self.interactiveView.center_mn;
            center.y += translation.y;
            
            if (self.isAllowsZoomInteractive) {
                
                if (center.y <= 0.f || center.y >= self.contentView.height_mn) return;
                
                center.x += translation.x;
                
                CGFloat minZoomScale = .3f;
                CGFloat scale = fabs(self.contentView.height_mn/2.f - center.y)/(self.contentView.height_mn/2.f);
                scale = (1.f - scale*(1.f - minZoomScale));
                
                CGRect frame = self.interactiveFrame;
                frame.size.width = frame.size.width*scale;
                //frame.size.width = ceil(frame.size.width);
                frame.size.height = frame.size.height*scale;
                //frame.size.height = ceil(frame.size.height);
                frame.origin.x = center.x - frame.size.width/2.f;
                frame.origin.x = MIN(MAX(0.f, frame.origin.x), self.contentView.width_mn - frame.size.width);
                frame.origin.y = center.y - frame.size.height/2.f;
                
                self.interactiveView.frame = frame;
                
                CGFloat alpha = center.y <= self.contentView.height_mn/2.f ? 1.f : scale;
                self.contentView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:alpha];
                
            } else {
                self.interactiveView.center_mn = center;
                self.interactiveView.top_mn = MIN(self.contentView.height_mn, MAX(-self.interactiveView.height_mn/2.f, self.interactiveView.top_mn));
            }
            
        } break;
        case UIGestureRecognizerStateCancelled:
        {
            if (self.interactiveView.isHidden) return;
            
            [self makePhotoBarVisible:YES];
            
            [self cancelInteractive];
            
        } break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.interactiveView.isHidden) return;
            
            if (ceil(self.interactiveView.centerY_mn) >= floor(self.contentView.height_mn/4.f*3.f)) {
                [self dismiss];
            } else {
                [self cancelInteractive];
                [self makePhotoBarVisible:YES];
            }
        } break;
            
        default:
            break;
    }
}

- (void)makePhotoBarVisible:(BOOL)isVisible {
    @weakify(self);
    CGFloat alpha = isVisible ? 1.f : 0.f;
    if (self.timelineBar.alpha == alpha) return;
    [UIView animateWithDuration:.15f animations:^{
        weakself.timelineBar.alpha = alpha;
        weakself.contentLabel.alpha = alpha;
        weakself.contentView.backgroundColor = UIColor.blackColor;
        weakself.navigationBar.alpha = (alpha == 1.f ? (WXPhotoStatusBarHidden ? 0.f : 1.f) : alpha);
    }];
}

- (void)cancelInteractive {
    @weakify(self);
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakself.interactiveView.frame = weakself.interactiveFrame;
    } completion:^(BOOL finished) {
        weakself.collectionView.hidden = NO;
        weakself.interactiveView.hidden = YES;
        weakself.view.userInteractionEnabled = YES;
        [[weakself cellForItemAtCurrentDisplayIndex] didBeginDisplaying];
    }];
}

- (void)dismiss {
    @weakify(self);
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakself.contentView.backgroundColor = UIColor.clearColor;
        weakself.interactiveView.top_mn = weakself.contentView.height_mn;
    } completion:^(BOOL finished) {
        weakself.view.userInteractionEnabled = YES;
        [weakself.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:MNCollectionElementCellReuseIdentifier forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(WXPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell didEndDisplaying];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WXPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.picture = self.photos[indexPath.item];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate || scrollView.isDragging || scrollView.isDecelerating) return;
    [self updateCurrentPageIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPageIfNeeded];
}

#pragma mark - Update
- (void)updateCurrentPageIfNeeded {
    NSInteger currentPageIndex = self.collectionView.contentOffset.x/self.collectionView.width_mn;
    if (currentPageIndex == self.displayIndex) return;
    self.displayIndex = currentPageIndex;
    [[self cellForItemAtCurrentDisplayIndex] didBeginDisplaying];
    [self updateCurrentPicture];
}

- (void)updateCurrentPicture {
    self.titleView.profile = self.timelineBar.profile = self.contentLabel.profile = self.photos[self.displayIndex];
}

#pragma mark - Event
- (void)like:(WXPhotoTipButton *)sender {
    WXProfile *profile = self.timelineBar.profile;
    NSArray <WXMoment *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName where:@{sql_field(profile.identifier):sql_pair(profile.moment)}.sqlQueryValue limit:NSRangeZero class:WXMoment.class];
    if (rows.count <= 0) return;
    WXMoment *moment = rows.firstObject;
    NSArray <WXLike *>*likes = [moment.likes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", WXUser.shareInfo.uid]];
    if (likes.count) {
        // 删除点赞
        WXLike *like = likes.firstObject;
        if ([MNDatabase.database deleteRowFromTable:WXMomentLikeTableName where:@{sql_field(like.uid):sql_pair(like.uid)}.sqlQueryValue]) {
            [moment.likes removeObject:like];
            [self.timelineBar update];
        }
    } else {
        // 添加点赞
        WXLike *like = [[WXLike alloc] initWithUid:WXUser.shareInfo.uid];
        like.moment = moment.identifier;
        if ([MNDatabase.database insertToTable:WXMomentLikeTableName model:like]) {
            [self.timelineBar update];
            [self.timelineBar startLikeAnimation];
        }
    }
}

- (void)comment:(WXPhotoTipButton *)sender {
    @weakify(self);
    WXEditingViewController *vc = [WXEditingViewController new];
    vc.title = @"评论内容";
    vc.numberOfLines = 5;
    vc.keyboardType = UIKeyboardTypeDefault;
    vc.placeholder = @"";
    vc.numberOfWords = 100;
    vc.minOfWordInput = 1;
    vc.shieldCharacters = @[@"\n", @"\r"];
    vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
        WXComment *comment = WXComment.new;
        comment.identifier = NSDate.shortTimestamps;
        comment.from_uid = WXUser.shareInfo.uid;
        comment.content = result;
        comment.timestamp = NSDate.timestamps;
        comment.moment = weakself.titleView.profile.moment;
        if ([MNDatabase.database insertToTable:WXMomentCommentTableName model:comment]) {
            [weakself.timelineBar update];
        }
        [v.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)detail:(WXPhotoTipButton *)sender {
    
}

#pragma mark - Setter
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.view.backgroundColor = self.view.backgroundColor;
    self.backgroundImageView.image = backgroundImage;
}

#pragma mark - Getter
- (WXPhotoCell *)cellForItemAtCurrentDisplayIndex {
    return (WXPhotoCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.displayIndex inSection:0]];
}

#pragma mark - Navigation
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftBarItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    leftBarItem.touchInset = UIEdgeInsetWith(-5.f);
    leftBarItem.backgroundImage = [[UIImage imageNamed:@"wx_common_back_white"] imageWithColor:MN_RGB(206.f)];
    [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftBarItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightBarItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    rightBarItem.touchInset = UIEdgeInsetWith(-5.f);
    rightBarItem.backgroundImage = [[UIImage imageNamed:@"wx_common_more_white"] imageWithColor:MN_RGB(206.f)];
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet * _Nonnull ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex) return;
        if (buttonIndex == 0) {
            if ([weakself.user.uid isEqualToString:WXUser.shareInfo.uid]) {
                // 删除
                [weakself del];
            } else {
                // 保存
                [weakself save];
            }
        } else {
            // 保存
            [weakself save];
        }
    } otherButtonTitles:([self.user.uid isEqualToString:WXUser.shareInfo.uid] ? @"删除" : @"保存至相册"), ([self.user.uid isEqualToString:WXUser.shareInfo.uid] ? @"保存至相册" : nil), nil];
    if ([self.user.uid isEqualToString:WXUser.shareInfo.uid]) [actionSheet setButtonTitleColor:BADGE_COLOR ofIndex:0];
    [actionSheet showInView:self.view];
}

- (void)save {
    @weakify(self);
    [self.view showActivityDialog:@"请稍后"];
    WXProfile *picture = self.photos[self.displayIndex];
    [MNAssetHelper writeAssets:@[picture.content] toAlbum:nil completion:^(NSArray<NSString *> * _Nullable identifiers, NSError * _Nullable error) {
        if (identifiers.count && !error) {
            [weakself.view showWechatComplete:@"已保存至系统相册"];
        } else {
            [weakself.view showWechatError:@"保存失败"];
        }
    }];
}

- (void)del {
    @weakify(self);
    WXProfile *picture = self.photos[weakself.displayIndex];
    [self.view showWechatDialogDelay:.5f eventHandler:^{
        [[weakself cellForItemAtCurrentDisplayIndex] endDisplaying];
        @PostNotify(WXAlbumPictureDeleteNotificationName, picture);
        [weakself del:picture];
    } completionHandler:^{
        if (weakself.photos.count <= 1) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)del:(WXProfile *)photo {
    // 更新朋友圈
    NSArray <WXMoment *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName where:@{sql_field(photo.identifier):sql_pair(photo.moment)}.sqlQueryValue limit:NSRangeZero class:WXMoment.class];
    if (rows.count <= 0) return;
    WXMoment *moment = rows.firstObject;
    [moment.profiles.copy enumerateObjectsUsingBlock:^(WXProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToProfile:photo]) {
            [obj removeContentsAtFile];
            [MNDatabase.database deleteRowFromTable:WXMomentProfileTableName where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue];
            [moment.profiles removeObject:obj];
            *stop = YES;
        }
    }];
    if (moment.profiles.count <= 0 && moment.content.length <= 0) {
        // 删除朋友圈及相关数据
        [MNDatabase.database deleteRowFromTable:WXMomentProfileTableName where:@{sql_field(photo.moment):sql_pair(moment.identifier)}.sqlQueryValue];
        [MNDatabase.database deleteRowFromTable:WXMomentLikeTableName
                                  where:@{sql_field(photo.moment):sql_pair(moment.identifier)}.sqlQueryValue];
        [MNDatabase.database deleteRowFromTable:WXMomentCommentTableName
                                  where:@{sql_field(photo.moment):sql_pair(moment.identifier)}.sqlQueryValue];
        [MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName where:@{sql_field(photo.moment):sql_pair(moment.identifier)}.sqlQueryValue];
        [MNDatabase.database deleteRowFromTable:WXMomentTableName
                                  where:@{sql_field(moment.identifier):sql_pair(moment.identifier)}.sqlQueryValue];
    } else {
        // 更新朋友圈
        if (moment.profiles.count <= 0) moment.type = WXMomentTypeWord;
        [MNDatabase.database updateTable:WXMomentTableName where:@{sql_field(moment.identifier):sql_pair(moment.identifier)}.sqlQueryValue model:moment];
    }
    // 更新视图
    if (self.photos.count <= 1) return;
    [[self cellForItemAtCurrentDisplayIndex] didEndDisplaying];
    NSInteger nextDisplayIndex = self.displayIndex + ((self.displayIndex <= self.photos.count - 2) ? 1 : -1);
    // 记录当前图片 删除指定图片
    WXProfile *picture = self.photos[nextDisplayIndex];
    [self.photos removeObject:photo];
    self.displayIndex = [self.photos indexOfObject:picture];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.displayIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                   animated:NO];
    [self updateCurrentPicture];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.15f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self cellForItemAtCurrentDisplayIndex] didBeginDisplaying];
    });
}

- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar {
    WXPhotoTitleView *titleView = [[WXPhotoTitleView alloc] initWithFrame:CGRectMake(0.f, 0.f, navigationBar.rightBarItem.left_mn - navigationBar.leftBarItem.right_mn, MN_NAV_BAR_HEIGHT)];
    titleView.centerX_mn = navigationBar.width_mn/2.f;
    titleView.bottom_mn = navigationBar.height_mn;
    [navigationBar addSubview:titleView];
    self.titleView = titleView;
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
