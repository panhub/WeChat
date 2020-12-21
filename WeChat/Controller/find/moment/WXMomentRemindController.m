//
//  WXMomentRemindController.m
//  MNChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXMomentRemindController.h"
#import "WXMomentProfileViewModel.h"
#import "WXMomentRemindViewModel.h"
#import "WXMomentRemindCell.h"

@interface WXMomentRemindController ()<MNTableViewCellDelegate>
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) WXMomentProfileViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray <WXMomentRemindViewModel *>*dataArray;
@end

@implementation WXMomentRemindController
- (instancetype)initWithViewModel:(WXMomentProfileViewModel *)viewModel {
    if (self = [super init]) {
        self.title = @"消息";
        self.viewModel = viewModel;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = VIEW_COLOR;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = WXMomentRemindCellHeight;
}

- (void)loadData {
    dispatch_async_default(^{
        NSArray <WXMomentRemind *>*rows = [[MNDatabase database] selectRowsModelFromTable:WXMomentRemindTableName class:WXMomentRemind.class];
        NSMutableArray <WXMomentRemindViewModel *>*dataArray = [NSMutableArray arrayWithCapacity:rows.count];
        [rows.reversedArray enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WXMomentRemindViewModel *model = [[WXMomentRemindViewModel alloc] initWithModel:obj];
            if (model) [dataArray addObject:model];
        }];
        self.dataArray = dataArray.mutableCopy;
        dispatch_async_main(^{
            UIButton *rightBarItem = kTransform(UIButton *, self.navigationBar.rightBarItem);
            rightBarItem.enabled = self.dataArray.count > 0;
            [self reloadList];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMomentRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.moment.remind.cell"];
    if (!cell) {
        cell = [[WXMomentRemindCell alloc] initWithReuseIdentifier:@"com.moment.remind.cell" size:tableView.rowSize];
        cell.editDelegate = self;
        cell.allowsEditing = YES;
    }
    cell.viewModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEdit) [tableView endEditingWithAnimated:YES];
}

#pragma mark - MNTableViewCellDelegate
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTableViewCellEditAction *action = [MNTableViewCellEditAction new];
    action.title = @"删除";
    action.inset = UIEdgeInsetWith(20.f);
    action.titleFont = [UIFont systemFontOfSize:18.f];
    action.style = MNTableViewCellEditingStyleDelete;
    return @[action];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.width_mn = cell.editingView.width_mn + 30.f;
    button.backgroundColor = MN_R_G_B(253.f, 61.f, 48.f);
    [button setTitle:@"确认删除" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
    @weakify(self);
    [button handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        /// 删除
        @strongify(self);
        if (indexPath.row >= self.dataArray.count) {
            [cell endEditingUsingAnimation];
            return;
        }
        [self deleteRemindAtIndexPath:indexPath];
    }];
    return button;
}

#pragma mark - 删除提醒事项
- (void)deleteRemindAtIndexPath:(NSIndexPath *)indexPath {
    WXMomentRemindViewModel *viewModel = self.dataArray[indexPath.row];
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [MNDatabase deleteRowFromTable:WXMomentRemindTableName where:[@{@"identifier":viewModel.model.identifier} componentString] completion:nil];
    if (self.dataArray.count <= 0) {
        self.tableView.tableFooterView = nil;
        kTransform(UIButton *, self.navigationBar.rightBarItem).enabled = NO;
    }
    __block WXMomentRemind *remind = nil;
    [self.viewModel.reminds enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:viewModel.model.identifier]) {
            remind = obj;
            *stop = YES;
        }
    }];
    if (!remind) return;
    [self.viewModel.reminds removeObject:remind];
    if (self.didDeleteRemindHandler) {
        self.didDeleteRemindHandler();
    }
}

- (void)deleteAllReminds {
    [self.dataArray removeAllObjects];
    [self.viewModel.reminds removeAllObjects];
    [self reloadList];
    [MNDatabase deleteRowFromTable:WXMomentRemindTableName where:nil completion:nil];
    if (self.didDeleteRemindHandler) {
        self.didDeleteRemindHandler();
    }
}

#pragma mark - Super
- (void)reloadList {
    [super reloadList];
    if (self.dataArray.count) {
        self.tableView.tableFooterView = self.footerView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)
                                            image:nil
                                              title:@"清空"
                                         titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                          titleFont:UIFontRegular(17.f)];
    [rightItem setTitleColor:UIColorWithAlpha([UIColor grayColor], .5f) forState:UIControlStateDisabled];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"清空后将退出消息" cancelButtonTitle:@"取消" handler:^(MNActionSheet *ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex) return;
        @weakify(self);
        [self.view showWechatDialogDelay:.3f eventHandler:^{
            @strongify(self);
            UIButton *rightItem = kTransform(UIButton *, rightBarItem);
            rightItem.enabled = NO;
            [self deleteAllReminds];
        } completionHandler:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } otherButtonTitles:@"删除所有消息", nil];
    actionSheet.buttonTitleColor = BADGE_COLOR;
    [actionSheet show];
}

#pragma mark - Getter
- (UIView *)footerView {
    if (!_footerView) {
        UILabel *footerLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 55.f)
                                                  text:@"查看更早的消息..."
                                         alignment:NSTextAlignmentCenter
                                             textColor:UIColorWithAlpha([UIColor darkTextColor], .7f)
                                                  font:UIFontRegular(14.f)];
        UIImageView *separator = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        [footerLabel addSubview:separator];
        separator.sd_layout
        .leftEqualToView(footerLabel)
        .rightEqualToView(footerLabel)
        .bottomEqualToView(footerLabel)
        .heightIs(WXMomentSeparatorHeight);
        _footerView = footerLabel;
    }
    return _footerView;
}

@end
