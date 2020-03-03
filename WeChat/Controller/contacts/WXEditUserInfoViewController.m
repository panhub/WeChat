//
//  WXEditUserInfoViewController.m
//  MNChat
//
//  Created by Vincent on 2019/3/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXEditUserInfoViewController.h"
#import "WXUser.h"
#import "WXDataValueModel.h"
#import "WXEditUserInfoCell.h"
#import "WXEditUserInfoHeaderView.h"
#import "WXEditUserInfoSectionHeaderView.h"

@interface WXEditUserInfoViewController ()
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, weak) WXEditUserInfoHeaderView *headerView;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataArray;
@end

@implementation WXEditUserInfoViewController
- (instancetype)initWithUser:(WXUser *)user {
    if (!user) return nil;
    if (self = [super init]) {
        self.user = user;
        self.title = @"设置备注和标签";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = VIEW_COLOR;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 48.f;
    
    WXEditUserInfoHeaderView *headerView = [[WXEditUserInfoHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    headerView.user = self.user;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)loadData {
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.title = @"微信号";
    model0.value = [NSString replacingBlankCharacter:_user.wechatId];
    model0.desc = @"设置微信号";
    model0.userInfo = @(UIKeyboardTypeNamePhonePad);
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"昵称";
    model1.value = [NSString replacingBlankCharacter:_user.nickname];
    model1.desc = @"设置昵称";
    model1.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"备注名";
    model2.value = [NSString replacingBlankCharacter:_user.notename];
    model2.desc = @"设置备注名";
    model2.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model3 = [WXDataValueModel new];
    model3.title = @"手机号码";
    model3.value = [NSString replacingBlankCharacter:_user.number];
    model3.desc = @"添加手机号码";
    model3.userInfo = @(UIKeyboardTypeNumberPad);
    WXDataValueModel *model4 = [WXDataValueModel new];
    model4.title = @"标签";
    model4.value = [NSString replacingBlankCharacter:_user.label];
    model4.desc = @"设置标签";
    model4.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model5 = [WXDataValueModel new];
    model5.title = @"描述";
    model5.value = [NSString replacingBlankCharacter:_user.desc];
    model5.desc = @"添加描述";
    model5.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model6 = [WXDataValueModel new];
    model6.title = @"地区";
    model6.value = [NSString replacingBlankCharacter:_user.location];
    model6.desc = @"设置地区";
    model6.userInfo = @(UIKeyboardTypeDefault);
    WXDataValueModel *model7 = [WXDataValueModel new];
    model7.title = @"性别";
    if (_user.gender == MNGenderUnknown) {
        model7.value = @"";
    } else {
        model7.value = _user.gender == MNGenderMale ? @"男" : @"女";
    }
    model7.desc = @"选择性别";
    model7.userInfo = @(UIKeyboardTypeDefault);
    self.dataArray = @[model0, model1, model2, model3, model4, model5, model6, model7];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 键盘变动通知
    @weakify(self);
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(id sender) {
        @strongify(self);
        [self keyboardWillChangeFrameNotification:sender];
    }];
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXEditUserInfoSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.edit.user.info.header"];
    if (!header) {
        header = [[WXEditUserInfoSectionHeaderView alloc] initWithReuseIdentifier:@"com.wx.edit.user.info.header"];
    }
    if (section >= self.dataArray.count) return header;
    WXDataValueModel *model = self.dataArray[section];
    header.titleLabel.text = model.title;
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.edit.user.info.footer"];
    if (!footer) {
        footer = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.edit.user.info.footer"];
        footer.contentView.backgroundColor = VIEW_COLOR;
    }
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXEditUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.edit.user.info.list.cell"];
    if (!cell) {
        cell = [[WXEditUserInfoCell alloc] initWithReuseIdentifier:@"com.wx.edit.user.info.list.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    WXDataValueModel *model = self.dataArray[indexPath.section];
    cell.model = model;
    cell.textField.userInteractionEnabled = (indexPath.section < (self.dataArray.count - 2));
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView endEditing:YES];
    if (indexPath.section == 6) {
        /// 地区
        @weakify(self);
        [MNCityPicker.new showInView:self.view selectHandler:^(MNCityPicker *picker) {
            @strongify(self);
            WXDataValueModel *model = self.dataArray[6];
            model.value = [NSString stringWithFormat:@"%@ %@", picker.province, picker.city];
            [self.tableView reloadSection:6 withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else if (indexPath.section == 7) {
        /// 性别
        @weakify(self);
        [[MNActionSheet actionSheetWithTitle:@"选择性别" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            @strongify(self);
            WXDataValueModel *model = self.dataArray[7];
            if (buttonIndex == 2) {
                model.value = @"";
            } else {
                model.value = buttonIndex ? @"女" : @"男";
            }
            [self.tableView reloadSection:7 withRowAnimation:UITableViewRowAnimationNone];
        } otherButtonTitles:@"男", @"女", @"保密", nil] show];
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
                                              titleFont:[UIFont systemFontOfSizes:17.f weights:.15f]];
    rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
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
    _user.wechatId = model0.value;
    _user.nickname = model1.value;
    _user.notename = model2.value;
    _user.number = model3.value;
    _user.label = model4.value;
    _user.desc = model5.value;
    _user.location = model6.value;
    if (kTransform(NSString *, model7.value).length <= 0) {
        _user.gender = MNGenderUnknown;
    } else {
        _user.gender = [model7.value isEqualToString:@"男"] ? MNGenderMale : MNGenderFemale;
    }
    if (self.headerView.headButton.selected) {
        UIImage *headImage = [self.headerView.headButton backgroundImageForState:UIControlStateSelected];
        _user.avatarData = headImage.JPEGData;
        [_user setValue:headImage forKey:@"avatar"];
    }
    /// 通知用户数据刷新
    @PostNotify(WXUserUpdateNotificationName, self.user);
    /// 优化体验
    dispatch_after_main(.5f, ^{
        [self.view closeDialog];
        dispatch_after_main(.1f, ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

#pragma mark - UIKeyboardWillChangeFrameNotification
- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
    UIKeyboardWillChangeFrameConvert(notification, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
        if (to.origin.y < SCREEN_HEIGHT) {
            /// 弹起或改变高度
            __block NSInteger section = -1;
            [self.dataArray enumerateObjectsUsingBlock:^(WXDataValueModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([model.user_info boolValue]) {
                    section = [self.dataArray indexOfObject:model];
                    *stop = YES;
                }
            }];
            if (section < 0) return;
            [self willBeginEditUserInfo:section keyboard:to];
        } else {
            [self willEndEditing];
        }
    });
}

- (void)willBeginEditUserInfo:(NSInteger)section keyboard:(CGRect)frame {
    if (section >= self.dataArray.count) return;
    CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
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

#pragma mark - controller config
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
