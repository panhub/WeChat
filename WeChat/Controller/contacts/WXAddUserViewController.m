//
//  WXAddUserViewController.m
//  WeChat
//
//  Created by Vincent on 2019/4/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddUserViewController.h"
#import "WXAddUserHeaderView.h"
#import "WXDataValueModel.h"
#import "WXAddUserInfoCell.h"
#import "WXEditUserInfoSectionHeaderView.h"

@interface WXAddUserViewController ()
@property (nonatomic, weak) WXAddUserHeaderView *headerView;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataArray;
@end

@implementation WXAddUserViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"添加联系人";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
    
    WXAddUserHeaderView *headerView = [[WXAddUserHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)loadData {
    if (self.dataArray.count > 0) return;
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.title = @"微信号";
    model0.value = @"";
    model0.desc = @"设置微信号";
    model0.userInfo = @(UIKeyboardTypeNamePhonePad);
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"昵称";
    model1.value = @"";
    model1.desc = @"设置昵称";
    model1.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"备注名";
    model2.value = @"";
    model2.desc = @"设置备注名";
    model2.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model3 = [WXDataValueModel new];
    model3.title = @"手机号";
    model3.value = @"";
    model3.desc = @"添加手机号码";
    model3.userInfo = @(UIKeyboardTypeNumberPad);
    WXDataValueModel *model4 = [WXDataValueModel new];
    model4.title = @"标签";
    model4.value = @"";
    model4.desc = @"设置标签";
    model4.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model5 = [WXDataValueModel new];
    model5.title = @"描述";
    model5.value = @"";
    model5.desc = @"添加描述";
    model5.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model6 = [WXDataValueModel new];
    model6.title = @"地区";
    model6.value = @"";
    model6.desc = @"选择地区";
    model6.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model7 = [WXDataValueModel new];
    model7.title = @"性别";
    model7.value = @"";
    model7.desc = @"选择性别";
    model7.userInfo = @(UIKeyboardTypeDefault);
    self.dataArray = @[model0, model1, model2, model3, model4, model5, model6, model7];
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

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXEditUserInfoSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.add.user.header"];
    if (!header) {
        header = [[WXEditUserInfoSectionHeaderView alloc] initWithReuseIdentifier:@"com.wx.add.user.header"];
        header.titleLabel.text = @"其它信息";
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAddUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.add.user.list.cell"];
    if (!cell) {
        cell = [[WXAddUserInfoCell alloc] initWithReuseIdentifier:@"com.wx.add.user.list.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    WXDataValueModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.textField.userInteractionEnabled = (indexPath.row < (self.dataArray.count - 2));
    if (indexPath.row == self.dataArray.count - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.right_mn, 0.f, 0.f);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView endEditing:YES];
    if (indexPath.row == 6) {
        /// 地区
        @weakify(self);
        [MNCityPicker.new showInView:self.view selectHandler:^(MNCityPicker *picker) {
            @strongify(self);
            WXDataValueModel *model = self.dataArray[6];
            model.value = [NSString stringWithFormat:@"%@ %@", picker.province, picker.city];
            [self.tableView reloadSection:6 withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else if (indexPath.row == 7) {
        /// 性别
        @weakify(self);
        MNActionSheet *ac = [MNActionSheet actionSheetWithTitle:@"选择性别" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            @strongify(self);
            WXDataValueModel *model = self.dataArray[7];
            if (buttonIndex == 2) {
                model.value = @"";
            } else {
                model.value = buttonIndex ? @"女" : @"男";
            }
            [self.tableView reloadSection:7 withRowAnimation:UITableViewRowAnimationNone];
        } otherButtonTitles:@"男", @"女", @"保密", nil];
        [ac setButtonTitleColor:MN_R_G_B(70.f, 182.f, 239.f) ofIndex:0];
        [ac setButtonTitleColor:MN_R_G_B(243.f, 126.f, 125.f) ofIndex:1];
        [ac setButtonTitleColor:TEXT_COLOR ofIndex:2];
        [ac show];
    }
}

#pragma mark - UIKeyboardWillChangeFrameNotification
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    UIKeyboardWillChangeFrameConvert(notification, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
        if (to.origin.y < MN_SCREEN_HEIGHT) {
            /// 弹起或改变高度
            __block NSInteger row = -1;
            [self.dataArray enumerateObjectsUsingBlock:^(WXDataValueModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([model.user_info boolValue]) {
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

#pragma mark - MNNavigationDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIView *rightBarItem = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 33.f)];
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
    [exitButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem addSubview:exitButton];
    rightBarItem.width_mn = exitButton.right_mn;
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [self.view endEditing:YES];
    if (rightBarItem.tag == 0) {
        [[MNActionSheet actionSheetWithTitle:@"确认添加联系人?" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            [self createContacts];
        } otherButtonTitles:@"确定", nil] show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)createContacts {
    /// 先检查数据模型, 为用户模型赋值
    [self.view endEditing:YES];
    [self.view showLoadDialog:@"请稍后"];
    WXDataValueModel *model0 = self.dataArray[0];
    if (kTransform(NSString *, model0.value).length < 6) {
        [self.view showInfoDialog:@"微信号不合法"];
        return;
    }
    WXDataValueModel *model1 = self.dataArray[1];
    WXDataValueModel *model2 = self.dataArray[2];
    if (kTransform(NSString *, model1.value).length <= 0 && kTransform(NSString *, model2.value).length <= 0) {
        [self.view showInfoDialog:@"昵称或备注名不合法"];
        return;
    }
    WXDataValueModel *model3 = self.dataArray[3];
    WXDataValueModel *model4 = self.dataArray[4];
    WXDataValueModel *model5 = self.dataArray[5];
    WXDataValueModel *model6 = self.dataArray[6];
    WXDataValueModel *model7 = self.dataArray[7];
    WXUser *user = [WXUser new];
    user.wechatId = model0.value;
    user.nickname = model1.value;
    user.notename = model2.value;
    user.phone = model3.value;
    user.label = model4.value;
    user.desc = model5.value;
    user.location = model6.value;
    if (kTransform(NSString *, model7.value).length > 0) {
        user.gender = [model7.value isEqualToString:@"男"] ? WechatGenderMale : WechatGenderFemale;
    }
    user.uid = [NSDate shortTimestamps];
    if (self.headerView.headButton.selected) {
        [user setValue:[self.headerView.headButton backgroundImageForState:UIControlStateSelected] forKey:kPath(user.avatar)];
    } else {
        [user setValue:[WechatHelper avatar] forKey:kPath(user.avatar)];
    }
    user.avatarString = user.avatar.PNGData.base64EncodedString;
    if ([[WechatHelper helper] insertUserToContacts:user]) {
        [self.view closeDialog];
        dispatch_after_main(.1f, ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } else {
        [self.view showInfoDialog:@"添加联系人失败"];
    }
}

#pragma mark - controller config
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
