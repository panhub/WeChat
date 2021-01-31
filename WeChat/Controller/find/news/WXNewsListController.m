//
//  WXNewsListController.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsListController.h"
#import "WXNewsCategory.h"
#import "WXNewsDataModel.h"
#import "WXNewsViewModel.h"
#import "WXNewsRequest.h"
#import "WXNewsCell.h"

@interface WXNewsListController ()<MNSegmentSubpageDataSource>
//@property (nonatomic, )
@end

@implementation WXNewsListController
- (instancetype)initWithFrame:(CGRect)frame category:(WXNewsCategory *)category {
    if (self = [super initWithFrame:frame]) {
        WXNewsRequest *request = WXNewsRequest.new;
        request.type = category.type;
        self.httpRequest = request;
        self.loadMoreEnabled = YES;
        self.pullRefreshEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDataSource &  UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.httpRequest.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXNewsViewModel *vm = self.httpRequest.dataArray[indexPath.row];
    return vm.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXNewsCell *cell = [[WXNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.wx.news.identifier"];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXNewsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = self.httpRequest.dataArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WXNewsViewModel *vm = self.httpRequest.dataArray[indexPath.row];
    MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:vm.dataModel.url];
    [self.parentViewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNSegmentSubpageDataSource
- (UIScrollView *)segmentSubpageScrollView {
    return self.listView;
}

#pragma mark - Super
- (BOOL)isChildViewController {
    return YES;
}

@end
