//
//  WXAppletResultController.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  小程序搜索

#import "WXAppletResultController.h"
#import "WXDataValueModel.h"
#import "WXAppletListCell.h"

@interface WXAppletResultController ()
@property (nonatomic, strong) NSMutableArray <WXDataValueModel *>*dataArray;
@end

@implementation WXAppletResultController
- (void)initialized {
    [super initialized];
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 52.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.applet.result.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.applet.result.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAppletListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.applet.result.cell"];
    if (!cell) {
        cell = [[WXAppletListCell alloc] initWithReuseIdentifier:@"com.wx.applet.result.cell" size:tableView.rowSize];
    }
    WXDataValueModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) return;
    WXDataValueModel *model = self.dataArray[indexPath.row];
    if (kTransform(NSString *, model.value).length > 0) {
        Class cls = NSClassFromString(model.value);
        if (!cls) return;
        UIViewControllerPush(model.value, YES);
    }
}

#pragma mark - MNSearchResultUpdating
- (void)updateSearchResultText:(NSString *)text forSearchController:(MNSearchViewController *)searchController {
    [self.dataArray removeAllObjects];
    if (text.length > 0) {
        [self.dataSource enumerateObjectsUsingBlock:^(WXDataValueModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.title containsString:text]) {
                [self.dataArray addObject:obj];
            }
        }];
    }
    [self reloadList];
}

- (void)reset {
    [self.dataArray removeAllObjects];
    [self reloadList];
}

#pragma mark - Super
- (BOOL)isChildViewController {
    return YES;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
