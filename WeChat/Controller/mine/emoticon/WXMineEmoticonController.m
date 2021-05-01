//
//  WXMineEmoticonController.m
//  WeChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineEmoticonController.h"
#import "WXDataValueModel.h"
#import "WXMineEmoticonCell.h"
#import "WXEmoticonPreviewController.h"

@interface WXMineEmoticonController ()<MNSegmentSubpageDataSource>

@end

@implementation WXMineEmoticonController
- (void)createView {
    [super createView];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 65.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    [self handNotification:WXEmoticonStateDidChangeNotificationName eventHandler:^(NSNotification *notification) {
        @strongify(self);
        if (self.isAppear) {
            if ([notification.object isKindOfClass:NSIndexPath.class]) {
                [self.tableView reloadRowAtIndexPath:notification.object withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [self reloadList];
            }
        } else {
            [self setNeedsReloadList];
        }
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[MNEmojiManager defaultManager] packets] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMineEmoticonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.mine.emoticon.cell"];
    if (!cell) {
        cell = [[WXMineEmoticonCell alloc] initWithReuseIdentifier:@"com.wx.mine.emoticon.cell" size:tableView.rowSize];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXMineEmoticonCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= MNEmojiManager.defaultManager.packets.count) return;
    cell.packet = [[MNEmojiManager defaultManager] packets][indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= MNEmojiManager.defaultManager.packets.count) return;
    MNEmojiPacket *packet = [[MNEmojiManager defaultManager] packets][indexPath.row];
    WXEmoticonPreviewController *vc = [[WXEmoticonPreviewController alloc] initWithPacket:packet];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNSegmentSubpageDataSource
- (UIScrollView *)segmentSubpageScrollView {
    return self.listView;
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
