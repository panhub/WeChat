//
//  WXUserMoreController.m
//  WeChat
//
//  Created by Vicent on 2021/5/1.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXUserMoreController.h"
#import "WXUser.h"
#import "WXDataValueModel.h"
#import "WXDataValueCell.h"

@interface WXUserMoreController ()
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataSource;
@end

@implementation WXUserMoreController
- (instancetype)initWithUser:(WXUser *)user {
    if (!user) return nil;
    if (self = [super init]) {
        self.title = @"朋友权限";
        self.user = user;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.rowHeight = 55.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = VIEW_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSMutableArray <WXDataValueModel *>*dataSource = @[].mutableCopy;
    WXDataValueModel *model = [WXDataValueModel new];
    model.title = @"个性签名";
    model.desc = self.user.signature ? : @"";
    [dataSource addObject:model];
    if (![self.user isEqualToUser:WXUser.shareInfo]) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = @"来源";
        model.desc = self.user.desc ? : @"通过微信号查找";
        [dataSource addObject:model];
    }
    self.dataSource = dataSource.copy;
    [self reloadList];
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.user.info.more.cell"];
    if (!cell) {
        cell = [[WXDataValueCell alloc] initWithReuseIdentifier:@"com.wx.user.info.more.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.imgView.hidden = YES;
        cell.switchButton.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull WXDataValueCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    cell.model = self.dataSource[indexPath.row];
    cell.detailLabel.right_mn = cell.imgView.centerX_mn;
    if (indexPath.row == self.dataSource.count - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
}

@end
