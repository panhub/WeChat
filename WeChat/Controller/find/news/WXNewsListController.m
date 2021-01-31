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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXNewsCell *cell = [[WXNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.wx.news.identifier"];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXNewsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = self.httpRequest.dataArray[indexPath.row];
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
