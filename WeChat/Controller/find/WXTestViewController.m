//
//  WXTestViewController.m
//  MNChat
//
//  Created by Vincent on 2019/4/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTestViewController.h"

@interface WXTestViewController ()

@end

@implementation WXTestViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"测试";
        self.pullRefreshEnabled = YES;
        self.loadMoreEnabled = YES;
    }
    return self;
}

- (void)initialized {
    [super initialized];
}

- (void)createView {
    [super createView];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 60.f;
    self.tableView.separatorColor = UIColorWithAlpha([UIColor darkTextColor], .1f);
}

- (void)beginPullRefresh {
    [self endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    if (!cell) {
        cell = [[MNTableViewCell alloc] initWithReuseIdentifier:@"123" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}




@end
