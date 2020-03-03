//
//  WXShakeHistoryController.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeHistoryController.h"
#import "WXShakeTVController.h"
#import "WXMusicPlayController.h"
#import "WXUserInfoViewController.h"
#import "WXShakeHistoryCell.h"
#import "WXShakeHistory.h"
#import "WXSong.h"
#import "WXUser.h"

@interface WXShakeHistoryController ()<MNTableViewCellDelegate>
@property (nonatomic, strong) NSMutableArray <WXShakeHistory *>*dataArray;
@end

@implementation WXShakeHistoryController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"摇到的历史";
    }
    return self;
}

- (void)createView {
    [super createView];
    // 创建视图
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = VIEW_COLOR;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.rowHeight = 64.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)loadData {
    @weakify(self);
    [self.dataArray removeAllObjects];
    [MNDatabase selectRowsModelFromTable:WXShakeHistoryTableName class:WXShakeHistory.class completion:^(NSArray<id> * _Nonnull rows) {
        dispatch_async_main(^{
            @strongify(self);
            [self.dataArray addObjectsFromArray:rows.reverseObjects];
            [self reloadList];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXShakeHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.shake.history.cell"];
    if (!cell) {
        cell = [[WXShakeHistoryCell alloc] initWithReuseIdentifier:@"com.wx.shake.history.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.delegate = self;
        cell.allowsEditing = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXShakeHistoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.history = self.dataArray[indexPath.row];
    cell.contentView.backgroundColor = indexPath.row == 0 ? UIColorWithSingleRGB(247.f) : UIColor.whiteColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEdit) [tableView endEditingWithAnimated:YES];
    if (self.dataArray.count <= indexPath.row) return;
    WXShakeHistory *history = [self.dataArray objectAtIndex:indexPath.row];
    if (history.type == WXShakeHistoryPerson) {
        WXUser *user = [WXUser userWithInfo:history.extend.JsonValue];
        if (user) {
            user.avatarData = history.thumbnailData;
            [user setValue:history.thumbnailImage forKey:kPath(user.avatar)];
            WXUserInfoViewController *vc = [[WXUserInfoViewController alloc] initWithUser:user];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.view showInfoDialog:@"数据错误"];
        }
    } else if (history.type == WXShakeHistoryMusic) {
        WXSong *song = [WXSong fetchSongWithTitle:history.extend.JsonString];
        if (song) {
            WXMusicPlayController *vc = [[WXMusicPlayController alloc] initWithSongs:@[song]];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.view showInfoDialog:@"未匹配到音乐"];
        }
    } else {
        WXShakeTVController *vc = WXShakeTVController.new;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - MNTableViewCellDelegate
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTableViewCellEditAction *action = [MNTableViewCellEditAction new];
    action.title = @"删除";
    action.inset = UIEdgeInsetWith(20.f);
    action.titleFont = [UIFont systemFontOfSize:17.f];
    action.style = MNTableViewCellEditingStyleDelete;
    return @[action];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.width_mn = cell.editingView.width_mn + 30.f;
    button.backgroundColor = R_G_B(253.f, 61.f, 48.f);
    [button setTitle:@"确认删除" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
    @weakify(self);
    [button handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        if (indexPath.row >= self.dataArray.count) {
            [cell endEditingUsingAnimation];
            return;
        }
        [self deleteHistoryAtIndexPath:indexPath];
    }];
    return button;
}

- (void)deleteHistoryAtIndexPath:(NSIndexPath *)indexPath {
    WXShakeHistory *history = self.dataArray[indexPath.row];
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    if (indexPath.row == 0 && self.dataArray.count > 0) {
        dispatch_after_main(.33f, ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    [self updateSubviews];
    [MNDatabase deleteRowFromTable:WXShakeHistoryTableName where:@{sql_field(history.date):history.date}.componentString completion:nil];
}

#pragma mark - 删除历史记录
- (void)updateSubviews {
    UIButton *rightBarItem = kTransform(UIButton *, self.navigationBar.rightBarItem);
    rightBarItem.enabled = self.dataArray.count > 0;
    if (self.dataArray.count > 0) {
        [self dismissEmptyView];
    } else {
        [self showEmptyViewNeed:YES image:nil message:@"暂时没有摇一摇记录" title:nil type:MNEmptyEventTypeReload];
        self.emptyView.backgroundColor = VIEW_COLOR;
    }
}

#pragma mark - Getter
- (NSMutableArray <WXShakeHistory *>*)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

#pragma mark - Overwrite
- (void)reloadList {
    [super reloadList];
    [self updateSubviews];
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

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
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"确定清空摇到的历史?" cancelButtonTitle:@"取消" handler:^(MNActionSheet *ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex) return;
        @weakify(self);
        [self.view showWeChatDialogDelay:.3f eventHandler:^{
            @strongify(self);
            [self.dataArray removeAllObjects];
            [self reloadList];
            [MNDatabase deleteRowFromTable:WXShakeHistoryTableName where:nil completion:nil];
        } completionHandler:nil];
    } otherButtonTitles:@"清空", nil];
    actionSheet.buttonTitleColor = BADGE_COLOR;
    [actionSheet show];
}

@end
