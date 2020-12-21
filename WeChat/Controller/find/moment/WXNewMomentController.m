//
//  WXNewMomentController.m
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXNewMomentController.h"
#import "WXAddMomentCollectionView.h"
#import "WXAddMomentTableView.h"
#import "WXMoment.h"

@interface WXNewMomentController ()<MNTextViewHandler, WXAddMomentCollectionViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MNEmojiTextView *textView;
@property (nonatomic, strong) WXAddMomentTableView *tableView;
@property (nonatomic, strong) WXAddMomentCollectionView *collectionView;
@end

@implementation WXNewMomentController
- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;

    MNEmojiTextView *textView = [[MNEmojiTextView alloc] initWithFrame:CGRectMake(22.f, 25.f, scrollView.width_mn - 44.f, 65.f)];
    textView.handler = self;
    textView.font = [UIFont systemFontOfSize:17.f];
    textView.tintColor = THEME_COLOR;
    textView.placeholder = @"这一刻的想法...";
    textView.expandHeight = 130.f;
    textView.placeholderColor = [[UIColor grayColor] colorWithAlphaComponent:.4f];
    textView.showsVerticalScrollIndicator = NO;
    textView.showsHorizontalScrollIndicator = NO;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;
    //textView.backgroundColor = [UIColor whiteColor];
    textView.enablesReturnKeyAutomatically = YES;
    textView.textContainerInset = UIEdgeInsetsZero;
    textView.textContainer.lineFragmentPadding = 0.f;
    if (@available(iOS 11.0, *)) {
        textView.textDragInteraction.enabled = NO;
    }
    [scrollView addSubview:textView];
    self.textView = textView;
    
    WXAddMomentCollectionView *collectionView = [[WXAddMomentCollectionView alloc] initWithFrame:CGRectMake(textView.left_mn, textView.bottom_mn + 30.f, textView.width_mn, 200.f)];
    collectionView.delegate = self;
    [scrollView addSubview:collectionView];
    self.collectionView = collectionView;
    
    WXAddMomentTableView *tableView = [[WXAddMomentTableView alloc] initWithFrame:CGRectMake(textView.left_mn, collectionView.bottom_mn + 90.f, textView.width_mn, 200.f) style:UITableViewStyleGrouped];
    [scrollView addSubview:tableView];
    self.tableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - MNTextViewHandler
- (void)textView:(MNTextView *)textView fixedHeightSubscribeNext:(CGFloat)height {
    [UIView animateWithDuration:.2f animations:^{
        textView.height_mn += height;
        self.collectionView.top_mn += height;
        self.tableView.top_mn += height;
    } completion:^(BOOL finished) {
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.height = MAX(self.tableView.bottom_mn + 20.f, self.scrollView.height_mn);
        self.scrollView.contentSize = contentSize;
    }];
}

#pragma mark - WXAddMomentCollectionViewDelegate
- (void)collectionViewDidChangeHeight:(WXAddMomentCollectionView *)collectionView {
    self.tableView.top_mn = 90.f/collectionView.rows + collectionView.bottom_mn;
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = MAX(self.tableView.bottom_mn + 20.f, self.scrollView.height_mn);
    self.scrollView.contentSize = contentSize;
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
    [self.view endEditing:YES];
    [self.view showWechatDialog];
    WXMoment *moment = [WXMoment new];
    moment.identifier = [MNFileHandle fileName];
    moment.uid = self.tableView.viewModel.owner.uid;
    moment.location = self.tableView.viewModel.dec;
    moment.privacy = self.tableView.viewModel.isPrivacy;
    moment.content = self.textView.attributedText.emoji_plainText;
    moment.timestamp = self.tableView.viewModel.timestamp;
    NSMutableString *imgs = @"".mutableCopy;
    [self.collectionView.images enumerateObjectsUsingBlock:^(UIImage *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 保存图片
        WXMomentPicture *pic = [[WXMomentPicture alloc] initWithImage:obj];
        if ([WechatHelper.helper.cache setObject:pic forKey:pic.identifier]) {
            if (imgs.length <= 0) {
                [imgs appendString:pic.identifier];
            } else {
                [imgs appendString:WXDataSeparatedSign];
                [imgs appendString:pic.identifier];
            }
        }
    }];
    moment.img = imgs.copy;
    [MNDatabase insertToTable:WXMomentTableName model:moment completion:nil];
    @PostNotify(WXMomentAddNotificationName, moment);
    dispatch_after_main(.5f, ^{
        [self.view closeDialogWithCompletionHandler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    });
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
