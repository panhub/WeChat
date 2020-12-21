//
//  WXLocationResultController.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocationResultController.h"
#import "WXLocationListCell.h"
#import "WXMapLocation.h"

@interface WXLocationResultController () <AMapSearchDelegate>
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapInputTipsSearchRequest *request;
@property (nonatomic, strong) NSMutableArray <AMapTip *>*dataSource;
@end

@implementation WXLocationResultController
- (void)initialized {
    [super initialized];
    self.dataSource = [NSMutableArray array];
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 50.f;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - MNSearchResultUpdating
- (void)updateSearchResultText:(NSString *)text forSearchController:(MNSearchViewController *)searchController {
    if (text.length <= 0) {
        [self.dataSource removeAllObjects];
        [self reloadList];
        return;
    }
    self.request.keywords = text;
    [self.search cancelAllRequests];
    [self.search AMapInputTipsSearch:self.request];
}

- (void)reset {
    [self.dataSource removeAllObjects];
    [self reloadList];
}

#pragma mark - AMapSearchDelegate
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:response.tips];
    [self reloadList];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXLocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.location.result.cell"];
    if (!cell) {
        cell = [[WXLocationListCell alloc] initWithReuseIdentifier:@"com.wx.location.result.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .8f);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXLocationListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) return;
    cell.tip = self.dataSource[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) return;
    AMapTip *tip = self.dataSource[indexPath.row];
    if (self.didSelectHandler) {
        WXMapLocation *location = [WXMapLocation pointWithLatitude:tip.location.latitude longitude:tip.location.longitude];
        location.address = tip.name;
        self.didSelectHandler(location);
    }
}

#pragma mark - Setter
- (void)setLocation:(AMapGeoPoint *)location {
    self.request.location = [NSString stringWithFormat:@"%@,%@", @(location.longitude), @(location.latitude)];
}

- (void)setAddress:(AMapLocationReGeocode *)address {
    self.request.city = address.citycode;
}

#pragma mark - Getter
- (AMapSearchAPI *)search {
    if (!_search) {
        AMapSearchAPI *search = [[AMapSearchAPI alloc] init];
        search.delegate = self;
        search.timeout = 10;
        search.language = AMapSearchLanguageZhCN;
        _search = search;
    }
    return _search;
}

- (AMapInputTipsSearchRequest *)request {
    if (!_request) {
        AMapInputTipsSearchRequest *request = [[AMapInputTipsSearchRequest alloc] init];
        request.cityLimit = YES;
        _request = request;
    }
    return _request;
}

#pragma mark - Super
- (BOOL)isChildViewController {
    return YES;
}

@end
