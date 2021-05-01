//
//  WXChatLocationResultController.m
//  WeChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatLocationResultController.h"
#import "WXLocationListCell.h"

@interface WXChatLocationResultController () <AMapSearchDelegate>
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapInputTipsSearchRequest *request;
@property (nonatomic, strong) NSMutableArray <AMapTip *>*dataSource;
@end

@implementation WXChatLocationResultController
- (void)initialized {
    [super initialized];
    self.dataSource = [NSMutableArray array];
}

- (void)createView {
    [super createView];

    self.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 50.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
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

- (void)resetSearchResults {
    [self.dataSource removeAllObjects];
    [self reloadList];
}

#pragma mark - AMapSearchDelegate
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {
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
        self.didSelectHandler(tip.name, tip.address, tip.location);
    }
}

#pragma mark - Setter
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    _coordinate = coordinate;
    self.request.location = [NSString stringWithFormat:@"%@,%@", @(coordinate.longitude), @(coordinate.latitude)];
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
