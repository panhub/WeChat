//
//  WXChangePasswordController.m
//  MNChat
//
//  Created by Vincent on 2019/8/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangePasswordController.h"
#import "WXDataValueModel.h"
#import "WXChangePasswordCell.h"

@interface WXChangePasswordController ()
@property (nonatomic, strong) NSArray <WXDataValueModel *> *dataArray;
@end

@implementation WXChangePasswordController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"设置微信密码";
    }
    return self;
}

- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = SEPARATOR_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 50.f;
    self.navigationBar.shadowView.hidden = YES;
    
    NSMutableAttributedString *string = @"设置微信密码后可以通过微信号/手机号/邮箱 + 微信密码登录微信".attributedString.mutableCopy;
    string.color = [[UIColor darkGrayColor] colorWithAlphaComponent:.67f];
    string.font = [UIFont systemFontOfSize:15.f];
    string.lineSpacing = 2.f;
    CGSize size = [string sizeOfLimitWidth:self.tableView.width_mn - 30.f];
    UILabel *headerLabel = [UILabel labelWithFrame:CGRectMake(15.f, 12.f, size.width, size.height) text:string.copy textColor:nil font:nil];
    headerLabel.numberOfLines = 0;
    UIView *headerView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(headerLabel.frame, UIEdgeInsetsMake(-headerLabel.top_mn, -headerLabel.left_mn, -17.f, -headerLabel.left_mn))];
    headerView.backgroundColor = VIEW_COLOR;
    [headerView addSubview:headerLabel];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /// 键盘变动通知
    @weakify(self);
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(id sender) {
        @strongify(self);
        [self keyboardWillChangeFrameNotification:sender];
    }];
}

- (void)loadData {
    NSArray <NSString *>*titles = @[@"微信号", @"旧密码", @"新密码", @"确认密码"];
    NSArray <NSString *>*descs = @[[[WXUser shareInfo] wechatId], @"请输入密码", @"请填写新的密码", @"请再次输入新密码"];
    NSMutableArray <WXDataValueModel *>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = obj;
        model.desc = descs[idx];
        [dataArray addObject:model];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXChangePasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.password.cell"];
    if (!cell) {
        cell = [[WXChangePasswordCell alloc] initWithReuseIdentifier:@"com.wx.password.cell" size:tableView.rowSize];
    }
    [cell setModel:self.dataArray[indexPath.row] row:indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
}

#pragma mark - UIKeyboardWillChangeFrameNotification
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    UIKeyboardWillChangeFrameConvert(notification, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
        if (to.origin.y < SCREEN_HEIGHT) {
            /// 弹起或改变高度
            __block NSInteger row = -1;
            [self.dataArray enumerateObjectsUsingBlock:^(WXDataValueModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([model.userInfo boolValue]) {
                    row = [self.dataArray indexOfObject:model];
                    *stop = YES;
                }
            }];
            if (row < 0) return;
            [self willBeginEditUserInfo:row keyboard:to];
        } else {
            [self willEndEditing];
        }
    });
}

- (void)willBeginEditUserInfo:(NSInteger)row keyboard:(CGRect)frame {
    if (row >= self.dataArray.count) return;
    CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    rect = [self.tableView convertRect:rect toViewOrWindow:nil];
    if (CGRectGetMaxY(rect) <= CGRectGetMinY(frame)) return;
    CGFloat delta = CGRectGetMinY(frame) - rect.origin.y - rect.size.height;
    [self.tableView setContentOffset:CGPointMake(0.f, self.tableView.contentOffset.y - delta) animated:NO];
}

- (void)willEndEditing {
    if (self.tableView.isDragging) return;
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat maxOffsetY = 0.f;
    if (self.tableView.contentSize.height > self.tableView.height_mn) {
        maxOffsetY = self.tableView.contentSize.height - self.tableView.height_mn;
    }
    if (offsetY > maxOffsetY) {
        [UIView animateWithDuration:.25f animations:^{
            self.tableView.contentOffset = CGPointMake(0.f, maxOffsetY);
        }];
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
                                              title:@"完成"
                                         titleColor:[UIColor whiteColor]
                                          titleFont:[UIFont systemFontOfSizes:16.f weights:.15f]];
    rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [self.view endEditing:YES];
    NSString *psd1 = self.dataArray[1].value;
    NSString *psd2 = self.dataArray[2].value;
    NSString *psd3 = self.dataArray[3].value;
    if (psd1.length < 5 || psd2.length < 5) {
        [self.contentView showInfoDialog:@"请输入至少5位数密码"];
        return;
    }
    if ([psd2 isEqualToString:psd1]) {
        [self.contentView showInfoDialog:@"新密码不可与旧密码相同"];
        return;
    }
    if (![psd2 isEqualToString:psd3]) {
        [self.contentView showInfoDialog:@"请确认密码是否一致"];
        return;
    }
    if (WXUser.shareInfo.password.length <= 0) {
        [self.contentView showInfoDialog:@"未发现密码存在"];
        return;
    }
    if (![psd1 isEqualToString:WXUser.shareInfo.password]) {
        [self.contentView showInfoDialog:@"旧密码输入错误"];
        return;
    }
    @weakify(self);
    [self.view showWeChatDialogDelay:.5f eventHandler:^{
        [WXUser performReplacingHandler:^(WXUser *userInfo) {
            userInfo.password = psd2;
        }];
    } completionHandler:^{
        @strongify(self);
        [self.view showCompletedDialog:@"密码已更新" completionHandler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

@end
